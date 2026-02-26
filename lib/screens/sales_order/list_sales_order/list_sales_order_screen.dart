import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/model/order_list_model.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';

import '../../../router.router.dart';
import 'list_salesorder_viewmodel.dart';

class ListOrderScreen extends StatelessWidget {
  const ListOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListOrderModel>.reactive(
      viewModelBuilder: () => ListOrderModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Sales Order'),
        ),
        body: fullScreenLoader(
          context: context,
          loader: model.isBusy,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ------------------------
                // Filters Row
                // ------------------------
                Column(
                  children: [
                    Row(
                      children: [
                        // -----------------------------
                        // Customer TextField (searchable)
                        // -----------------------------
                        Expanded(
                          child: TextField(
                            controller: model.customerController,
                            onChanged: model.setCustomer,
                            // persistent controller
                            decoration: InputDecoration(
                              labelText: "Search Customer",
                              prefixIcon: const Icon(Icons.person_2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),
                        // -----------------------------
                        // Status Dropdown
                        // -----------------------------
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: "Status",
                              prefixIcon: const Icon(Icons.info_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            initialValue: model.selectedStatus,
                            items: model.statusList
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              model.setStatus(value);
                              model.applyFilters();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // -----------------------------
                    // Clear Filter Button
                    // -----------------------------
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          model.clearFilter();
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text("Clear Filters"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                // ------------------------
                // Order List
                // ------------------------
                Expanded(
                  child: model.filteredOrderList.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () => model.refresh(),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: model.filteredOrderList.length,
                            itemBuilder: (context, index) {
                              final order = model.filteredOrderList[index];
                              model.getOrderDisplayStatus(
                                  order.status, order.deliveryStatus);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _OrderCard(
                                  order: order,
                                  model: model,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.pushNamed(
              context,
              Routes.addOrderScreen,
              arguments: const AddOrderScreenArguments(orderid: ""),
            );
            if (result == true) {
              model.refresh();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Order'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'No orders found!',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderList order;
  final ListOrderModel model;

  const _OrderCard({required this.order, required this.model});

  @override
  Widget build(BuildContext context) {
    final statusText =
        model.getOrderDisplayStatus(order.status, order.deliveryStatus);
    final statusColor = getStatusColor(statusText);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => model.onRowClick(context, order),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName ?? "Unknown Customer",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.transactionDate ?? "No Date",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ✅ FIXED STATUS PILL
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        border: Border.all(color: statusColor),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                order.warehouse ?? "",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.black12, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3, // ✅ Warehouse gets more space
                    child: _buildDetailBlock("Order ID", order.name ?? "N/A"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildDetailBlock("Items", "${order.totalQty ?? 0}"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildDetailBlock(
                      "Amount",
                      "₹${(order.grandTotal ?? 0).toStringAsFixed(2)}",
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.owner ?? "N/A",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns color based on order status
  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orangeAccent;
      case "Accepted":
        return Colors.blueAccent;
      case "Partially Delivered":
        return Colors.teal;
      case "Fully Delivered":
        return Colors.green;
      case "Cancelled":
        return Colors.redAccent;
      case "Closed":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailBlock(
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    final style = valueStyle ??
        const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),

        // ✅ AutoSize + wrap long words (no-space strings)
        AutoSizeText(
          value.split('').join('\u200B'),
          maxLines: 2,
          minFontSize: 10,
          stepGranularity: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ],
    );
  }
}
