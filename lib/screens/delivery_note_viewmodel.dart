import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../model/add_order_model.dart';
import '../services/add_order_services.dart';
import 'delivery_note_list.dart';

class DeliveryNoteViewModel extends BaseViewModel {
  final AddOrderServices _service = AddOrderServices();

  late AddOrderModel orderData;
  List<Items> items = [];
  double baseTotal = 0.0;
  double tax = 0.0;
  double grandTotal = 0.0;

  bool isLoading = false;

  Future<void> init(AddOrderModel order) async {
    orderData = order;
    setBusy(true);

    final rawItems = List<Items>.from(orderData.items ?? []);
    final selectItems = await _service.fetchItems(orderData.setWarehouse);

    final updated = <Items>[];
    for (var item in rawItems) {
      final match = selectItems.firstWhere(
        (e) => e.itemCode == item.itemCode,
        orElse: () => Items(itemCode: item.itemCode, actualQty: 0),
      );

      final remainingQty = (item.qty ?? 0) - (item.deliveredQty ?? 0);

      if (remainingQty > 0) {
        item
          ..qty = remainingQty
          ..actualQty = match.actualQty ?? 0;

        updated.add(item);
      }
    }

    items = updated;
    _calculateTotals();
    setBusy(false);
  }

  void updateQty(int index, String value) {
    final qty = double.tryParse(value) ?? 0;
    if (qty < 0) {
      items[index].qty = 0;
    } else {
      items[index].qty = qty;
    }
    _calculateTotals();
    notifyListeners();
  }

  void removeItem(int index) {
    items.removeAt(index);
    _calculateTotals();
    notifyListeners();
  }

  void _calculateTotals() {
    baseTotal = items.fold(0.0, (sum, i) => sum + (i.rate ?? 0) * (i.qty ?? 0));
    tax = baseTotal * 0.18;
    grandTotal = baseTotal + tax;
  }

  Future<void> submit(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      for (final i in items) {
        if (i.qty == 0) {
          _showSnack(context, "Item ${i.itemName} has zero quantity.");
          _stopLoading();
          return;
        }
        if (i.qty! > (i.actualQty ?? 0)) {
          _showSnack(context,
              "Not enough stock for ${i.itemName}. Available: ${i.actualQty}, Requested: ${i.qty}");
          _stopLoading();
          return;
        }
      }

      final deliveryNoteData = {
        "doctype": "Delivery Note",
        "customer": orderData.customer,
        "posting_date": orderData.deliveryDate?.toString().split(" ").first,
        "set_warehouse": orderData.setWarehouse,
        "items": items
            .map((i) => {
                  "item_code": i.itemCode,
                  "item_name": i.itemName,
                  "qty": i.qty,
                  "rate": i.rate,
                  "amount": i.amount,
                  "against_sales_order": orderData.name,
                  "so_detail": i.name,
                  "warehouse": i.warehouse ?? orderData.setWarehouse,
                })
            .toList(),
      };

      final res = await _service.addDeliveryNote(deliveryNoteData);
      _stopLoading();

      if (res) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ListDeliveryNoteScreen()),
          (route) => route.isFirst, // keep only the very first screen (home)
        );
      } else {
        _showSnack(context, "Failed to create delivery note");
      }
    } catch (e) {
      _stopLoading();
      _showSnack(context, "Error: $e");
    }
  }

  void _stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
