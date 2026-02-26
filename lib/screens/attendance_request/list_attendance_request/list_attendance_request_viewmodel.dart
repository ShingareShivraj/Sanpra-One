import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/services/attendance_requests_services.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class AttendanceRequestListViewModel extends BaseViewModel {
  final AttendanceRequestsServices _services = AttendanceRequestsServices();

  List<AttendanceRequestModel> _requests = [];

  final List<int> _availableYears = [2022, 2023, 2024, 2025, 2026, 2027];
  int? _selectedYear;
  int? _selectedMonth;
  String? monthName;

  // ================= GETTERS =================
  List<AttendanceRequestModel> get requests => _requests;
  List<int> get availableYears => _availableYears;
  int? get selectedYear => _selectedYear;
  int? get selectedMonth => _selectedMonth;

  // ================= INIT =================
  Future<void> initialise() async {
    setBusy(true);
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
    monthName = getMonthName(_selectedMonth!);

    await fetchRequests();
    setBusy(false);
  }

  // ================= FETCH =================
  Future<void> fetchRequests() async {
    try {
      _requests = await _services.getAttendanceRequests(
        _selectedMonth!,
        _selectedYear!,
      );
    } catch (e) {
      _requests = [];
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchRequests();
  }

  // ================= DELETE =================
  Future<void> deleteRequest(String name, int docstatus) async {
    /// SAFETY CHECK (UI + API)
    if (docstatus != 0) {
      Fluttertoast.showToast(
        msg: "Only draft requests can be deleted",
      );
      return;
    }

    setBusy(true);
    try {
      final success = await _services.delete(name);
      if (success) {
        Fluttertoast.showToast(msg: "Request deleted");
        await fetchRequests();
      } else {
        Fluttertoast.showToast(msg: "Unable to delete request");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Delete failed");
    }
    setBusy(false);
  }

  // ================= FILTER =================
  void updateSelectedYear(int? year) {
    _selectedYear = year;
    fetchRequests();
    notifyListeners();
  }

  void updateSelectedMonth(int month) {
    _selectedMonth = month;
    monthName = getMonthName(month);
    fetchRequests();
    notifyListeners();
  }

  // ================= HELPERS =================
  String getMonthName(int month) {
    final date = DateTime(2024, month, 1);
    return DateFormat('MMMM').format(date);
  }

  String formatDate(String? date) {
    if (date == null) return "-";
    try {
      final parsed = DateFormat('dd-MM-yyyy').parse(date);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  String getDayType(int? halfDay) {
    return halfDay == 1 ? "Half Day" : "Full Day";
  }
}

class AttendanceRequestModel {
  final String name;
  final String? employee;
  final String? employeeName;
  final int? docstatus;
  final String? company;
  final String? fromDate;
  final String? halfDayDate;
  final String? toDate;
  final int? halfDay;
  final String? reason;
  final String? explanation;

  AttendanceRequestModel({
    required this.name,
    this.employee,
    this.employeeName,
    this.docstatus,
    this.company,
    this.fromDate,
    this.halfDayDate,
    this.toDate,
    this.halfDay,
    this.reason,
    this.explanation,
  });

  factory AttendanceRequestModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRequestModel(
      name: json['name'],
      employee: json['employee'],
      employeeName: json['employee_name'],
      docstatus: json['docstatus'],
      company: json['company'],
      fromDate: json['from_date'],
      halfDayDate: json['half_day_date'],
      toDate: json['to_date'],
      halfDay: json['half_day'],
      reason: json['reason'],
      explanation: json['explanation'],
    );
  }
}
