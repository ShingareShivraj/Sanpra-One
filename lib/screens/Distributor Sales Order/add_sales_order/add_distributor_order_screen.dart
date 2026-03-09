import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';

import '../../../constants.dart';
import '../../../model/add_order_model.dart';
import '../../../router.router.dart';
import '../../../widgets/drop_down.dart';
import '../../../widgets/text_button.dart';
import 'add_order_viewmodel.dart';

class AddDistributorOrderScreen extends StatefulWidget {
  final String orderId;
  const AddDistributorOrderScreen({super.key, required this.orderId});
  @override
  State<AddDistributorOrderScreen> createState() => _AddDistributorOrderScreenState();
}

class _AddDistributorOrderScreenState extends State<AddDistributorOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddDistributorOrderViewModel>.reactive(
      viewModelBuilder: () => AddDistributorOrderViewModel(),
      onViewModelReady: (model) => model.initialise(context, widget.orderId),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(model.isEdit == true
                ? model.orderData.name ?? ""
                : 'Create Order'),
            actions: [
              if (model.orderData.docstatus ==
                  1) // Only show for submitted orders
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delivery_note') {
                      Navigator.pushNamed(
                        context,
                        Routes.deliveryNoteScreen,
                        arguments: DeliveryNoteScreenArguments(orderData: model.orderData),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {

                      return const [
                        PopupMenuItem<String>(
                          value: 'delivery_note',
                          child: Text('Delivery Note'),
                        ),
                      ];
                    }
                ),
            ],
          ),
          body: WillPopScope(
            onWillPop: () async {
              Navigator.pop(context);
              return true;
            },
            child: fullScreenLoader(
              loader: model.isBusy,
              context: context,
              child: SingleChildScrollView(
                child: AbsorbPointer(
                  absorbing: model.orderData.docstatus == 1 ||
                      model.orderData.docstatus == 2,
                  child: Form(
                    key: model.formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          WarehouseDropdown(model: model),
                          const SizedBox(height: 15),
                          CustomerDropdown(model: model),
                          const SizedBox(height: 15),
                          OrderTypeAndDeliveryDateRow(model: model),
                          const SizedBox(height: 15),
                          ItemsSelector(model: model),
                          const SizedBox(height: 5),
                          const Text(
                            'Item List',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          SelectedItemList(model: model),
                          const SizedBox(height: 8),
                          BillingSection(model: model),
                          const SizedBox(height: 25),
                          if (model.orderData.docstatus != 2)
                            ActionButtons(model: model),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String actionText,
    required Future<bool> Function() onConfirm, // returns success/fail
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true); // close dialog first
                await onConfirm(); // async action
              },
              child: Text(
                actionText,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}

// Individual smaller widget examples

class CustomerDropdown extends StatelessWidget {
  final AddDistributorOrderViewModel model;
  const CustomerDropdown({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDropdownButton2(
      value: model.orderData.customer,
      prefixIcon: Icons.person_2,
      items: model.customerNames,
      hintText: 'Select the customer',
      labelText: 'Customer',
      onChanged: model.setCustomer,
    );
  }
}

class OrderTypeAndDeliveryDateRow extends StatelessWidget {
  final AddDistributorOrderViewModel model;
  const OrderTypeAndDeliveryDateRow({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded(
        //   flex: 1,
        //   child: CustomDropdownButton2(
        //     items: model.orderTypes,
        //     hintText: 'order type',
        //     onChanged: model.setOrderType,
        //     labelText: 'Order Type',
        //     value: model.orderData.orderType,
        //   ),
        // ),
        // const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: TextFormField(
            readOnly: true,
            controller: model.deliveryDateController,
            onTap: () => model.selectDeliveryDate(context),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              labelText: 'Delivery date',
              hintText: 'Delivery Date',
              prefixIcon: const Icon(Icons.calendar_today_rounded),
              labelStyle: const TextStyle(
                color: Colors.black54,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              hintStyle: const TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.blue, width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey, width: 2)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.black45, width: 2)),
            ),
            validator: model.validateDeliveryDate,
          ),
        ),
      ],
    );
  }
}

