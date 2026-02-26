import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../add_retailer_sale/add_retailer_sale_screen.dart';
import 'list_retailer_sale_viewmodel.dart';

class RetailerSaleListView extends StatelessWidget {
  const RetailerSaleListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RetailerSaleListViewModel>.reactive(
      viewModelBuilder: () => RetailerSaleListViewModel(),
      onViewModelReady: (model) => model.fetchRetailers(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Retailers Sale"),
          backgroundColor: Colors.blueAccent,
          elevation: 0,
        ),
        backgroundColor: Colors.grey[100],
        body: model.isBusy
            ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent))
            : model.retailers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 60, color: Colors.grey[500]),
                        const SizedBox(height: 16),
                        const Text(
                          "No retailers Sale found",
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: model.retailers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final retailer = model.retailers[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              /// Left Section: Icon or initials
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.indigo.shade100,
                                child: Text(
                                  retailer.name1?.isNotEmpty == true
                                      ? retailer.name1![0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              /// Center Section: Retailer info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      retailer.name1 ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _InfoLabelValue(
                                            label: "Total Qty",
                                            value: retailer.qtyTotal
                                                    ?.toStringAsFixed(2) ??
                                                "0",
                                          ),
                                        ),
                                        Expanded(
                                          child: _InfoLabelValue(
                                            label: "Total Amount",
                                            value:
                                                "₹${retailer.amountTotal?.toStringAsFixed(2) ?? '0.00'}",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              /// Right Section: Date
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 18, color: Colors.indigo),
                                  const SizedBox(height: 4),
                                  Text(
                                    retailer.date ?? 'No Date',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RetailerSaleView(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Sale"),
          backgroundColor: Colors.blueAccent,
        ),
      ),
    );
  }
}

class _InfoLabelValue extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLabelValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(fontSize: 12, color: Colors.black54, height: 1.3),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }
}
