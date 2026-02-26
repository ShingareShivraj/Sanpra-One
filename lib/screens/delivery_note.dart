import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../model/add_order_model.dart';
import 'delivery_note_viewmodel.dart';

class DeliveryNoteScreen extends StatefulWidget {
  final AddOrderModel orderData;

  const DeliveryNoteScreen({super.key, required this.orderData});

  @override
  State<DeliveryNoteScreen> createState() => _DeliveryNoteScreenState();
}

class _DeliveryNoteScreenState extends State<DeliveryNoteScreen> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeliveryNoteViewModel>.reactive(
      viewModelBuilder: () => DeliveryNoteViewModel(),
      onViewModelReady: (vm) => vm.init(widget.orderData),
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text('Delivery Note'),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: vm.isBusy
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(vm),
          bottomNavigationBar: _buildBottomButtons(vm),
        );
      },
    );
  }

  Widget _buildBody(DeliveryNoteViewModel vm) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(vm: vm),
          const SizedBox(height: 12),
          _ItemsList(vm: vm),
          const SizedBox(height: 12),
          BillingSection(model: vm),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(DeliveryNoteViewModel vm) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Cancel",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => vm.submit(context),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Submit",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
}

/// ---------------- HEADER ----------------
class _HeaderCard extends StatelessWidget {
  final DeliveryNoteViewModel vm;
  const _HeaderCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.local_shipping, color: Colors.indigo),
              const SizedBox(width: 8),
              Text("Delivery Details",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const Divider(height: 20),
            _row(Icons.person, "Customer", vm.orderData.customer ?? "-", style),
            _row(Icons.calendar_today, "Date", vm.orderData.deliveryDate ?? "-",
                style),
            _row(Icons.warehouse, "Warehouse", vm.orderData.setWarehouse ?? "-",
                style),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text("$label: ", style: style?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(
              child: Text(value,
                  style: style?.copyWith(color: Colors.black87),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

/// ---------------- ITEMS LIST ----------------
class _ItemsList extends StatelessWidget {
  final DeliveryNoteViewModel vm;
  const _ItemsList({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [
              Icon(Icons.inventory, color: Colors.teal),
              SizedBox(width: 8),
              Text("Items",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            const Divider(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.items.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.grey.shade200, height: 16),
              itemBuilder: (context, index) {
                final item = vm.items[index];
                return _ItemRow(
                  item: item,
                  onQtyChanged: (val) => vm.updateQty(index, val),
                  onRemove: () => vm.removeItem(index),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final Items item;
  final ValueChanged<String> onQtyChanged;
  final VoidCallback onRemove;

  const _ItemRow({
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qty = item.qty ?? 0;
    final rate = item.rate ?? 0;
    final total = qty * rate;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Name
            Text(
              item.itemName ?? "Item",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Rate, Qty, Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rate: ₹${rate.toStringAsFixed(2)}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green, // ✅ Green color for Rate
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    initialValue: qty.toStringAsFixed(2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: "Qty",
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: onQtyChanged,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Remove Item",
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Available Stock (left) + Total (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available: ${item.actualQty?.toStringAsFixed(0) ?? '0'}",
                  style: TextStyle(
                    fontSize: 13,
                    color: (item.actualQty ?? 0) <= 0
                        ? Colors.redAccent
                        : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Total: ₹${total.toStringAsFixed(2)}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green, // ✅ Green for total
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- BILL SUMMARY ----------------
class BillingSection extends StatelessWidget {
  final DeliveryNoteViewModel model;
  const BillingSection({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tax and Discount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            const Divider(thickness: 1),
            buildBillingRow(
                'Subtotal :', model.orderData.netTotal?.toString() ?? '0.0'),
            const SizedBox(height: 10),
            buildBillingRow('Total Tax :',
                model.orderData.totalTaxesAndCharges?.toString() ?? '0.0'),
            const SizedBox(height: 10),
            buildBillingRow('Discount :',
                model.orderData.discountAmount?.toString() ?? '0.0'),
            const Divider(thickness: 1),
            buildBillingRow(
                'Total :', model.orderData.grandTotal?.toString() ?? '0.0',
                highlight: true),
          ],
        ),
      ),
    );
  }

  Widget buildBillingRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16.0)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: highlight ? Colors.green : Colors.black87)),
      ],
    );
  }
}