class WarehouseDropdown extends StatelessWidget {
  final AddDistributorOrderViewModel model;
  const WarehouseDropdown({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDropdownButton2(
      prefixIcon: Icons.warehouse_outlined,
      items: model.warehouses,
      hintText: 'select the distributor',
      onChanged: model.setWarehouse,
      labelText: 'Set Distributor',
      value: model.orderData.setWarehouse,
    );
  }
}

class ItemsSelector extends StatelessWidget {
  final AddDistributorOrderViewModel model;
  const ItemsSelector({required this.model, super.key});

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      key: Key(model.displayString),
      initialValue: model.displayString,
      onTap: () async {
        if (model.orderData.customer == null ||
            model.orderData.setWarehouse == null) {
          _showSnackBar(context, "Please select the customer and warehouse");
          return;
        }

        final selectedItems = await Navigator.pushNamed(
          context,
          Routes.itemScreen,
          arguments: ItemScreenArguments(
            warehouse: model.orderData.setWarehouse ?? "",
            items: model.items,
            selectedItems: model.selectedItems,
          ),
        ) as List<Items>?;

        if (selectedItems != null) {
          model.setSelectedItems(selectedItems);
        }
      },
      decoration: InputDecoration(
        labelText: 'Items',
        hintText: 'Click here to select items',
        prefixIcon: const Icon(Icons.shopping_basket),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        labelStyle: const TextStyle(
            color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}

class SelectedItemList extends StatefulWidget {
  final AddDistributorOrderViewModel model;
  const SelectedItemList({required this.model, super.key});

  @override
  State<SelectedItemList> createState() => _SelectedItemListState();
}

class _SelectedItemListState extends State<SelectedItemList> {
  Future<bool> _confirmDelete() async {
    if (!mounted) return false;
    return await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Delete Item?"),
            content: const Text("Are you sure you want to delete this item?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text("No")),
              TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text("Yes")),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    if (model.selectedItems.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Items are not selected',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: model.selectedItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final selectedItem = model.selectedItems[index];
        return Dismissible(
          key: Key(selectedItem.itemCode.toString()),
          background: Container(
            color: Colors.red.shade400,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.delete_forever_outlined,
                color: Colors.white, size: 36),
          ),
          direction: DismissDirection.startToEnd,
          confirmDismiss: (_) => _confirmDelete(),
          onDismissed: (_) => model.deleteItem(index),
          child:
              SelectedItemCard(item: selectedItem, model: model, index: index),
        );
      },
    );
  }
}

class SelectedItemCard extends StatelessWidget {
  final Items item;
  final AddDistributorOrderViewModel model;
  final int index;

  const SelectedItemCard({
    required this.item,
    required this.model,
    required this.index,
    super.key,
  });

  TextStyle get _titleStyle => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      );

