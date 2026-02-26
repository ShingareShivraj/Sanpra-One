import 'package:flutter/material.dart';
import 'package:geolocation/model/attendance_request_model.dart';
import 'package:geolocation/services/attendance_requests_services.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class AttendanceRequestViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();

  /// Controllers
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final halfDateController = TextEditingController();
  final explanationController = TextEditingController();

  /// Services
  final AttendanceRequestsServices _services = AttendanceRequestsServices();

  /// Model
  final AttendanceRequest request = AttendanceRequest();

  /// State
  bool halfDay = false;

  /// Dropdown values
  final List<String> reasonList = [
    'Work From Home',
    'On Duty',
  ];

  final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  void initialise(BuildContext context) {}

  /// ---------------- HALF DAY ----------------
  void setHalfDay(bool value) {
    halfDay = value;
    request.halfDay = value ? 1 : 0;

    /// If half day → auto set to date = from date
    if (value && fromDateController.text.isNotEmpty) {
      toDateController.text = fromDateController.text;
      request.toDate = request.fromDate;
    }

    notifyListeners();
  }

  /// ---------------- REASON ----------------
  void setReason(String? value) {
    request.reason = value;
  }

  /// ---------------- EXPLANATION ----------------
  void setExplanation(String value) {
    request.explanation = value;
  }

  /// ---------------- DATE PICKERS ----------------
  Future<void> selectFromDate(BuildContext context) async {
    final date = await _pickDate(context);
    if (date == null) return;

    final formatted = _formatter.format(date);
    fromDateController.text = formatted;
    request.fromDate = formatted;

    /// Auto set To Date if half day

    notifyListeners();
  }

  Future<void> selectToDate(BuildContext context) async {
    final date = await _pickDate(context);
    if (date == null) return;

    final formatted = _formatter.format(date);
    toDateController.text = formatted;
    request.toDate = formatted;

    notifyListeners();
  }

  Future<void> selectHalfDate(BuildContext context) async {
    final date = await _pickDate(context);
    if (date == null) return;

    final formatted = _formatter.format(date);
    halfDateController.text = formatted;
    request.halfDayDate = formatted;

    notifyListeners();
  }

  Future<DateTime?> _pickDate(BuildContext context) {
    return showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
  }

  /// ---------------- VALIDATORS ----------------
  String? validateFromDate(String? value) =>
      value == null || value.isEmpty ? 'Select from date' : null;

  String? validateToDate(String? value) =>
      value == null || value.isEmpty ? 'Select to date' : null;
  String? validateHalfDate(String? value) =>
      value == null || value.isEmpty ? 'Select half date' : null;
  String? validateReason(String? value) =>
      value == null || value.isEmpty ? 'Select reason' : null;

  String? validateExplanation(String? value) =>
      value == null || value.isEmpty ? 'Enter explanation' : null;

  /// ---------------- SUBMIT ----------------
  Future<void> submitAttendanceRequest(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setBusy(true);
    print(request.toJson());
    try {
      bool success = await _services.addRequest(request);

      if (success && context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Attendance request failed: $e');
    } finally {
      setBusy(false);
    }
  }

  /// ---------------- DISPOSE ----------------
  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    explanationController.dispose();
    super.dispose();
  }
}
