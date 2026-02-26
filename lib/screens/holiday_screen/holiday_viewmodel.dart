import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';

import '../../model/holiday_model.dart';
import '../../services/holiday_services.dart';

class Holidayviewmodel extends BaseViewModel {
  Holidayviewmodel({HolidayServices? service})
      : _service = service ?? HolidayServices();

  final HolidayServices _service;

  final List<int> _availableYears = const [2022, 2023, 2024, 2025, 2026, 2027];
  List<int> get availableYears => _availableYears;

  int? _selectedYear;
  int? get selectedYear => _selectedYear;

  List<HolidayList> _holidaylist = const [];
  List<HolidayList> get holidaylist => _holidaylist;

  // Simple in-memory cache: year -> holidays
  final Map<int, List<HolidayList>> _cache = {};

  // Used to avoid race conditions when user changes year quickly
  int _requestId = 0;

  Future<void> initialise(BuildContext context) async {
    _selectedYear ??= DateTime.now().year;
    await _loadYear(_selectedYear!, useCache: true, setBusyUi: true);
  }

  void updateSelectedYear(int? year) {
    if (year == null) return;

    // If same year selected, do nothing
    if (year == _selectedYear) return;

    _selectedYear = year;
    notifyListeners(); // update dropdown immediately

    // Load list for selected year (async)
    _loadYear(year, useCache: true, setBusyUi: true);
  }

  Future<void> refresh() async {
    if (_selectedYear == null) return;
    await _loadYear(_selectedYear!, useCache: false, setBusyUi: true);
  }

  Future<void> _loadYear(
    int year, {
    required bool useCache,
    required bool setBusyUi,
  }) async {
    // Serve from cache instantly
    if (useCache && _cache.containsKey(year)) {
      _holidaylist = _cache[year]!;
      notifyListeners();
      return;
    }

    final int currentReq = ++_requestId;

    Future<void> task() async {
      final list = await _service.fetchHoliday(year.toString());

      // Ignore stale responses if user selected another year quickly
      if (currentReq != _requestId) return;

      // If API already returns only that year, no need to filter.
      // If it returns mixed years, keep this filter:
      final filtered = list.where((h) => h.year == year.toString()).toList();

      _cache[year] = filtered;
      _holidaylist = filtered;
      notifyListeners();
    }

    if (setBusyUi) {
      await runBusyFuture(task());
    } else {
      await task();
    }
  }
}
