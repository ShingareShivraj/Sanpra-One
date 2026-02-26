import 'package:flutter/material.dart';
import 'package:geolocation/widgets/text_button.dart';
import 'package:stacked/stacked.dart';

import '../../../widgets/customtextfield.dart';
import '../../../widgets/drop_down.dart';
import 'add_project_lead_viewmodel.dart';

class ProjectLeadFormScreen extends StatelessWidget {
  final String Id;
  const ProjectLeadFormScreen({super.key, required this.Id});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProjectLeadViewModel>.reactive(
      viewModelBuilder: () => ProjectLeadViewModel(),
      onViewModelReady: (model) => model.initialise(context, Id),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Project Lead Form"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: model.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------ DROPDOWN 1
                  CustomDropdownButton2(
                    labelText: "Project",
                    value: model.projectIs,
                    items: model.projectIsList,
                    hintText: "Select Project",
                    onChanged: model.setProjectIs,
                    validator: model.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  // ------------------------------ DROPDOWN 2
                  CustomDropdownButton2(
                    labelText: "Project From",
                    value: model.projectType,
                    items: model.projectTypeList,
                    hintText: "Select Project From",
                    onChanged: model.setProjectType,
                    validator: model.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  // ------------------------------ DROPDOWN 3
                  CustomDropdownButton2(
                    labelText: " Project Plan",
                    value: model.plan,
                    items: model.planList,
                    hintText: "Select Plan",
                    onChanged: model.setPlan,
                    validator: model.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  // ------------------------------ DROPDOWN 4
                  CustomDropdownButton2(
                    labelText: "Project Site Status",
                    value: model.siteStatus,
                    items: model.siteStatusList,
                    hintText: "Select Site Status",
                    onChanged: model.setSiteStatus,
                    validator: model.validateRequired,
                  ),
                  const SizedBox(height: 20),

                  // ------------------------------ TEXT FIELDS
                  CustomSmallTextFormField(
                    controller: model.contactPerson,
                    labelText: "Contact Person",
                    hintText: "Enter name",
                    onChanged: model.onContactPersonChanged,
                    validator: model.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  CustomSmallTextFormField(
                    keyboardtype: TextInputType.number,
                    controller: model.mobileNumber,
                    labelText: "Mobile Number",
                    hintText: "Enter mobile number",
                    onChanged: model.onMobileChanged,
                    validator: model.validateMobile,
                    length: 10,
                  ),
                  const SizedBox(height: 16),

                  CustomSmallTextFormField(
                    controller: model.address,
                    labelText: "Address",
                    hintText: "Enter address",
                    validator: model.validateRequired,
                    onChanged: model.onAddressChanged,
                  ),
                  const SizedBox(height: 16),

                  CustomSmallTextFormField(
                    controller: model.city,
                    labelText: "City",
                    hintText: "Enter city",
                    validator: model.validateRequired,
                    onChanged: model.onCityChanged,
                  ),
                  const SizedBox(height: 16),

                  CustomDropdownButton2(
                    labelText: "Territory",
                    value: model.projectLead.territory,
                    items: model.territories,
                    hintText: "Select Territory",
                    onChanged: model.setTerritory,
                  ),
                  const SizedBox(height: 20),
                  CustomSmallTextFormField(
                    controller: model.state,
                    labelText: "State",
                    hintText: "Enter state",
                    validator: model.validateRequired,
                    onChanged: model.onStateChanged,
                  ),
                  const SizedBox(height: 16),

                  CustomSmallTextFormField(
                    keyboardtype: TextInputType.number,
                    controller: model.pincode,
                    labelText: "Pincode",
                    hintText: "Enter pincode",
                    validator: model.validateRequired,
                    onChanged: model.onPincodeChanged,
                    length: 6,
                  ),
                  CustomSmallTextFormField(
                    controller: model.description,
                    labelText: "Description",
                    hintText: "Enter Description",
                    onChanged: model.onDescriptionChanged,
                    lineLength: 3,
                  ),
                  const SizedBox(height: 24),

                  // ------------------------------ SUBMIT BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CTextButton(
                          onPressed: () => Navigator.pop(context),
                          text: "Cancel",
                          buttonColor: Colors.redAccent),
                      CTextButton(
                          onPressed: () => model.onSavePressed(context),
                          text: "Submit",
                          buttonColor: Colors.blueAccent)
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
