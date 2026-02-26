import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../widgets/customtextfield.dart';
import '../../../widgets/drop_down.dart';
import '../../../widgets/full_screen_loader.dart';
import '../../../widgets/text_button.dart';
import 'add_attendance_request_viewmodel.dart';

class AddAttendanceRequestScreen extends StatelessWidget {
  const AddAttendanceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AttendanceRequestViewModel>.reactive(
      viewModelBuilder: () => AttendanceRequestViewModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Attendance Request',
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: model.formKey,
                child: Column(
                  children: [
                    /// FROM DATE
                    _dateField(
                      context,
                      label: 'From Date',
                      controller: model.fromDateController,
                      onTap: () => model.selectFromDate(context),
                      validator: model.validateFromDate,
                    ),

                    const SizedBox(height: 12),

                    /// TO DATE
                    _dateField(
                      context,
                      label: 'To Date',
                      controller: model.toDateController,
                      onTap: () => model.selectToDate(context),
                      validator: model.validateToDate,
                    ),

                    const SizedBox(height: 12),

                    /// HALF DAY SWITCH
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Half Day'),
                      value: model.halfDay,
                      onChanged: model.setHalfDay,
                    ),
                    if (model.halfDay == true)
                      _dateField(
                        context,
                        label: 'Half Date',
                        controller: model.halfDateController,
                        onTap: () => model.selectHalfDate(context),
                        validator: model.validateHalfDate,
                      ),
                    const SizedBox(height: 12),

                    /// REASON
                    CustomDropdownButton2(
                      labelText: 'Reason',
                      hintText: 'Select reason',
                      items: model.reasonList,
                      onChanged: model.setReason,
                      validator: model.validateReason,
                    ),

                    const SizedBox(height: 12),

                    /// EXPLANATION
                    CustomSmallTextFormField(
                      controller: model.explanationController,
                      labelText: 'Explanation',
                      hintText: 'Enter explanation',
                      lineLength: 4,
                      validator: model.validateExplanation,
                      onChanged: model.setExplanation,
                    ),

                    const SizedBox(height: 24),

                    /// ACTION BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: CTextButton(
                            text: 'Cancel',
                            buttonColor: Colors.red.shade500,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CTextButton(
                            text: 'Submit',
                            buttonColor: Colors.blueAccent,
                            onPressed: () =>
                                model.submitAttendanceRequest(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// DATE FIELD WIDGET
  Widget _dateField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
