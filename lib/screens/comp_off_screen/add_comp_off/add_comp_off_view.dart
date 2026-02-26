import 'package:flutter/material.dart';
import 'package:geolocation/widgets/drop_down.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:geolocation/widgets/text_button.dart';
import 'package:stacked/stacked.dart';

import '../../../widgets/customtextfield.dart';
import 'add_comp_off_viewmodel.dart';

class AddCompOffView extends StatelessWidget {
  final String leaveId;

  const AddCompOffView({super.key, required this.leaveId});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddCompOffViewmodel>.reactive(
      viewModelBuilder: () => AddCompOffViewmodel(),
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
              leaveId.isEmpty ? 'Create Comp off' : 'Comp Off Details',
              style: const TextStyle(fontSize: 18),
            ),
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
                              decoration: _inputDecoration('Work From Date'),
                              validator: model.validateDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: model.toDateController,
                              readOnly: true,
                              onTap: () => model.selectToDate(context),
                              decoration: _inputDecoration('Work End Date'),
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
                                    ? 'Create Comp off'
                                    : 'Update Comp off',
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
