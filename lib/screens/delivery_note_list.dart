import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/model/order_list_model.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';

import '../services/order_services.dart';
import 'delivery_note/delivery_screen.dart';

class ListDeliveryNoteScreen extends StatefulWidget {
  const ListDeliveryNoteScreen({super.key});

  @override
  State<ListDeliveryNoteScreen> createState() => _DeliveryNoteScreenState();
}

class _DeliveryNoteScreenState extends State<ListDeliveryNoteScreen> {
  List<DeliverNoteList> deliveryList = [];
  List<DeliverNoteList> filteredList = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDeliveryNotes();
  }

  Future<void> _fetchDeliveryNotes() async {
    setState(() => isLoading = true);
    final list = await OrderServices().filterFetchDeliveryNote();
    if (mounted) {
      setState(() {
        deliveryList = list;
        filteredList = list;
        isLoading = false;
      });
    }
  }

  void _filterNotes(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredList = deliveryList.where((order) {
        return (order.customerName ?? '').toLowerCase().contains(lowerQuery) ||
            (order.name ?? '').toLowerCase().contains(lowerQuery) ||
            (order.status ?? '').toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Notes'),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: fullScreenLoader(
          context: context,
          loader: isLoading,
          child: Column(
            children: [
              // 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterNotes,
                  decoration: InputDecoration(
                    hintText: "Search by customer, note, or status...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // 📋 Delivery Notes List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchDeliveryNotes,
                  child: filteredList.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final order = filteredList[index];
                            return _OrderCard(
                                order: order,
                                statusColor:
                                    _getColorForStatus(order.status ?? ""),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DeliveryNoteIdScreen(
                                              dnId: order.name.toString(),
                                            ))));
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Draft':
        return Colors.red;
      case 'On Hold':
        return Colors.orangeAccent;
      case 'To Deliver and Bill':
      case 'To Bill':
      case 'To Deliver':
        return Colors.orange;
      case 'Completed':
      case 'Closed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 80, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No delivery notes found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final DeliverNoteList order;
  final VoidCallback onTap;
  final Color statusColor;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: Colors.white, // ✅ Pure white card
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.6, color: Colors.grey),
              const SizedBox(height: 12),
              _buildDetails(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.name ?? "",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                order.transactionDate ?? "",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            border: Border.all(color: statusColor),
            borderRadius: BorderRadius.circular(50),
          ),
          child: AutoSizeText(
            order.status ?? "",
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailBlock('Customer', order.customerName ?? "", theme,
            maxWidth: 140, icon: Icons.person_outline),
        _buildDetailBlock('Items', '${order.totalQty ?? 0}', theme,
            icon: Icons.inventory_2_outlined),
        _buildDetailBlock(
          'Amount',
          '₹${order.grandTotal?.toStringAsFixed(2) ?? "0.00"}',
          theme,
          icon: Icons.currency_rupee,
          valueStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailBlock(
    String label,
    String value,
    ThemeData theme, {
    TextStyle? valueStyle,
    double? maxWidth,
    IconData? icon,
  }) {
    return SizedBox(
      width: maxWidth ?? 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: valueStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
          ),
        ],
      ),
    );
  }
}
