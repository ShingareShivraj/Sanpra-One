import 'package:flutter/material.dart';
import 'package:geolocation/screens/tour_forms/add_tour/add_tour_viewmodel.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';

import '../../../widgets/customtextfield.dart';
import '../../../widgets/drop_down.dart';
import '../../../widgets/text_button.dart';

class CreateTourScreen extends StatelessWidget {
  const CreateTourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateTourViewModel>.reactive(
      viewModelBuilder: () => CreateTourViewModel(),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Create Tour'),
          centerTitle: true,
        ),
        body: fullScreenLoader(
          context: context,
          loader: model.isBusy,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// AREA
                CustomDropdownButton2(
                  value: model.tour.area,
                  items: model.areaList,
                  hintText: 'Select Area',
                  labelText: "Area *",
                  onChanged: model.onAreaChanged,
                ),
                const SizedBox(height: 16),

                /// DATE
                TextFormField(
                  readOnly: true,
                  controller: model.dateController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 12.0),
                    labelText: 'Tour date',
                    hintText: 'Tour Date',
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
                        borderSide:
                            BorderSide(color: Colors.black45, width: 2)),
                  ),
                  onTap: () => model.pickDate(context),
                ),

                const SizedBox(height: 16),
                CustomSmallTextFormField(
                  length: 6,
                  controller: model.callsController,
                  labelText: 'Total Calls',
                  keyboardtype: TextInputType.number,
                  hintText: "Enter Calls",
                  onChanged: model.onCallsChanged,
                ),
                const SizedBox(height: 16),

                CustomSmallTextFormField(
                  lineLength: 3,
                  controller: model.descriptionController,
                  labelText: 'Description',
                  hintText: "Description",
                  onChanged: model.onDescriptionChanged,
                ),
                const SizedBox(height: 30),

                /// SUBMIT
                Row(
                  children: [
                    /// Cancel Button
                    Expanded(
                      child: CTextButton(
                        text: 'Cancel',
                        buttonColor: Colors.red.shade400,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    // spacing
                    // HIDE Accept for distributor
                    Expanded(
                      child: CTextButton(
                        text: 'Create Tour',
                        buttonColor: Colors.blueAccent.shade400,
                        onPressed: () {
                          model.submit(context);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
