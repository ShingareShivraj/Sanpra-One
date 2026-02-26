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

class AddOrderScreen extends StatefulWidget {
  final String orderid;
  const AddOrderScreen({super.key, required this.orderid});
  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddOrderViewModel>.reactive(
      viewModelBuilder: () => AddOrderViewModel(),
      onViewModelReady: (model) => model.initialise(context, widget.orderid),
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
                    if (value == 'close_order') {
                      await showConfirmationDialog(
                        context: context,
                        title: 'Close Order',
                        message: 'Are you sure you want to close this order?',
                        actionText: 'Close Order',
                        onConfirm: () => model.closeNewOrder(context),
                      );
                    }

                    if (value == 'open_order') {
                      await showConfirmationDialog(
                        context: context,
                        title: 'Re-Open Order',
                        message: 'Are you sure you want to re-open this order?',
                        actionText: 'Re-Open Order',
                        onConfirm: () => model.openNewOrder(context),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    // Show Re-Open only if status is 'Closed'
                    // Show Close only if status is NOT 'Closed'
                    if (model.orderData.status?.toLowerCase() == 'closed') {
                      return const [
                        PopupMenuItem<String>(
                          value: 'open_order',
                          child: Text('Re-Open'),
                        ),
                      ];
                    } else {
                      return const [
                        PopupMenuItem<String>(
                          value: 'close_order',
                          child: Text('Close'),
                        ),
                      ];
                    }
                  },
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
  final AddOrderViewModel model;
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
  final AddOrderViewModel model;
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
  final AddOrderViewModel model;
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
  final AddOrderViewModel model;
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

class SelectedItemList extends StatelessWidget {
  final AddOrderViewModel model;
  const SelectedItemList({required this.model, super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Item?"),
            content: const Text("Are you sure you want to delete this item?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes")),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
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
          confirmDismiss: (_) => _confirmDelete(context),
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
  final AddOrderViewModel model;
  final int index;

  const SelectedItemCard({
    required this.item,
    required this.model,
    required this.index,
    super.key,
  });

  Widget _buildInfoText(String label, String value, {Color? color}) {
    return Text(
      "$label: $value",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? Colors.black,
      ),
    );
  }

  Widget _buildQtyBox(TextEditingController controller) {
    return SizedBox(
      width: 50,
      height: 32,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(6),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          final parsed = int.tryParse(value);
          if (parsed != null && parsed > 0) {
            model.setItemQuantity(index, parsed);
          }
        },
      ),
    );
  }

  Widget _buildRateBox(TextEditingController controller) {
    return SizedBox(
      width: 70,
      height: 32,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(6),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          final parsed = double.tryParse(value);
          if (parsed != null && parsed > 0) {
            model.setItemRate(index, parsed);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qtyController = model.getQuantityController(index);
    final rateController = model.getRateController(index);

    final deliveredQty = item.deliveredQty ?? 0;
    final orderedQty = item.qty ?? 0;
    final pendingQty = (orderedQty - deliveredQty).clamp(0, double.infinity);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top row: image + details + qty + rate
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: '$baseurl${item.image}',
                  width: 60,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (_, __, ___) =>
                      Image.asset('assets/images/image.png', scale: 5),
                ),
              ),
              const SizedBox(width: 10),

              /// Item info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName ?? "N/A",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Text("Rate: ",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        _buildRateBox(rateController),
                      ],
                    ),
                    _buildInfoText(
                      "Amt",
                      "₹ ${(item.amount ?? 0).toStringAsFixed(2)}",
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              /// Qty Box
              Column(
                children: [
                  const Text('Qty',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  _buildQtyBox(qtyController),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(),

          /// Delivered & Pending
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoText("Delivered", deliveredQty.toStringAsFixed(2),
                  color: Colors.green),
              _buildInfoText("Pending", pendingQty.toStringAsFixed(2),
                  color: Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class BillingSection extends StatelessWidget {
  final AddOrderViewModel model;
  const BillingSection({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tax and Discount',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          const Divider(thickness: 2),
          buildBillingRow(
              'Subtotal :', model.orderData.netTotal?.toString() ?? '0.0'),
          const SizedBox(height: 10),
          buildBillingRow('Total Tax :',
              model.orderData.totalTaxesAndCharges?.toString() ?? '0.0'),
          const SizedBox(height: 10),
          buildBillingRow('Discount :',
              model.orderData.discountAmount?.toString() ?? '0.0'),
          const Divider(thickness: 2),
          buildBillingRow(
              'Total :', model.orderData.grandTotal?.toString() ?? '0.0'),
        ],
      ),
    );
  }

  Widget buildBillingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16.0)),
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  final AddOrderViewModel model;
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
