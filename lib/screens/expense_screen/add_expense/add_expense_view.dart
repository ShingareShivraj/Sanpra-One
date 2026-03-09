import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocation/widgets/drop_down.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:geolocation/widgets/text_button.dart';
import 'package:stacked/stacked.dart';

import '../../../widgets/customtextfield.dart';
import '../../../widgets/view_docs_from_internet.dart';
import 'add_expense_viewmodel.dart';

class AddExpenseScreen extends StatefulWidget {
  final String expenseId;
  const AddExpenseScreen({super.key, required this.expenseId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddExpenseViewModel>.reactive(
      viewModelBuilder: () => AddExpenseViewModel(),
      onViewModelReady: (model) => model.initialise(context, widget.expenseId),
      builder: (context, model, child) {
        final bool isEditable = model.expenseData.docstatus == 0 ||
            model.expenseData.docstatus == null;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              model.isEdit ? 'Edit Expense' : 'Create Expense',
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              if (isEditable && widget.expenseId.isNotEmpty)
                IconButton(
                  onPressed: () async {
                    final pageContext = context;

                    await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text(
                            "Delete Expense?",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                              "Are you sure you want to delete this Expense?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                model.deleteNote(widget.expenseId, pageContext);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                ),
            ],
          ),
          body: fullScreenLoader(
            loader: model.isBusy,
            context: context,
            child: AbsorbPointer(
              absorbing: !isEditable,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: model.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------------- DATE ----------------
                        TextFormField(
                          readOnly: true,
                          controller: model.dateController,
                          onTap: () => model.selectDate(context),
                          decoration: InputDecoration(
                            labelText: 'Expense Date',
                            prefixIcon:
                                const Icon(Icons.calendar_today_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          validator: model.validateDate,
                        ),

                        const SizedBox(height: 12),

                        // ---------------- TYPE ----------------
                        CustomDropdownButton2(
                          value: model.expenseData.expenseType,
                          items: model.expenseTypes,
                          hintText: 'Select expense type',
                          labelText: 'Expense Type',
                          onChanged: model.setExpenseType,
                          validator: model.validateExpenseType,
                        ),

                        const SizedBox(height: 12),

                        // ---------------- DESCRIPTION ----------------
                        CustomSmallTextFormField(
                          controller: model.descriptionController,
                          labelText: 'Expense Description',
                          hintText: 'Enter description',
                          validator: model.validateDescription,
                          onChanged: model.setDescription,
                        ),

                        const SizedBox(height: 12),

                        if (model.isTravelExpense) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _infoItem(
                                  label: 'Rate / KM',
                                  value: model.ratePerKm != null
                                      ? '₹${model.ratePerKm!.toStringAsFixed(2)}'
                                      : '-',
                                ),
                              ),
                              Expanded(
                                child: _infoItem(
                                  label: 'KM',
                                  value: model.km.toStringAsFixed(2),
                                ),
                              ),
                              Expanded(
                                child: _infoItem(
                                  label: 'Amount',
                                  value: model.calculatedAmount != null
                                      ? '₹${model.calculatedAmount!.toStringAsFixed(2)}'
                                      : '-',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        // ---------------- AMOUNT ----------------
                        CustomSmallTextFormField(
                          controller: model.amountController,
                          labelText: 'Amount',
                          hintText: 'Enter amount',
                          keyboardtype: TextInputType.number,
                          validator: model.validateAmount,
                          onChanged: model.setAmount,
                          readOnly: model.isTravelExpense,
                        ),

                        const SizedBox(height: 12),

                        // ---------------- ATTACHMENTS ----------------
                        _attachmentPickerSection(model, isEditable),

                        const SizedBox(height: 24),

                        // ---------------- ACTION BUTTONS ----------------
                        if (isEditable)
                          Row(
                            children: [
                              Expanded(
                                child: CTextButton(
                                  text: 'Cancel',
                                  buttonColor: Colors.redAccent,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CTextButton(
                                  text: widget.expenseId.isEmpty
                                      ? 'Create Expense'
                                      : 'Update Expense',
                                  buttonColor: Colors.blueAccent,
                                  onPressed: () => model.onSavePressed(context),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'This Expense is already submitted and cannot be edited.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        if (isEditable)
                          const Text(
                            "📸 Camera will open automatically after clicking Create Expense. (Photo not required for Car or Bike expenses)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
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

  // ---------------- ATTACHMENT PICKER SECTION ----------------
  Widget _attachmentPickerSection(AddExpenseViewModel model, bool isEditable) {
    final attachments = model.expenseData.attachments ?? [];
    final hasServerAttachment =
        attachments.isNotEmpty && (attachments.first.fileUrl ?? "").isNotEmpty;
    final hasLocalImage = model.selectedImageFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Attachments",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            if (isEditable)
              TextButton.icon(
                onPressed: () => model.pickOrCaptureImage(),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: Text(model.isEdit ? "Change" : "Add"),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Create requirement hint
        if (!model.isEdit && !hasLocalImage && !hasServerAttachment)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Photo is required to create an expense.",
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),

        if (hasLocalImage) ...[
          const SizedBox(height: 10),
          _localAttachmentPreview(model.selectedImageFile!),
        ] else if (hasServerAttachment) ...[
          const SizedBox(height: 10),
          _serverAttachmentsPreviewList(model),
        ],
      ],
    );
  }

  // Local picked image preview
  Widget _localAttachmentPreview(File file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: Image.file(file, fit: BoxFit.cover),
      ),
    );
  }

  // Server attachments preview list with dialog close button
  Widget _serverAttachmentsPreviewList(AddExpenseViewModel model) {
    final attachments = model.expenseData.attachments ?? [];
    if (attachments.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final url = attachments[index].fileUrl ?? "";
          if (url.isEmpty) return const SizedBox.shrink();

          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) => Dialog(
                  insetPadding: const EdgeInsets.all(14),
                  backgroundColor: Colors.transparent,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          color: Colors.white,
                          child: ViewImageInternet(url: url),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 76,
                height: 76,
                child: ViewImageInternet(url: url),
              ),
            ),
          );
        },
      ),
    );
  }

  // Info item widget
  Widget _infoItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
