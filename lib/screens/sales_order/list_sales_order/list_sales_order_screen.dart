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
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => model.onRowClick(context, order),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 TOP SECTION
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName ?? "Unknown Customer",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.transactionDate ?? "No Date",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Delivery: ${order.deliveryDate ?? "N/A"}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 🔹 STATUS PILL
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: statusColor.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🔹 WAREHOUSE
              Text(
                order.warehouse ?? "",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              /// 🔹 ORDER INFO ROW
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildDetailBlock(
                      "Order ID",
                      order.name ?? "N/A",
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      valueStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildDetailBlock(
                      "Items",
                      "${order.totalQty ?? 0}",
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      valueStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildDetailBlock(
                      "Amount",
                      "₹${(order.grandTotal ?? 0).toStringAsFixed(2)}",
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      valueStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// 🔹 OWNER ROW
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.owner ?? "N/A",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    final style = valueStyle ??
        const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        );
    final labelstyle =
        labelStyle ?? const TextStyle(fontSize: 12, color: Colors.grey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelstyle),
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
