import 'package:flutter/material.dart';
import 'package:geolocation/widgets/drop_down.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:geolocation/widgets/text_button.dart';
import 'package:stacked/stacked.dart';

import '../../../widgets/customtextfield.dart';
import 'add_leave_viewmodel.dart';

class AddLeaveScreen extends StatelessWidget {
  final String leaveId;

  const AddLeaveScreen({super.key, required this.leaveId});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddLeaveViewModel>.reactive(
      viewModelBuilder: () => AddLeaveViewModel(),
      onViewModelReady: (model) => model.initialise(context, leaveId),
      builder: (context, model, child) {
        /// 🔐 EDITABLE LOGIC
        final bool isEditable =
            model.leaveData.docstatus == 0 || model.leaveData.docstatus == null;
        print(model.leaveData.docstatus);
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: Text(
              leaveId.isEmpty ? 'Create Leave' : 'Leave Details',
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              if (isEditable)
                IconButton.outlined(
                  onPressed: () async {
                    final pageContext = context; // ✅ save screen context

                    await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text(
                            "Delete Leave?",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                              "Are you sure you want to delete this Leave?"),
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
                                model.deleteNote(leaveId,
                                    pageContext); // ✅ PASS PAGE CONTEXT
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
              absorbing: !isEditable, // 🔥 MAIN LOCK
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: model.formKey,
                  child: Column(
                    children: [
                      /// FROM + TO DATE
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: model.fromDateController,
                              readOnly: true,
                              onTap: () => model.selectFromDate(context),
                              decoration: _inputDecoration('From Date'),
                              validator: model.validateDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: model.toDateController,
                              readOnly: true,
                              onTap: () => model.selectToDate(context),
                              decoration: _inputDecoration('To Date'),
                              validator: model.validateDate,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      /// LEAVE TYPE
                      CustomDropdownButton2(
                        value: model.leaveData.leaveType,
                        items: model.leaveTypes,
                        hintText: 'Select leave type',
                        labelText: 'Leave Type',
                        onChanged: model.setLeaveType,
                      ),

                      const SizedBox(height: 15),

                      /// HALF DAY SWITCH
                      SwitchListTile(
                        value: model.isHalfDay,
                        onChanged: model.toggleHalfDay,
                        title: const Text('Half Day'),
                        subtitle: const Text('Enable if leave is for half day'),
                      ),

                      /// HALF DAY DATE
                      if (model.leaveData.halfDay == 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: TextFormField(
                            controller: model.halfDayController,
                            readOnly: true,
                            onTap: () => model.selectHalfDayDate(context),
                            decoration: _inputDecoration('Half Day Date'),
                          ),
                        ),

                      /// DESCRIPTION
                      CustomSmallTextFormField(
                        controller: model.descriptionController,
                        labelText: 'Reason',
                        hintText: 'Enter leave reason',
                        validator: model.validateDescription,
                        onChanged: model.setDescription,
                      ),

                      const SizedBox(height: 25),

                      /// ACTION BUTTONS / INFO
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
                                text: leaveId.isEmpty
                                    ? 'Create Leave'
                                    : 'Update Leave',
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
                            'This leave is already submitted and cannot be edited.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// COMMON INPUT DECORATION
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.calendar_today),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
