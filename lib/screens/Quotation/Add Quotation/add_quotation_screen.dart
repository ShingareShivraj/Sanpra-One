import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../constants.dart';
import '../../../model/addquotation_model.dart';
import '../../../router.router.dart';
import '../../../widgets/customtextfield.dart';
import '../../../widgets/drop_down.dart';
import '../../../widgets/full_screen_loader.dart';
import '../../../widgets/text_button.dart';
import 'add_quotation_viewmodel.dart';

class AddQuotationView extends StatefulWidget {
  final String quotationid;

  const AddQuotationView({super.key, required this.quotationid});

  @override
  State<AddQuotationView> createState() => _AddQuotationViewState();
}

class _AddQuotationViewState extends State<AddQuotationView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddQuotationModel>.reactive(
      viewModelBuilder: () => AddQuotationModel(),
      onViewModelReady: (model) => model.initialise(context, widget.quotationid),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Text(
              model.isEdit ? (model.quotationdata.name ?? "Quotation") : "Create Quotation",
            ),
          ),
          body: fullScreenLoader(
            loader: model.isBusy,
            context: context,
            child: Form(
              key: model.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _buildHeaderCard(model),
                    const SizedBox(height: 16),
                    _buildPartyCard(context, model),
                    const SizedBox(height: 16),
                    _buildItemsSelector(context, model),
                    const SizedBox(height: 16),
                    _buildItemsList(model),
                    const SizedBox(height: 16),
                    _buildBillingSection(model),
                    const SizedBox(height: 24),
                    _buildBottomActions(context, model),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(AddQuotationModel model) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Quotation Details"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomDropdownButton2(
                  value: model.quotationdata.quotationTo,
                  prefixIcon: Icons.person_2_outlined,
                  items: model.quotationto,
                  hintText: 'quote to',
                  labelText: 'Quotation To',
                  onChanged: model.setquotationto,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:TextFormField(
                  readOnly: true,
                  controller: model.validtilldatecontroller,
                  onTap: () => model.selectvalidtillDate(context),
                  decoration: _decoration(
                    label: 'Valid Till Date',
                    hint: 'Select valid till date',
                    icon: Icons.calendar_today_rounded,
                  ),
                  validator: model.validateValidTill,
                  onChanged: model.onvalidtillDobChanged,
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildPartyCard(BuildContext context, AddQuotationModel model) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Party Information"),
          const SizedBox(height: 16),
          CustomDropdownButton2(
            value: model.quotationdata.partyName,
            prefixIcon: Icons.groups_2_outlined,
            items: model.searchcustomer,
            hintText: 'Select ${model.customerLabel.toLowerCase()}',
            labelText: model.customerLabel,
            onChanged: model.setcustomer,
            validator: model.validateQuotationTo,
          ),
          if (model.isEdit) ...[
            const SizedBox(height: 16),
            CustomSmallTextFormField(
              prefixIcon: Icons.badge_outlined,
              controller: model.customernamecontroller,
              labelText: 'Party Name',
              hintText: 'Enter party name',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsSelector(BuildContext context, AddQuotationModel model) {
    return _card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          if (model.quotationdata.partyName == null ||
              model.quotationdata.partyName!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  'Please select the customer name',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            );
            return;
          }

          final result = await Navigator.pushNamed(
            context,
            Routes.quotationItemScreen,
            arguments: QuotationItemScreenArguments(items: model.selectedItems),
          ) as List<Items>?;

          if (result != null) {
            model.setSelectedItems(result);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(2),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shopping_basket_outlined,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      model.displayString,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(AddQuotationModel model) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Item List"),
          const SizedBox(height: 8),

          if (model.selectedItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                'Items are not selected',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            )
          else
            ListView.separated(
              itemCount: model.selectedItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final selectedItem = model.selectedItems[index];

                return Dismissible(
                  key: ValueKey(selectedItem.itemCode ?? index.toString()),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction != DismissDirection.startToEnd) return false;

                    return await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete Item"),
                        content: const Text("Remove this item?"),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text("Yes"),
                          ),
                        ],
                      ),
                    ) ??
                        false;
                  },
                  onDismissed: (_) => model.deleteitem(index),

                  /// Compact Card
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        /// Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: '$baseurl${selectedItem.image ?? ""}',
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                            const Icon(Icons.image_not_supported, size: 30),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// Item info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedItem.itemName ?? "Item",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "₹ ${selectedItem.rate ?? 0}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Quantity Stepper
                        Container(
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                            Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: () =>
                                    model.removeitem(index),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  model
                                      .getQuantity(selectedItem)
                                      .toInt()
                                      .toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () => model.additem(index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBillingSection(AddQuotationModel model) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Tax & Summary"),
          const SizedBox(height: 14),
          _billRow("Subtotal", model.quotationdata.netTotal),
          const SizedBox(height: 10),
          _billRow("Total Tax", model.quotationdata.totalTaxesAndCharges),
          const SizedBox(height: 10),
          _billRow("Discount", model.quotationdata.discountAmount),
          const Divider(height: 24),
          _billRow(
            "Grand Total",
            model.quotationdata.grandTotal,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, AddQuotationModel model) {
    if (quotationStatus == 2) {
      return const SizedBox.shrink();
    }

    final canShowPrimary =
        quotationStatus == 0 || model.quotationdata.docstatus == null;

    return Row(
      children: [
        Expanded(
          child: CTextButton(
            text: 'Cancel',
            onPressed: () async {
              if (quotationStatus == 1) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Are you sure?"),
                    content: const Text("Permanently cancel quotation?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Yes"),
                      ),
                    ],
                  ),
                ) ??
                    false;

                if (confirm) {
                  model.onCancelPressed(context);
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            buttonColor: Colors.red.shade400,
          ),
        ),
        if (canShowPrimary) ...[
          const SizedBox(width: 14),
          Expanded(
            child: CTextButton(
              text: model.isSame
                  ? 'Submit'
                  : (model.isEdit ? 'Update' : 'Create'),
              onPressed: () async {
                if (!model.isSame) {
                  model.onSavePressed(context);
                  return;
                }

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Confirm Submit?"),
                    content: const Text("Permanently submit quotation?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Confirm"),
                      ),
                    ],
                  ),
                ) ??
                    false;

                if (confirm) {
                  model.onSubmitPressed(context);
                }
              },
              buttonColor: Colors.blueAccent.shade400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    );
  }

  Widget _billRow(String label, num? value, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: isBold ? 16 : 15,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: isBold ? Colors.black : Colors.grey.shade800,
    );

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text("₹ ${(value ?? 0).toStringAsFixed(2)}", style: style),
      ],
    );
  }
}

class _QuotationItemCard extends StatelessWidget {
  final Items item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final int quantity;

  const _QuotationItemCard({
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6ECF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: '${baseurl}${item.image ?? ""}',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox(
                width: 72,
                height: 72,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
              ),
              errorWidget: (_, __, ___) => Image.asset(
                'assets/images/image.png',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName ?? "N/A",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                AutoSizeText(
                  'UOM: ${item.uom ?? "-"}',
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    Text(
                      'Rate: ₹${(item.rate ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Amount: ₹${(item.amount ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.shade200),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: quantity > 1 ? onRemove : null,
                        icon: const Icon(Icons.remove, color: Colors.blueAccent),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        onPressed: onAdd,
                        icon: const Icon(Icons.add, color: Colors.blueAccent),
                      ),
                    ],
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
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}