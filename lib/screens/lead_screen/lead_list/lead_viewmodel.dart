import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocation/model/list_lead_model.dart';
import 'package:geolocation/services/list_lead_services.dart';
import 'package:stacked/stacked.dart';

import '../../../router.router.dart';

class LeadListViewModel extends BaseViewModel {
  List<ListLeadModel> _allLeads = [];
  List<ListLeadModel> filterleadlist = [];

  String _searchText = '';
  Timer? _searchDebounce;

  // cache: key -> "name company" lowercased
  final Map<String, String> _searchCache = {};

  Future<void> initialise() async {
    setBusy(true);
    try {
      await _loadLeads();
      _applySearch(notify: true);
    } finally {
      setBusy(false);
    }
  }

  Future<void> refresh() async {
    await _loadLeads();
    _applySearch(notify: true);
  }

  Future<void> _loadLeads() async {
    _allLeads = await ListLeadServices().fetchLeadList();

    _searchCache.clear();
    for (final l in _allLeads) {
      final key = _cacheKey(l);
      _searchCache[key] = _makeSearchable(l);
    }
  }

  Future<void> onRowClick(BuildContext context, ListLeadModel lead) async {
    final result = await Navigator.pushNamed(
      context,
      Routes.updateLeadScreen,
      arguments: UpdateLeadScreenArguments(updateId: lead.name ?? ""),
    );

    if (result == true) {
      await refresh();
    }
  }

  String _cacheKey(ListLeadModel lead) =>
      (lead.companyName != null && lead.companyName!.isNotEmpty)
          ? lead.companyName!
          : lead.hashCode.toString();

  // ✅ ONLY name + company
  String _makeSearchable(ListLeadModel lead) {
    final company = lead.companyName ?? ''; // change field if yours differs
    return company.toLowerCase();
  }

  void filterBySearch(String value) {
    _searchText = value.trim().toLowerCase();

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _applySearch(notify: true);
    });
  }

  void clearSearch() {
    if (_searchText.isEmpty) return;
    _searchText = '';
    _applySearch(notify: true);
  }

  void _applySearch({required bool notify}) {
    final search = _searchText;

    if (search.isEmpty) {
      filterleadlist = List<ListLeadModel>.from(_allLeads);
      if (notify) notifyListeners();
      return;
    }

    final out = <ListLeadModel>[];
    for (final lead in _allLeads) {
      final key = _cacheKey(lead);
      final blob = _searchCache[key] ?? _makeSearchable(lead);
      if (blob.contains(search)) out.add(lead);
    }

    filterleadlist = out;
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
