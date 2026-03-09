import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'delivery_note_viewmodel.dart';

class DeliveryNoteIdScreen extends StatelessWidget {
  final String dnId;

  const DeliveryNoteIdScreen({
    super.key,
    required this.dnId,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeliveryNoteViewModel>.reactive(
      viewModelBuilder: () => DeliveryNoteViewModel(),
      onViewModelReady: (vm) => vm.initialise(dnId),
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: AppBar(
            title: const Text("Delivery Note"),
            centerTitle: true,
            elevation: 0,
          ),
          body: vm.isBusy
              ? const Center(child: CircularProgressIndicator())
              : vm.deliveryNoteData.name == null
              ? const _NoDataView()
              : _buildBody(context, vm.deliveryNoteData),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DeliveryNote data) {
    final items = data.items ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBannerCard(data: data, dnId: dnId),
          const SizedBox(height: 16),

          _SectionTitle(
            icon: Icons.receipt_long_outlined,
            title: "Summary",
            subtitle: "Delivery information and totals",
          ),
          const SizedBox(height: 12),

          _SummaryCard(data: data),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _HighlightCard(
                  title: "Total Qty",
                  value: _formatNumber(data.totalQty),
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HighlightCard(
                  title: "Grand Total",
                  value: "₹${_formatMoney(data.grandTotal)}",
                  icon: Icons.currency_rupee,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _SectionTitle(
            icon: Icons.local_shipping_outlined,
            title: "Items",
            subtitle: "${items.length} item(s) in this delivery note",
          ),
          const SizedBox(height: 12),

          if (items.isEmpty)
            const _EmptyItemsCard()
          else
            ...List.generate(
              items.length,
                  (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DeliveryNoteItemCard(item: items[index]),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatMoney(dynamic value) {
    if (value == null) return "0.00";
    final number = double.tryParse(value.toString()) ?? 0;
    return number.toStringAsFixed(2);
  }

  static String _formatNumber(dynamic value) {
    if (value == null) return "0";
    final number = double.tryParse(value.toString()) ?? 0;
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}

class _TopBannerCard extends StatelessWidget {
  final DeliveryNote data;
  final String dnId;

  const _TopBannerCard({
    required this.data,
    required this.dnId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dnId,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.customerName ?? "-",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.94),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Posting Date: ${data.postingDate ?? '-'}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.82),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFE8F0FE),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final DeliveryNote data;

  const _SummaryCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            label: "Customer",
            value: data.customerName ?? "-",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: "Posting Date",
            value: data.postingDate ?? "-",
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: "Net Total",
            value: "₹${DeliveryNoteIdScreen._formatMoney(data.netTotal)}",
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: "Grand Total",
            value: "₹${DeliveryNoteIdScreen._formatMoney(data.grandTotal)}",
            icon: Icons.payments_outlined,
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = highlight ? const Color(0xFF059669) : Colors.black87;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.black54,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HighlightCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(.14),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryNoteItemCard extends StatelessWidget {
  final dynamic item;

  const _DeliveryNoteItemCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final qty = double.tryParse((item.qty ?? 0).toString()) ?? 0;
    final rate = double.tryParse((item.rate ?? 0).toString()) ?? 0;
    final amount = double.tryParse((item.amount ?? 0).toString()) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.itemName ?? "",
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ItemInfoChip(
                icon: Icons.scale_outlined,
                label: "Qty",
                value: qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2),
                color: const Color(0xFF2563EB),
              ),
              _ItemInfoChip(
                icon: Icons.currency_rupee,
                label: "Rate",
                value: rate.toStringAsFixed(2),
                color: const Color(0xFFF59E0B),
              ),
              _ItemInfoChip(
                icon: Icons.payments_outlined,
                label: "Amount",
                value: amount.toStringAsFixed(2),
                color: const Color(0xFF059669),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ItemInfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            "$label: $value",
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyItemsCard extends StatelessWidget {
  const _EmptyItemsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 36,
            color: Colors.black38,
          ),
          SizedBox(height: 10),
          Text(
            "No items found",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDataView extends StatelessWidget {
  const _NoDataView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "No data found",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}