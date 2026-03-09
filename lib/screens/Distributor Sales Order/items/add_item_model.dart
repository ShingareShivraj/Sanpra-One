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
  final Map<String, Items> _selectedMap =
      {}; // ✅ O(1) lookup for selected items

  Timer? _debounce;

  Future<void> initialise(
    BuildContext context,
    String warehouse,
    List<Items> items,
    List<Items> selected,
  ) async {
    setBusy(true);

    // Fetch all items
    _items = await _service.fetchItems(warehouse);
    filteredItems = List.of(_items);

    // Restore previously selected items with qty
    for (var selectedItem in selected) {
      final match = _items.firstWhere(
        (e) => e.itemCode == selectedItem.itemCode,
        orElse: () => Items(itemCode: selectedItem.itemCode),
      );
      match.qty = selectedItem.qty;
      _selectedMap[match.itemCode ?? ""] = match;
    }

    setBusy(false);
  }

  List<Items> get selectedItems => _selectedMap.values.toList();

  bool isSelected(Items item) => _selectedMap.containsKey(item.itemCode);

  void toggleSelection(Items item) {
    if (isSelected(item)) {
      _selectedMap.remove(item.itemCode);
    } else {
      _selectedMap[item.itemCode ?? ""] = item;
    }
    notifyListeners();
  }

  void addItem(Items item) {
    item.qty = (item.qty ?? 0) + 1;
    _selectedMap[item.itemCode ?? ""] = item; // ensure updated qty is tracked
    notifyListeners();
  }

  void removeItem(Items item) {
    final currentQty = item.qty ?? 0;
    if (currentQty > 1) {
      item.qty = currentQty - 1;
      _selectedMap[item.itemCode ?? ""] = item;
    } else {
      // remove if qty is 0 or 1
      _selectedMap.remove(item.itemCode);
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
              .where(
                  (item) => (item.itemName ?? "").toLowerCase().contains(lower))
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
