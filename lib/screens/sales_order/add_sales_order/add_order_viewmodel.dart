import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/constants.dart';
import 'package:geolocation/model/order_details_model.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

import '../../../model/add_order_model.dart';
import '../../../services/add_order_services.dart';

class AddOrderViewModel extends BaseViewModel {
  final _logger = Logger();
  final _service = AddOrderServices();

  final formKey = GlobalKey<FormState>();

  final customerController = TextEditingController();
  final deliveryDateController = TextEditingController();

  DateTime? selectedDeliveryDate;
  String orderId = "";
  String name = "";
  bool isEdit = false;
  bool isSame = false;
  String? role;
  List<String> customerNames = [];
  List<String> warehouses = [];
  List<String> orderTypes = ["Sales", "Maintenance", "Shopping Cart"];
  Masters masters = Masters();
  List<Items> selectedItems = [];
  List<Items> items = [];

  List<OrderDetailsModel> orderDetails = [];

  AddOrderModel orderData = AddOrderModel();

  String displayString = '';

  /// Initialization ///
  Future<void> initialise(BuildContext context, String orderId) async {
    setBusy(true);
    this.orderId = orderId;
    orderStatus = 0;

    try {
      masters = await _service.masters() ?? Masters();
      customerNames = masters.customers ?? [];
      warehouses = masters.warehouses ?? [];
      items = masters.items ?? [];
      role = await getUserRole();
      // customerNames = await _service.fetchCustomer();
      // warehouses = await _service.fetchWarehouse();
      _logger.i(orderData.toJson());

      if (orderId.isNotEmpty) {
        isEdit = true;
        orderData.items?.clear();
        selectedItems.clear();

        final fetchedOrder = await _service.getOrder(orderId);
        if (fetchedOrder != null) {
          orderData = fetchedOrder;
          print(orderData);
          customerController.text = orderData.customer ?? "";
          deliveryDateController.text = orderData.deliveryDate ?? "";
          selectedItems.addAll(orderData.items ?? []);
          orderStatus = orderData.docstatus;
          isSame = true;
        }
      }

      orderData.orderType ??= "Sales";
      updateTextFieldValue();
    } catch (e) {
      _showToast("Initialization failed", isError: true);
      _logger.e(e);
    }

    setBusy(false);
  }

  /// Form Submit ///
  Future<void> onSavePressed(BuildContext context) async {
    if (_isSubmitted()) return;

    if (!formKey.currentState!.validate()) return;
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select items to proceed"),
          backgroundColor: Colors.red, // error style
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setBusy(true);
    orderData.items = selectedItems;

    try {
      if (isEdit) {
        await _submitEdit(context);
      } else {
        await _submitNewOrder(context);
      }
    } catch (e) {
      _showToast("Error while saving order", isError: true);
    }

    setBusy(false);
  }

  Future<void> _submitEdit(BuildContext context) async {
    name = await _service.addOrder(orderData);
    if (name.isNotEmpty) isSame = true;
  }

  Future<void> _submitNewOrder(BuildContext context) async {
    name = await _service.addOrder(orderData);
    if (name.isNotEmpty) await initialise(context, name);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Close order
  Future<bool> closeNewOrder(BuildContext context) async {
    setBusy(true);

    final success = await _service.closeOrder(orderData.name);

    _showSnackBar(
      context,
      success ? 'Order closed successfully' : 'Failed to close order',
    );

    if (success) await initialise(context, name);

    setBusy(false);

    return success;
  }

  Future<bool> openNewOrder(BuildContext context) async {
    setBusy(true);

    final success = await _service.reOpenOrder(orderData.name);

    _showSnackBar(
      context,
      success ? 'Order re-opened successfully' : 'Failed to re-open order',
    );

    if (success) await initialise(context, name);

    setBusy(false);

    return success;
  }

  /// Submit Order ///
  Future<void> onSubmitPressed(BuildContext context) async {
    if (_isSubmitted()) return;

    if (!formKey.currentState!.validate()) return;

    setBusy(true);
    orderData
      ..items = selectedItems
      ..docstatus = 1;

    try {
      final res = await _service.updateOrder(orderData);
      if (res && context.mounted) Navigator.pop(context);
    } catch (e) {
      _showToast("Failed to submit order", isError: true);
    }

    setBusy(false);
  }

  /// Cancel Order ///
  Future<void> onCancelPressed(BuildContext context) async {
    setBusy(true);
    orderData
      ..items = selectedItems
      ..docstatus = 2;

    try {
      final res = await _service.cancelOrder(orderData);
      if (res && context.mounted) Navigator.pop(context);
    } catch (e) {
      _showToast("Failed to cancel order", isError: true);
    }

    setBusy(false);
  }

  void onMenuSelected(String value, BuildContext context) {
    if (value == 'create_delivery_note') {
      _createDeliveryNote(context);
    }
  }

  void _createDeliveryNote(BuildContext context) {
    // Navigate to delivery note screen or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Delivery Note selected')),
    );
    // Navigator.push(...); // or show a form, etc.
  }

  /// UI Logic ///
  double getQuantity(Items item) {
    return (item.qty ?? 1.0).clamp(0.0, double.infinity);
  }

