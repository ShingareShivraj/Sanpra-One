import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import '../model/add_order_model.dart';
import 'delivery_note_viewmodel.dart';

// ─── Theme Constants ───────────────────────────────────────────────────────────

class _C {
  static const primary     = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1E3A8A);
  static const bg          = Color(0xFFF0F4FF);
  static const surface     = Colors.white;
  static const border      = Color(0xFFDBEAFE);
  static const borderLight = Color(0xFFBFDBFE);
  static const tint        = Color(0xFFEFF6FF);
  static const textHead    = Color(0xFF1E3A8A);
  static const textMuted   = Color(0xFF93C5FD);
  static const green       = Color(0xFF059669);
  static const greenBg     = Color(0xFFD1FAE5);
  static const greenBorder = Color(0xFF86EFAC);
  static const red         = Color(0xFFDC2626);
  static const redBg       = Color(0xFFFEE2E2);
  static const redBorder   = Color(0xFFFCA5A5);
}

// ─── Screen ────────────────────────────────────────────────────────────────────

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
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
          child: Scaffold(
            backgroundColor: _C.bg,
            appBar: _buildAppBar(context),
            body: vm.isBusy
                ? const Center(
                child: CircularProgressIndicator(color: _C.primary))
                : SafeArea(
              child: ListView(
                padding:
                const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  _DeliverySummaryCard(vm: vm),
                  const SizedBox(height: 14),
                  _SectionHeader(
                    title: "Items",
                    trailing:
                    "${vm.items.length} item(s)",
                  ),
                  const SizedBox(height: 10),
                  if (vm.items.isEmpty)
                    const _EmptyItems()
                  else
                    ...List.generate(
                      vm.items.length,
                          (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DeliveryItemCard(
                          item: vm.items[i],
                          onQtyChanged: (v) => vm.updateQty(i, v),
                          onRemove: () => vm.removeItem(i),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  _BillingSummaryCard(model: vm),
                ],
              ),
            ),
            bottomNavigationBar: _BottomActionBar(
              onCancel: () => Navigator.of(context).pop(),
              onSubmit: () => vm.submit(context),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _C.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.border),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: _C.primary, size: 22),
          ),
        ),
      ),
      title: const Text(
        "Delivery note",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _C.textHead,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _C.textHead,
          ),
        ),
        const Spacer(),
        Text(
          trailing,
          style: const TextStyle(
            fontSize: 12,
            color: _C.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Empty Items ───────────────────────────────────────────────────────────────

class _EmptyItems extends StatelessWidget {
  const _EmptyItems();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: const [
          Icon(Icons.inbox_outlined, size: 36, color: _C.borderLight),
          SizedBox(height: 8),
          Text(
            "No items available",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: _C.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Delivery Summary Card ─────────────────────────────────────────────────────

class _DeliverySummaryCard extends StatelessWidget {
  final DeliveryNoteViewModel vm;

  const _DeliverySummaryCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined,
                  color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                "Delivery details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.person_outline_rounded,
            label: "Customer",
            value: vm.orderData.customer ?? "—",
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.calendar_today_outlined,
            label: "Date",
            value: vm.orderData.deliveryDate ?? "—",
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.warehouse_outlined,
            label: "Warehouse",
            value: vm.orderData.setWarehouse ?? "—",
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white60),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            fontSize: 12.5,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Delivery Item Card ────────────────────────────────────────────────────────
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
    final qty         = (item.qty ?? 0).toDouble();
    final rate        = (item.rate ?? 0).toDouble();
    final total       = qty * rate;
    final actualQty   = (item.actualQty ?? 0).toDouble();
    final exceedsStock = qty > actualQty && actualQty >= 0;

    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header: icon + name + delete ──
          Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEFF6FF)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _C.tint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.borderLight),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      size: 16, color: _C.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName ?? "Item",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textHead,
                        ),
                      ),
                      if ((item.itemCode ?? "").isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.itemCode!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _C.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _C.redBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _C.redBorder),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: _C.red,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Chips: rate + stock ──
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEFF6FF)),
              ),
            ),
            child: Row(
              children: [
                _Chip(
                  icon: Icons.currency_rupee_rounded,
                  label: "Rate: ${rate.toStringAsFixed(0)}",
                  color: _C.green,
                  bg: _C.greenBg,
                ),
                const SizedBox(width: 8),
                _Chip(
                  icon: Icons.inventory_2_outlined,
                  label: "Stock: ${actualQty.toStringAsFixed(0)}",
                  color: actualQty > 0 ? _C.primary : _C.red,
                  bg: actualQty > 0 ? _C.tint : _C.redBg,
                ),
              ],
            ),
          ),

          // ── Qty input + Amount display ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quantity",
                        style: TextStyle(
                          fontSize: 11,
                          color: _C.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: qty.toStringAsFixed(2),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textHead,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _C.tint,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: _C.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: _C.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: _C.primary, width: 1.5),
                          ),
                        ),
                        onChanged: onQtyChanged,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Amount",
                        style: TextStyle(
                          fontSize: 11,
                          color: _C.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: _C.greenBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _C.greenBorder),
                        ),
                        child: Text(
                          "₹${total.toStringAsFixed(2)}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _C.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Exceeds stock warning ──
          if (exceedsStock)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _C.redBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.redBorder),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 14, color: _C.red),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Quantity exceeds available stock",
                      style: TextStyle(
                        color: _C.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
// ─── Billing Summary ───────────────────────────────────────────────────────────

class _BillingSummaryCard extends StatelessWidget {
  final DeliveryNoteViewModel model;

  const _BillingSummaryCard({required this.model});

  String _fmt(num? v) => (v ?? 0).toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 16, color: _C.primary),
              SizedBox(width: 8),
              Text(
                "Billing summary",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.textHead,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _C.tint, height: 1),
          const SizedBox(height: 14),
          _BillingRow(label: "Subtotal",
              value: "₹${_fmt(model.orderData.netTotal)}"),
          const SizedBox(height: 10),
          _BillingRow(label: "Total Tax",
              value: "₹${_fmt(model.orderData.totalTaxesAndCharges)}"),
          const SizedBox(height: 10),
          _BillingRow(label: "Discount",
              value: "- ₹${_fmt(model.orderData.discountAmount)}",
              valueColor: _C.red),
          const SizedBox(height: 14),
          const Divider(color: _C.tint, height: 1),
          const SizedBox(height: 14),
          _BillingRow(
            label: "Grand Total",
            value: "₹${_fmt(model.orderData.grandTotal)}",
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _BillingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _BillingRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14.5 : 13.5,
              fontWeight:
              isTotal ? FontWeight.w700 : FontWeight.w500,
              color: _C.textHead,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13.5,
            fontWeight: FontWeight.w700,
            color: valueColor ??
                (isTotal ? _C.green : _C.textHead),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Action Bar ─────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _BottomActionBar({
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: _C.surface,
        border: Border(top: BorderSide(color: _C.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Cancel
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded,
                    size: 16, color: _C.red),
                label: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: _C.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _C.redBorder),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Submit
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.check_rounded,
                      size: 18, color: Colors.white),
                  label: const Text(
                    "Submit delivery note",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _C.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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