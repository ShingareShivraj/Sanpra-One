import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../model/add_retailer_sale_model.dart';
import 'add_retailer_sale_viewmodel.dart';

class RetailerSaleView extends StatelessWidget {
  const RetailerSaleView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RetailerSaleViewModel>.reactive(
      viewModelBuilder: () => RetailerSaleViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Retailer Sale"),
          foregroundColor: Colors.white,
        ),
        body: model.isBusy
            ? const Center(child: CircularProgressIndicator())
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Retailer Dropdown
                        DropdownButtonFormField<String>(
                          value: model.selectedRetailer,
                          decoration: InputDecoration(
                            labelText: "Select Retailer",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: model.retailerList.map((e) {
                            return DropdownMenuItem(
                              value: e.name,
                              child: Text(e.name1 ?? ""),
                            );
                          }).toList(),
                          onChanged: model.setRetailer,
                        ),

                        const SizedBox(height: 16),

                        /// Date Field
                        TextFormField(
                          controller: model.dateController,
                          readOnly: true,
                          onTap: () => model.pickDate(context),
                          decoration: InputDecoration(
                            labelText: "Sale Date",
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Add Item Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text("Add Item"),
                            onPressed: () async {
                              _showAddItemBottomSheet(
                                  context, model.items, model);
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// Items List
                        Expanded(
                          child: model.selectedItems.isEmpty
                              ? const Center(child: Text("No items added yet"))
                              : ListView.builder(
                                  itemCount: model.selectedItems.length,
                                  itemBuilder: (context, index) {
                                    final item = model.selectedItems[index];
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 2,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                        title: Text(
                                          item.itemName ?? "Unnamed Item",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "UOM: ${item.uom ?? '-'} | Rate: ₹${item.rate?.toStringAsFixed(2) ?? '0.00'}"),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove,
                                                      size: 20),
                                                  onPressed: () {
                                                    final newQty =
                                                        ((item.quantity ?? 0) -
                                                                1)
                                                            .clamp(1, 999);
                                                    model.updateQuantity(index,
                                                        newQty.toDouble());
                                                  },
                                                ),
                                                Text(
                                                  item.quantity
                                                          ?.toStringAsFixed(
                                                              1) ??
                                                      "0",
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add,
                                                      size: 20),
                                                  onPressed: () {
                                                    model.updateQuantity(
                                                        index,
                                                        (item.quantity ?? 0) +
                                                            1);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "₹${item.amount?.toStringAsFixed(2) ?? '0.00'}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            GestureDetector(
                                              onTap: () =>
                                                  model.removeItem(index),
                                              child: const Icon(Icons.delete,
                                                  size: 20,
                                                  color: Colors.redAccent),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 16),

                        /// Total
                        Text(
                          "Total: ₹${model.totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.send),
                            label: const Text("Submit Sale"),
                            onPressed: () => model.submit(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _showAddItemBottomSheet(BuildContext context, List<Items> allItems,
      RetailerSaleViewModel model) async {
    final result = await showModalBottomSheet<Items>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RetailerItemBottomSheet(itemList: allItems),
    );

    if (result != null) {
      model.addItem(result);
    }
  }
}

class RetailerItemBottomSheet extends StatefulWidget {
  final List<Items> itemList;

  const RetailerItemBottomSheet({super.key, required this.itemList});

  @override
  State<RetailerItemBottomSheet> createState() =>
      _RetailerItemBottomSheetState();
}

class _RetailerItemBottomSheetState extends State<RetailerItemBottomSheet> {
  Items? selectedItem;
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController rateController =
      TextEditingController(text: '0.0');

  double get quantity => double.tryParse(qtyController.text) ?? 1.0;
  int get rate => int.tryParse(rateController.text) ?? 0;
  int get amount => quantity.toInt() * rate;

  @override
  void dispose() {
    qtyController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Retailer Item",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// Dropdown for Item Selection
            DropdownButtonFormField<Items>(
              decoration: InputDecoration(
                labelText: "Select Item",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: selectedItem,
              items: widget.itemList.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.itemName ?? item.itemCode ?? "Unnamed Item"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedItem = value;
                  rateController.text = value?.rate?.toString() ?? '';
                });
              },
            ),

            /// Item details
            if (selectedItem != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DetailBox(
                        label: "Item Code", value: selectedItem!.itemCode),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailBox(label: "UOM", value: selectedItem!.uom),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// Quantity input
              TextFormField(
                controller: qtyController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              /// Rate input
              TextFormField(
                controller: rateController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Rate",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              /// Calculated amount
              Text(
                "Amount: ₹${amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
            ],

            const SizedBox(height: 24),

            /// Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Add Item"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: selectedItem == null
                    ? null
                    : () {
                        final item = Items(
                          itemCode: selectedItem!.itemCode,
                          itemName: selectedItem!.itemName,
                          uom: selectedItem!.uom,
                          quantity: quantity,
                          rate: rate,
                          amount: amount,
                        );
                        Navigator.pop(context, item);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  final String? label;
  final String? value;

  const _DetailBox({this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label ?? '',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: Text(value ?? '',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
