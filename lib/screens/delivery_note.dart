import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../model/add_order_model.dart';
import 'delivery_note_viewmodel.dart';

class DeliveryNoteScreen extends StatefulWidget {
  final AddOrderModel orderData;

  const DeliveryNoteScreen({
    super.key,
    required this.orderData,
  });

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
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: AppBar(
            title: const Text('Delivery Note'),
            centerTitle: true,
            elevation: 0,
          ),
          body: vm.isBusy
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _DeliverySummaryCard(vm: vm),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: "Items",
                  subtitle: "${vm.items.length} item(s) in delivery",
                  icon: Icons.inventory_2_outlined,
                ),
                const SizedBox(height: 12),
                if (vm.items.isEmpty)
                  const _EmptyItemsCard()
                else
                  ...List.generate(
                    vm.items.length,
                        (index) {
                      final item = vm.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DeliveryItemCard(
                          item: item,
                          onQtyChanged: (val) => vm.updateQty(index, val),
                          onRemove: () => vm.removeItem(index),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                _BillingSummaryCard(model: vm),
              ],
            ),
          ),
          bottomNavigationBar: _BottomActionBar(
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: () => vm.submit(context),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
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
            "No items available",
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

/// ---------------- TOP SUMMARY ----------------
class _DeliverySummaryCard extends StatelessWidget {
  final DeliveryNoteViewModel vm;

  const _DeliverySummaryCard({
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.20),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Delivery Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoTile(
            icon: Icons.person_outline,
            label: "Customer",
            value: vm.orderData.customer ?? "-",
            valueColor: Colors.white,
            iconColor: Colors.white,
            labelColor: Colors.white70,
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.calendar_today_outlined,
            label: "Date",
            value: vm.orderData.deliveryDate ?? "-",
            valueColor: Colors.white,
            iconColor: Colors.white,
            labelColor: Colors.white70,
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.warehouse_outlined,
            label: "Warehouse",
            value: vm.orderData.setWarehouse ?? "-",
            valueColor: Colors.white,
            iconColor: Colors.white,
            labelColor: Colors.white70,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------- ITEM CARD ----------------
class _DeliveryItemCard extends StatelessWidget {
  final Items item;
  final ValueChanged<String> onQtyChanged;
  final VoidCallback onRemove;

  const _DeliveryItemCard({
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qty = (item.qty ?? 0).toDouble();
    final rate = (item.rate ?? 0).toDouble();
    final total = qty * rate;
    final actualQty = (item.actualQty ?? 0).toDouble();
    final inStock = actualQty > 0;
    final exceedsStock = qty > actualQty && actualQty >= 0;

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
          /// top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.itemName ?? "Item",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// stock + rate chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ValueChip(
                icon: Icons.currency_rupee,
                label: "Rate",
                value: rate.toStringAsFixed(2),
                color: const Color(0xFF10B981),
              ),
              _ValueChip(
                icon: Icons.inventory_2_outlined,
                label: "Available",
                value: actualQty.toStringAsFixed(0),
                color: inStock ? const Color(0xFF2563EB) : Colors.redAccent,
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// qty + total
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: qty.toStringAsFixed(2),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    hintText: "Enter qty",
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: onQtyChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Amount",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (exceedsStock) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Entered quantity exceeds available stock",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ValueChip({
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
          Icon(icon, size: 16, color: color),
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

/// ---------------- BILLING ----------------
class _BillingSummaryCard extends StatelessWidget {
  final DeliveryNoteViewModel model;

  const _BillingSummaryCard({
    required this.model,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text(
                'Billing Summary',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BillingRow(
            'Subtotal',
            model.orderData.netTotal?.toString() ?? '0.0',
          ),
          const SizedBox(height: 12),
          _BillingRow(
            'Total Tax',
            model.orderData.totalTaxesAndCharges?.toString() ?? '0.0',
          ),
          const SizedBox(height: 12),
          _BillingRow(
            'Discount',
            model.orderData.discountAmount?.toString() ?? '0.0',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          _BillingRow(
            'Grand Total',
            model.orderData.grandTotal?.toString() ?? '0.0',
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _BillingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _BillingRow(
      this.label,
      this.value, {
        this.highlight = false,
      });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFF059669) : Colors.black87;
    final fontSize = highlight ? 18.0 : 15.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          "₹$value",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// ---------------- BOTTOM ACTIONS ----------------
class _BottomActionBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _BottomActionBar({
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Submit Delivery Note",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}