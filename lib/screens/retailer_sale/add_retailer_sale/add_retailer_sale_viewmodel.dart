import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../model/add_retailer_sale_model.dart';
import '../../../model/retailer_model.dart';
import '../../../services/add_retailer_sale_services.dart';

class RetailerSaleViewModel extends BaseViewModel {
  final _service = RetailerSaleService();

  List<Retailer> retailerList = [];
  List<Items> selectedItems = [];
  List<Items> items = [];

  RetailerSale retailerSale = RetailerSale();
  String? selectedRetailer;
  DateTime? selectedDate;
  bool res = false;
  final dateController = TextEditingController();

  double totalAmount = 0;

  Future<void> init() async {
    setBusy(true);
    retailerList = await _service.fetchRetailers();
    items = (await _service.getAllItems()).cast<Items>();
    setBusy(false);
  }

  void setRetailer(String? val) {
    selectedRetailer = val;
    notifyListeners();
  }

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate = picked;
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      notifyListeners();
    }
  }

  void addItem(Items item) {
    selectedItems.add(item);
    // _recalculateTotal();
    notifyListeners();
  }

  void removeItem(int index) {
    selectedItems.removeAt(index);
    // _recalculateTotal();
    notifyListeners();
  }

  void updateQuantity(int index, double qty) {
    selectedItems[index].quantity = qty;
    selectedItems[index].amount =
        (qty * (selectedItems[index].rate ?? 1.0)).toInt();
    // _recalculateTotal();
    notifyListeners();
  }

  // void _recalculateTotal() {
  //   totalAmount = selectedItems.fold(0.0, (sum, item) => sum + item.amount);
  // }

  Future<void> submit(BuildContext context) async {
    if (selectedRetailer == null ||
        selectedDate == null ||
        selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }
    retailerSale.name1 = selectedRetailer;
    retailerSale.date = dateController.text;
    retailerSale.items = selectedItems ?? [];

    res = await _service.addRetailerSale(retailerSale);
    if (res) {
      selectedItems.clear();
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }
}
