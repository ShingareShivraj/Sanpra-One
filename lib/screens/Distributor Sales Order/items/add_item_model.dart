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
  final Map<String, Items> _selectedMap = {};

  // itemCode → original qty from previously selected items
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
    filteredItems = List.of(_items);

    // Restore previously selected items with their qty
    for (var selectedItem in selected) {
      final match = _items.firstWhere(
            (e) => e.itemCode == selectedItem.itemCode,
        orElse: () => Items(itemCode: selectedItem.itemCode),
      );
      final qty = (selectedItem.qty ?? 1).toDouble();
      match.qty = qty;
      _originalQtyMap[match.itemCode ?? ""] = qty;
      _selectedMap[match.itemCode ?? ""] = match;
    }

    setBusy(false);
  }

  List<Items> get selectedItems => _selectedMap.values.toList();

  bool isSelected(Items item) => _selectedMap.containsKey(item.itemCode);

  void toggleSelection(Items item) {
    final key = item.itemCode ?? "";
    if (isSelected(item)) {
      _selectedMap.remove(key);
      item.qty = 0;
    } else {
      // restore original qty if it existed, else default to 1
      item.qty = _originalQtyMap[key] ?? 1;
      _selectedMap[key] = item;
    }
    notifyListeners();
  }

  void addItem(Items item) {
    final key = item.itemCode ?? "";
    item.qty = (item.qty ?? 0) + 1;
    _selectedMap[key] = item;
    notifyListeners();
  }

  void removeItem(Items item) {
    final key = item.itemCode ?? "";
    final currentQty = item.qty ?? 0;
    if (currentQty > 1) {
      item.qty = currentQty - 1;
      _selectedMap[key] = item;
    } else {
      _selectedMap.remove(key);
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

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}