import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../model/leave_list.dart';
import '../../../services/list_leave_services.dart';

class LeaveViewModel extends BaseViewModel {
  // -------------------- STATE --------------------
  final List<int> _availableYears = [2022, 2023, 2024, 2025, 2026, 2027];
  LeaveListDetails details = LeaveListDetails();
  List<Upcoming> _allUpcomingLeaves = [];
  List<Taken> _allTakenLeaves = [];

  List<Upcoming> _filteredUpcomingLeaves = [];
  List<Taken> _filteredTakenLeaves = [];

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  // -------------------- GETTERS --------------------
  List<Upcoming> get leavelist => _filteredUpcomingLeaves;

  List<Taken> get takenlist => _filteredTakenLeaves;

  List<int> get availableYears => _availableYears;

  int get selectedYear => _selectedYear;

  int get selectedMonth => _selectedMonth;

  // -------------------- INIT --------------------
  Future<void> initialise(BuildContext context) async {
    setBusy(true);

    await _fetchAllLeaves();
    _applyFilters();

    setBusy(false);
  }

  // -------------------- REFRESH --------------------
  Future<void> refresh() async {
    await _fetchAllLeaves();
    _applyFilters();
    notifyListeners();
  }

  // -------------------- DATA FETCH --------------------
  Future<void> _fetchAllLeaves() async {
    final services = ListLeaveServices();
    details = await services.leaveListDetails() ?? LeaveListDetails();
    _allUpcomingLeaves = details.upcoming ?? [];
    _allTakenLeaves = details.taken ?? [];
  }

  // -------------------- FILTER LOGIC --------------------
  void _applyFilters() {
    _filteredUpcomingLeaves = _filterLeavesByMonthAndYear(_allUpcomingLeaves);
    _filteredTakenLeaves = _filterTakenLeavesByMonthAndYear(_allTakenLeaves);
  }

  List<Upcoming> _filterLeavesByMonthAndYear(List<Upcoming> leaves) {
    return leaves.where((leave) {
      final date = _safeParseDate(leave.postingDate);
      return date != null &&
          date.year == _selectedYear &&
          date.month == _selectedMonth;
    }).toList();
  }

  List<Taken> _filterTakenLeavesByMonthAndYear(List<Taken> leaves) {
    return leaves.where((leave) {
      final date = _safeParseDate(leave.postingDate);
      return date != null &&
          date.year == _selectedYear &&
          date.month == _selectedMonth;
    }).toList();
  }

  DateTime? _safeParseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  // -------------------- DROPDOWN ACTIONS --------------------
  void updateSelectedYear(int? year) {
    if (year == null || year == _selectedYear) return;
    _selectedYear = year;
    _applyFilters();
    notifyListeners();
  }

  void updateSelectedmonth(int? month) {
    if (month == null || month == _selectedMonth) return;
    _selectedMonth = month;
    _applyFilters();
    notifyListeners();
  }

  // -------------------- UI HELPERS --------------------
  Color getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.grey;
      case 'approved':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.black87;
    }
  }

  String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2024, month));
  }
}
