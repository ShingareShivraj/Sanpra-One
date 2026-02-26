import 'dart:async';

import 'package:geolocation/screens/stock_screen/stock_screen.dart';
import 'package:stacked/stacked.dart';

import '../../services/order_services.dart';

class ItemStockViewModel extends BaseViewModel {
  List<ItemStock> allItems = [];
  List<ItemStock> filteredItems = [];
  List<String> warehouses = [];

  String selectedWarehouse = "All";
  String searchQuery = "";

  Timer? _debounce;

  Future<void> fetchStock() async {
    setBusy(true);

    try {
      allItems = await OrderServices().fetchStocks();

      warehouses = [
        "All",
        ...{for (var i in allItems) i.warehouse}
      ];

      applyFilters();
    } catch (e) {
      print("Error fetching stock: $e");
    }

    setBusy(false);
  }

  // 🔍 Debounced Search
  void updateSearch(String value) {
    searchQuery = value;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      applyFilters();
    });
  }

  void updateWarehouse(String warehouse) {
    selectedWarehouse = warehouse;
    applyFilters();
  }

  void applyFilters() {
    filteredItems = allItems.where((item) {
      final matchWarehouse =
          selectedWarehouse == "All" || item.warehouse == selectedWarehouse;

      final query = searchQuery.toLowerCase();
      final matchSearch = item.itemName.toLowerCase().contains(query) ||
          item.itemCode.toLowerCase().contains(query);

      return matchWarehouse && matchSearch;
    }).toList();

    notifyListeners();
  }

  int selectedFilter = 0; // 0 = all, 1 = low, 2 = high

  void updateFilter(int value) {
    selectedFilter = value;
    applyFilters();
    notifyListeners();
  }
}