  void updateTextFieldValue() {
    displayString = selectedItems.isEmpty
        ? 'Items are not selected'
        : '${selectedItems.length} items selected';
    notifyListeners();
  }

  Future<void> selectDeliveryDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDeliveryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDeliveryDate = picked;
      deliveryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      orderData.deliveryDate = deliveryDateController.text;
      isSame = false;
      notifyListeners();
    }
  }

  /// Setters ///
  void setCustomer(String? customer) {
    isSame = false;
    orderData.customer = customer;
    notifyListeners();
  }

  void setOrderType(String? type) {
    isSame = false;
    orderData.orderType = type;
    notifyListeners();
  }

  void setWarehouse(String? warehouse) {
    isSame = false;
    orderData.setWarehouse = warehouse;
    notifyListeners();
  }

  Future<void> setSelectedItems(List<Items> items) async {
    isSame = false;
    selectedItems = items;

    for (var item in selectedItems) {
      item
        ..warehouse = orderData.setWarehouse
        ..deliveryDate = orderData.deliveryDate
        ..amount = (item.qty ?? 1.0) * (item.rate ?? 0.0);
    }

    orderData.items = selectedItems;
    updateTextFieldValue();

    try {
      orderDetails = await _service.orderDetails(orderData);
      _updateOrderDetails(orderDetails);
    } catch (e) {
      _showToast("Failed to update order details", isError: true);
    }

    notifyListeners();
  }

  Timer? _debounce;

  void _updateOrderDetails(List<OrderDetailsModel> details) {
    if (details.isEmpty) return;

    final d = details.first;
    orderData
      ..totalTaxesAndCharges = d.totalTaxesAndCharges
      ..grandTotal = d.grandTotal
      ..discountAmount = d.discountAmount
      ..total = d.netTotal
      ..netTotal = d.netTotal;
    isSame = false;
  }

  /// Map controllers by item index
  final Map<int, TextEditingController> _quantityControllers = {};
  final Map<int, TextEditingController> _rateControllers = {};

  TextEditingController getQuantityController(int index) {
    if (!_quantityControllers.containsKey(index)) {
      final item = selectedItems[index];
      _quantityControllers[index] =
          TextEditingController(text: (item.qty?.toInt() ?? 1).toString());
    }
    return _quantityControllers[index]!;
  }

  TextEditingController getRateController(int index) {
    if (!_rateControllers.containsKey(index)) {
      final item = selectedItems[index];
      _rateControllers[index] =
          TextEditingController(text: item.rate?.toStringAsFixed(2) ?? "0");
    }
    return _rateControllers[index]!;
  }

  /// Debounced backend update
  void _debouncedUpdate() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        orderDetails = await _service.orderDetails(orderData);
        _updateOrderDetails(orderDetails);
        notifyListeners();
      } catch (e) {
        _showToast("Failed to update order details", isError: true);
      }
    });
  }

  void setItemQuantity(int index, int newQty) {
    isSame = false;
    if (newQty < 0) newQty = 0;

    final item = selectedItems[index];
    _quantityControllers[index]?.text = newQty.toString();

    item.qty = newQty.toDouble();
    item.amount = (item.qty ?? 0.0) * (item.rate ?? 0.0);

    orderData.items = selectedItems;

    _debouncedUpdate(); // call API after debounce
    notifyListeners();
  }

  void updateItemQuantity(int index, int delta) {
    isSame = false;

    final item = selectedItems[index];
    final newQty = ((item.qty ?? 0.0) + delta).clamp(0, double.infinity);
    item.qty = double.parse(newQty.toString());
    item.amount = newQty * (item.rate ?? 0.0);

    orderData.items = selectedItems;

    _debouncedUpdate(); // call API after debounce
    notifyListeners();
  }

  void setItemRate(int index, double rate) {
    final item = selectedItems[index];
    item.rate = rate;
    item.amount = rate * (item.qty ?? 1);

    orderData.items = selectedItems;

    _debouncedUpdate(); // call API after debounce
    notifyListeners();
  }

  void deleteItem(int index) {
    isSame = false;
    final removed = selectedItems.removeAt(index);

    // dispose controllers to avoid leaks
    _quantityControllers[index]?.dispose();
    _rateControllers[index]?.dispose();
    _quantityControllers.remove(index);
    _rateControllers.remove(index);

    orderData.items = selectedItems;

    _debouncedUpdate();
    updateTextFieldValue();
    notifyListeners();
  }

  /// Validators ///
  String? validateWarehouse(String? value) => (value == null || value.isEmpty)
      ? 'Please select source warehouse'
      : null;

  String? validateDeliveryDate(String? value) =>
      (value == null || value.isEmpty) ? 'Please select delivery date' : null;

  String? validateOrderType(String? value) =>
      (value == null || value.isEmpty) ? 'Please select order type' : null;

  /// Helpers ///
  bool _isSubmitted() {
    if (orderStatus == 1) {
      _showToast('This document is already submitted.', isError: true);
      return true;
    }
    return false;
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      textColor: Colors.white,
    );
  }

  /// Dispose ///
  @override
  void dispose() {
    customerController.dispose();
    deliveryDateController.dispose();
    super.dispose();
  }
}
