import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'delivery_note_viewmodel.dart';

class DeliveryNoteIdScreen extends StatelessWidget {
  final String dnId;

  const DeliveryNoteIdScreen({super.key, required this.dnId});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeliveryNoteViewModel>.reactive(
      viewModelBuilder: () => DeliveryNoteViewModel(),
      onViewModelReady: (vm) => vm.initialise(dnId),
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(dnId),
            centerTitle: true,
          ),
          body: vm.isBusy
              ? const Center(child: CircularProgressIndicator())
              : vm.deliveryNoteData.name == null
                  ? const Center(child: Text("No data found"))
                  : _buildBody(vm.deliveryNoteData),
        );
      },
    );
  }

  Widget _buildBody(DeliveryNote data) {
    final items = data.items ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------
          // SUMMARY CARD
          // --------------------
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row("Customer", data.customerName),
                  _row("Posting Date", data.postingDate),
                  _row("Total Qty", data.totalQty?.toString()),
                  _row("Net Total", data.netTotal?.toString()),
                  _row("Grand Total", data.grandTotal?.toString()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Items",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // --------------------
          // ITEMS LIST
          // --------------------
          ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    item.itemName ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Qty: ${item.qty ?? 0}"),
                      Text("Rate: ${item.rate ?? 0}"),
                      Text("Amount: ${item.amount ?? 0}"),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value ?? "-"),
        ],
      ),
    );
  }
}