  TextStyle get _smallBold => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      );

  TextStyle get _smallGrey => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      );

  Widget _statusStrip(double delivered, double pending) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Delivered: ${delivered.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Pending: ${pending.toStringAsFixed(2)}",
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(
    TextEditingController controller, {
    required Function(String) onChanged,
    double width = 70,
    String? suffix,
  }) {
    return SizedBox(
      width: width,
      height: 34,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          filled: true,
          fillColor: Colors.white,
          suffixText: suffix,
          suffixStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.20)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black54),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qtyController = model.getQuantityController(index);
    final discountController = model.getDiscountController(index);

    final deliveredQty = (item.deliveredQty ?? 0).toDouble();
    final orderedQty = (item.qty ?? 0).toDouble();
    final pendingQty =
        (orderedQty - deliveredQty).clamp(0, double.infinity).toDouble();

    final rate = (item.rate ?? 0).toDouble();

    final discountAmount =
        ((item.discountAmount ?? 0) + (item.distributedDiscountAmount ?? 0))
            .toDouble();
    final total = (item.netAmount ?? (item.amount));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
      ),
      child: Column(
        children: [
          /// TOP STRIP

          /// BODY
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: '$baseurl${item.image}',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox(
                      width: 52,
                      height: 52,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Image.asset(
                      'assets/images/image.png',
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                /// Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Name + Rate (same row)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (item.itemName ?? "N/A").toUpperCase(),
                              style: _titleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Rate: ${rate.toStringAsFixed(2)}",
                            style: _smallBold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      /// Qty + Disc boxes row (like screenshot)
                      Row(
                        children: [
                          Text("Qty", style: _smallGrey),
                          const SizedBox(width: 8),
                          _box(
                            qtyController,
                            width: 70,
                            onChanged: (v) {
                              final parsed = int.tryParse(v);
                              if (parsed != null) {
                                model.setItemQuantity(index, parsed);
                              }
                            },
                          ),
                          const SizedBox(width: 14),
                          Text("Disc %", style: _smallGrey),
                          const SizedBox(width: 8),
                          _box(
                            discountController,
                            width: 80,
                            onChanged: (v) {
                              final parsed = double.tryParse(v);
                              if (parsed != null) {
                                model.setItemDiscount(index, parsed);
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// Net like screenshot (2 lines)
                      Text(
                        "Amount: ${total?.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Disc Amt: Rs. ${discountAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                        ),
                      ),

                      /// (Optional) If you still want gross line:
                      // const SizedBox(height: 6),
                      // Text("Gross: Rs. ${gross.toStringAsFixed(2)}", style: _smallGrey),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.black.withOpacity(0.10)),

          /// BOTTOM STRIP (same as screenshot)
          _statusStrip(deliveredQty, pendingQty),
        ],
      ),
    );
  }
}

class BillingSection extends StatelessWidget {
  final AddDistributorOrderViewModel model;
  const BillingSection({required this.model, super.key});

  String _money(num? v) => (v ?? 0).toStringAsFixed(2);

  Widget _discountInput(
    TextEditingController controller, {
    required Function(String) onChanged,
  }) {
    return SizedBox(
      width: 90,
      height: 34,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          filled: true,
          fillColor: Colors.white,
          suffixText: "%",
          suffixStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.20)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black54),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = Colors.black.withOpacity(0.12);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tax and Discount",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: border),
          const SizedBox(height: 12),
          _row("Subtotal :", _money(model.orderData.netTotal)),
          const SizedBox(height: 10),
          _row("Total Tax :", _money(model.orderData.totalTaxesAndCharges)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Order Disc %",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              _discountInput(
                model.orderDiscountController,
                onChanged: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) model.setOrderDiscountPercent(parsed);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          _row("Discount :", _money(model.orderData.discountAmount),
              valueColor: Colors.redAccent),
          const SizedBox(height: 12),
          Divider(height: 1, color: border),
          const SizedBox(height: 12),
          _row(
            "Total :",
            _money(model.orderData.grandTotal),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 15,
            fontWeight: FontWeight.w800,
            color: valueColor ?? (isTotal ? Colors.black : Colors.black87),
          ),
        ),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  final AddDistributorOrderViewModel model;
  const ActionButtons({required this.model, super.key});

  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = model.orderData;

    return Row(
      children: [
        /// Cancel Button
        // Expanded(
        //   child: CTextButton(
        //     text: 'Cancel',
        //     buttonColor: Colors.red.shade400,
        //     onPressed: () {
        //       if (order.docstatus == 1) {
        //         _showConfirmationDialog(
        //           context: context,
        //           title: "Are you sure?",
        //           content: "This will permanently cancel the order.",
        //           onConfirm: () => model.onCancelPressed(context),
        //         );
        //       } else {
        //         Navigator.of(context).pop();
        //       }
        //     },
        //   ),
        // ),

// spacing
//         if (order.docstatus == 0 || order.docstatus == null)
//           const SizedBox(width: 20),

        /// Action Button (Create / Update / Accept)
        if ((order.docstatus == 0 || order.docstatus == null) &&
            !(model.isSame &&
                model.role?.toLowerCase() ==
                    "distributor")) // HIDE Accept for distributor
          Expanded(
            child: CTextButton(
              text: model.isSame
                  ? 'Submit Order'
                  : (model.isEdit ? 'Update Order' : 'Create Order'),
              buttonColor: Colors.blueAccent.shade400,
              onPressed: () {
                if (model.isSame) {
                  _showConfirmationDialog(
                    context: context,
                    title: "Confirm Submit?",
                    content: "Do you want to permanently submit this order?",
                    onConfirm: () => model.onSubmitPressed(context),
                  );
                } else {
                  model.onSavePressed(context);
                }
              },
            ),
          ),
      ],
    );
  }
}
