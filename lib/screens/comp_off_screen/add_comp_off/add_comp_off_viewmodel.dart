import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/model/comp_off_model.dart';
import 'package:geolocation/services/comp_off_services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

class AddCompOffViewmodel extends BaseViewModel {
  /// SERVICES
  final CompOffServices _service = CompOffServices();
  final Logger _logger = Logger();

  /// CONTROLLERS
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final halfDayController = TextEditingController();

  /// FORM
  final formKey = GlobalKey<FormState>();

  /// DATA
  CompOff leaveData = CompOff();
  List<String> leaveTypes = [];

  DateTime? fromDate;
  DateTime? toDate;
  DateTime? halfDayDate;
  bool isEdit = false;
  bool isHalfDay = false;

  // -------------------- INIT --------------------
  Future<void> initialise(BuildContext context, String id) async {
    setBusy(true);
    try {
      leaveTypes = await _service.getLeaveTypes();
      if (id.isNotEmpty) {
        isEdit = true;
        leaveData = await _service.getLeave(id) ?? CompOff();
        fromDateController.text = leaveData.workFromDate ?? "";
        toDateController.text = leaveData.workEndDate ?? "";
        halfDayController.text = leaveData.halfDayDate ?? "";
        descriptionController.text = leaveData.reason ?? "";
        isHalfDay = leaveData.halfDay == 1 ? true : false;
      }
    } catch (e, s) {
      _logger.e('Failed to load leave types', error: e, stackTrace: s);
    } finally {
      setBusy(false);
    }
  }

  // -------------------- SAVE --------------------
  Future<void> onSavePressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setBusy(true);
    try {
      _logger.i(leaveData.toJson());

      if (isEdit) {
        final bool success = await _service.updateLeave(leaveData);
        if (success && context.mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final bool success = await _service.addLeave(leaveData);
        if (success && context.mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e, s) {
      _logger.e('Add leave failed', error: e, stackTrace: s);
    } finally {
      setBusy(false);
    }
  }

  // -------------------- HALF DAY --------------------
  void toggleHalfDay(bool value) {
    isHalfDay = value;
    leaveData.halfDay = value ? 1 : 0;

    if (!value) {
      halfDayDate = null;
      halfDayController.clear();
      leaveData.halfDayDate = null;
    }

    notifyListeners();
  }

  bool delete = false;

  Future<void> deleteNote(String leaveId, BuildContext context) async {
    if (leaveId.isEmpty) return;

    try {
      final deleted = await _service.delete(leaveId);

      if (deleted) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true)
              .pop(true); // ✅ ALWAYS WORKS
        }
      } else {
        Fluttertoast.showToast(
          msg: "Leave cannot be deleted (only Draft leaves allowed)",
        );
      }
    } catch (e, stack) {
      _logger.e('Error deleting leave', error: e, stackTrace: stack);
    }
  }

  // -------------------- DATE PICKERS --------------------
  Future<void> selectFromDate(BuildContext context) async {
    final picked = await _pickDate(context, fromDate);
    if (picked == null) return;

    fromDate = picked;
    final formatted = _formatDate(picked);

    fromDateController.text = formatted;
    leaveData.workFromDate = formatted;
  }

  Future<void> selectToDate(BuildContext context) async {
    final picked = await _pickDate(context, toDate);
    if (picked == null) return;

    toDate = picked;
    final formatted = _formatDate(picked);

    toDateController.text = formatted;
    leaveData.workEndDate = formatted;
  }

  Future<void> selectHalfDayDate(BuildContext context) async {
    final picked = await _pickDate(context, halfDayDate);
    if (picked == null) return;

    halfDayDate = picked;
    final formatted = _formatDate(picked);

    halfDayController.text = formatted;
    leaveData.halfDayDate = formatted;
  }

  // -------------------- SETTERS --------------------
  void setDescription(String value) {
    leaveData.reason = value.trim();
  }

  void setLeaveType(String? value) {
    leaveData.leaveType = value;
  }

  // -------------------- VALIDATORS --------------------
  String? validateDate(String? value) =>
      value == null || value.isEmpty ? 'Please select date' : null;

  String? validateLeaveType(String? value) =>
      value == null || value.isEmpty ? 'Please select leave type' : null;

  String? validateDescription(String? value) =>
      value == null || value.isEmpty ? 'Please enter description' : null;

  // -------------------- HELPERS --------------------
  Future<DateTime?> _pickDate(
    BuildContext context,
    DateTime? initial,
  ) {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  // -------------------- DISPOSE --------------------
  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    descriptionController.dispose();
    halfDayController.dispose();
    super.dispose();
  }
}
