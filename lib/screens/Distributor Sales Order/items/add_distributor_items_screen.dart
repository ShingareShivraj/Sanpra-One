import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../model/add_order_model.dart';
import '../../../services/add_order_services.dart';

class ItemDistributorListModel extends BaseViewModel {
  final TextEditingController searchController = TextEditingController();
  final AddOrderServices _service = AddOrderServices();

  List<Items> _items = [];
  List<Items> filteredItems = [];

  // itemCode → qty (single source of truth)
  final Map<String, double> _qtyMap = {};

  // itemCode → original qty from the passed selected list
  final Map<String, double> _originalQtyMap = {};

  Timer? _debounce;

  Future<void> initialise(
      BuildContext context,
      String warehouse,
      List<Items> items,
      List<Items> selected,
      ) async {
    setBusy(true);

    _items = await _service.fetchItems(warehouse);

    // Store original selected qtys for restoration
    for (final s in selected) {
      if (s.itemCode != null) {
        final qty = (s.qty ?? 1).toDouble();
        _originalQtyMap[s.itemCode!] = qty;
        _qtyMap[s.itemCode!] = qty;
      }
    }

    _syncQtyToItems();
    filteredItems = List.of(_items);

    setBusy(false);
  }

  void _syncQtyToItems() {
    for (final item in _items) {
      item.qty = _qtyMap[item.itemCode ?? ""] ?? 0;
    }
  }

  List<Items> get selectedItems {
    return _items
        .where((e) => (_qtyMap[e.itemCode ?? ""] ?? 0) > 0)
        .map((e) {
      e.qty = _qtyMap[e.itemCode ?? ""] ?? 0;
      return e;
    })
        .toList();
  }

  bool isSelected(Items item) =>
      (_qtyMap[item.itemCode ?? ""] ?? 0) > 0;

  int getQty(Items item) =>
      (_qtyMap[item.itemCode ?? ""] ?? 0).toInt();

  void toggleSelection(Items item) {
    final key = item.itemCode ?? "";
    if (isSelected(item)) {
      _qtyMap.remove(key);
      item.qty = 0;
    } else {
      final restoredQty = _originalQtyMap[key] ?? 1;
      _qtyMap[key] = restoredQty;
      item.qty = restoredQty;
    }
    notifyListeners();
  }

  void addItem(Items item) {
    final key = item.itemCode ?? "";
    final current = _qtyMap[key] ?? 0;
    _qtyMap[key] = current + 1;
    item.qty = _qtyMap[key];
    notifyListeners();
  }

  void removeItem(Items item) {
    final key = item.itemCode ?? "";
    final current = _qtyMap[key] ?? 0;
    if (current > 1) {
      _qtyMap[key] = current - 1;
      item.qty = _qtyMap[key];
    } else {
      _qtyMap.remove(key);
      item.qty = 0;
    }
    notifyListeners();
  }

  void searchItems(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final lower = query.toLowerCase();
      filteredItems = lower.isEmpty
          ? List.of(_items)
          : _items
          .where((item) =>
      (item.itemName ?? "").toLowerCase().contains(lower) ||
          (item.itemCode ?? "").toLowerCase().contains(lower))
          .toList();
      notifyListeners();
    });
  }

  void clearAll() {
    _qtyMap.clear();
    _syncQtyToItems();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}