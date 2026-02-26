import 'package:flutter/material.dart';
import 'package:geolocation/widgets/drop_down.dart';
import 'package:geolocation/widgets/text_button.dart';
import 'package:stacked/stacked.dart';

import '../../../services/add_project_lead_services.dart';
import '../../../widgets/customtextfield.dart';
import 'add_marketing_viewmodel.dart';

class MarketingFormScreen extends StatelessWidget {
  final String Id;
  const MarketingFormScreen({super.key, required this.Id});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddMarketingViewmodel>.reactive(
      viewModelBuilder: () => AddMarketingViewmodel(),
      onViewModelReady: (vm) => vm.init(Id),
      builder: (context, vm, _) {
        final bool isApproved = vm.isApproved;
        print(vm.issue.workflowState);
        print(isApproved);
        return Scaffold(
          backgroundColor: Colors.grey.shade100,

          /// ================= APP BAR =================
          appBar: AppBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.isEdit
                      ? (vm.issue.name?.toString() ?? "Merchandise")
                      : "Merchandise",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                _workflowChip(vm.issue.workflowState)
              ],
            ),
            backgroundColor: Colors.blueAccent,
            elevation: 1,
          ),

          /// ================= BODY =================
          body: vm.isBusy
              ? const Center(child: CircularProgressIndicator())
              : AbsorbPointer(
                  absorbing: isApproved,
                  child: Opacity(
                    opacity: isApproved ? 0.75 : 1,
                    child: Form(
                      key: vm.formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            /// ================= CUSTOMER =================
                            _sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionTitle("Customer Details"),
                                  CustomDropdownButton2(
                                    value: vm.issue.customer,
                                    prefixIcon: Icons.person_outline,
                                    items: vm.customer,
                                    hintText: "Select customer",
                                    onChanged: vm.setCustomer,
                                    labelText: "Customer",
                                    validator: (v) =>
                                        v == null ? "Required" : null,
                                  ),
                                ],
                              ),
                            ),

                            /// ================= ITEMS =================
                            _sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: _SectionTitle("Issued Items"),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _showItemSheet(context, vm),
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text("Add"),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  if ((vm.issue.items ?? const <Items>[])
                                      .isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Center(
                                        child: Text(
                                          "No items added",
                                          style: TextStyle(
                                              color: Colors.grey.shade600),
                                        ),
                                      ),
                                    ),

                                  // ✅ Tap item to Edit (no swipe / no dismiss)
                                  ...((vm.issue.items ?? const <Items>[])
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    final merch =
                                        vm.getMerchandiseByCode(item.itemCode);

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => _showItemSheet(context, vm,
                                          editIndex: index),
                                      child: _ItemTile(
                                        name: item.itemName ?? '',
                                        qty:
                                            "${item.qtyGiven ?? 0} ${merch?.uom ?? ''}",
                                      ),
                                    );
                                  })),
                                ],
                              ),
                            ),

                            /// ================= TOTAL =================
                            _sectionCard(
                              child: TextFormField(
                                controller: vm.totalQtyController,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: "Total Quantity",
                                  prefixIcon:
                                      const Icon(Icons.calculate_outlined),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),

                            /// ================= REMARKS =================
                            _sectionCard(
                              child: CustomSmallTextFormField(
                                lineLength: 3,
                                prefixIcon: Icons.notes_outlined,
                                controller: vm.descriptionController,
                                labelText: 'Remarks',
                                hintText: 'Additional notes',
                                onChanged: vm.setRemark,
                              ),
                            ),

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

          /// ================= BOTTOM ACTIONS =================
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isApproved
                  ? const SizedBox()
                  : CTextButton(
                      onPressed: () => vm.onSavePressed(context),
                      text: vm.isEdit ? "Update" : "Save",
                      buttonColor: Colors.blue,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _workflowChip(String? state) {
    final label = state ?? "Draft";

    Color bgColor;
    Color textColor;

    switch (label) {
      case "Approved":
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case "Rejected":
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case "Pending":
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ===================================================
  // ADD / EDIT ITEM BOTTOM SHEET
  // ===================================================
  void _showItemSheet(
    BuildContext context,
    AddMarketingViewmodel vm, {
    int? editIndex,
  }) {
    MerchandiseItems? selectedItem;
    final qtyController = TextEditingController(text: "1");

    if (editIndex != null) {
      final item = vm.issue.items![editIndex];
      selectedItem = vm.getMerchandiseByCode(item.itemCode);
      qtyController.text = (item.qtyGiven ?? 1).toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent, // ✅ for rounded container
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> confirmDelete() async {
              final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Delete Item"),
                      content: Text(
                        "Are you sure you want to delete "
                        "${vm.issue.items![editIndex!].itemName ?? "this item"}?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (!ok) return;
              vm.removeItem(editIndex!);
              Navigator.pop(context);
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.58, // ✅ opens mid
              minChildSize: 0.45,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      10,
                      16,
                      MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController, // ✅ sheet scroll
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✅ drag handle
                          Container(
                            width: 42,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  editIndex == null
                                      ? "Add Item"
                                      : "Update Item",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: "Close",
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          DropdownButtonFormField<MerchandiseItems>(
                            isExpanded: true,
                            value: selectedItem,
                            items: vm.items.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.itemName ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setSheetState(() => selectedItem = v),
                            decoration: _filledInput("Item"),
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            decoration: _filledInput("Quantity"),
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              if (editIndex != null) ...[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(
                                          color: Colors.redAccent),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    onPressed: confirmDelete,
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text("Delete"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blueAccent,
                                    side: const BorderSide(
                                        color: Colors.blueAccent),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  onPressed: () {
                                    if (selectedItem == null) return;

                                    vm.addOrUpdateItemFromSheet(
                                      selectedItem: selectedItem!,
                                      qty:
                                          double.tryParse(qtyController.text) ??
                                              0,
                                      editIndex: editIndex,
                                    );

                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.update_outlined),
                                  label: Text(
                                      editIndex == null ? "Add" : "Update"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// ================= HELPERS =================

InputDecoration _filledInput(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

Widget _sectionCard({required Widget child}) {
  return Card(
    elevation: 1.5,
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String name;
  final String qty;

  const _ItemTile({required this.name, required this.qty});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  qty,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined),
        ],
      ),
    );
  }
}
