import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../model/attendance_model.dart';
import '../../services/attendence_services.dart';

class AttendenceViewModel extends BaseViewModel {
  // ─────────────────────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────────────────────

  final AttendanceServices _service = AttendanceServices();

  final List<int> _availableYears = [2022, 2023, 2024, 2025, 2026, 2027];

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  CalendarFormat calendarFormat = CalendarFormat.week;

  List<AttendanceList> _attendanceList = [];
  AttendanceDetails attendanceDetails = AttendanceDetails();

  // ─────────────────────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────────────────────

  List<int> get availableYears => _availableYears;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  List<AttendanceList> get attendanceList => _attendanceList;

  // ─────────────────────────────────────────────────────────────
  // INITIALIZE
  // ─────────────────────────────────────────────────────────────

  Future<void> initialise(BuildContext context) async {
    setBusy(true);
    await _fetchAttendanceData();
    setBusy(false);
  }

  // ─────────────────────────────────────────────────────────────
  // DATA FETCHING
  // ─────────────────────────────────────────────────────────────

  Future<void> _fetchAttendanceData() async {
    try {
      final results = await Future.wait([
        _service.fetchAttendance(_selectedYear, _selectedMonth),
        _service.fetchAttendanceDetails(_selectedYear, _selectedMonth),
      ]);

      _attendanceList = results[0] as List<AttendanceList>;
      attendanceDetails =
          results[1] as AttendanceDetails? ?? AttendanceDetails();
    } catch (e) {
      debugPrint('Attendance Fetch Error: $e');
      _attendanceList = [];
      attendanceDetails = AttendanceDetails();
    }

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // CALENDAR HELPERS
  // ─────────────────────────────────────────────────────────────

  AttendanceList? getAttendanceForDate(DateTime date) {
    for (final attendance in _attendanceList) {
      if (attendance.attendanceDate == null) continue;

      final parsedDate = DateTime.tryParse(attendance.attendanceDate!);
      if (parsedDate != null && isSameDay(parsedDate, date)) {
        return attendance;
      }
    }
    return null;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void updateCalendarFormat(CalendarFormat format) {
    calendarFormat = format;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // FILTERS (YEAR / MONTH)
  // ─────────────────────────────────────────────────────────────

  Future<void> updateSelectedYear(int year) async {
    if (_selectedYear == year) return;
    _selectedYear = year;
    setBusy(true);
    await _fetchAttendanceData();
    setBusy(false);
  }

  Future<void> updateSelectedMonth(int month) async {
    if (_selectedMonth == month) return;
    _selectedMonth = month;
    setBusy(true);
    await _fetchAttendanceData();
    setBusy(false);
  }

  // ─────────────────────────────────────────────────────────────
  // UI HELPERS
  // ─────────────────────────────────────────────────────────────

  Color getColorForStatus(String? status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'On Leave':
        return Colors.orange;
      case 'Absent':
        return Colors.redAccent;
      case 'Half Day':
        return Colors.indigo;
      default:
        return Colors.grey.shade300;
    }
  }

  String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2024, month));
  }
}
