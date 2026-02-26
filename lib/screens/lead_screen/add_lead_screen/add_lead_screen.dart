import 'package:flutter/material.dart';
import 'package:geolocation/screens/lead_screen/add_lead_screen/add_lead_viewmodel.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:geolocation/widgets/text_button.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:stacked/stacked.dart';

import '../../../widgets/customtextfield.dart';
import '../../../widgets/drop_down.dart';

class AddLeadScreen extends StatefulWidget {
  final String leadId;
  const AddLeadScreen({super.key, required this.leadId});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddLeadViewModel>.reactive(
        viewModelBuilder: () => AddLeadViewModel(),
        onViewModelReady: (model) => model.initialise(context, widget.leadId),
        builder: (context, model, child) => Scaffold(
              appBar: AppBar(
                title: Text(
                  model.isEdit ? model.leadData.name.toString() : 'Create Lead',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              body: fullScreenLoader(
                loader: model.isBusy,
                context: context,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: model.formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: CustomSmallTextFormField(
                                prefixIcon: Icons.person,
                                controller: model.firstnameController,
                                labelText: 'Person Name',
                                hintText: 'Person name',
                                onChanged: model.setFirstName,
                                validator: model.validateFirstName,
                              )),
                              // const SizedBox(
                              //   width: 15,
                              // ),
                              // Expanded(
                              //     child: CustomSmallTextFormField(
                              //   prefixIcon: Icons.person,
                              //   controller: model.lastnameController,
                              //   labelText: 'Last Name',
                              //   hintText: 'last name',
                              //   onChanged: model.setLastName,
                              //   validator: model.validateLastName,
                              // )),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomSmallTextFormField(
                            prefixIcon: Icons.factory_outlined,
                            controller: model.companyNameController,
                            labelText: 'Organisation Name',
                            hintText: 'Enter the organisation',
                            onChanged: model.setCompany,
                            validator: model.validateCompany,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomDropdownButton2(
                            prefixIcon: Icons.factory_sharp,
                            labelText: 'Category',
                            value: model.leadData.industry,
                            items: model.industryTypes,
                            hintText: 'select industry',
                            onChanged: model.setIndustry,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomSmallTextFormField(
                                    prefixIcon: Icons.phone,
                                    controller: model.mobileNumberController,
                                    labelText: 'Mobile Number',
                                    hintText: 'mobile number',
                                    onChanged: model.setMobile,
                                    validator: model.validateMobile,
                                    length: 10,
                                    keyboardtype: TextInputType.phone),
                              ),
                              // const SizedBox(
                              //   width: 15,
                              // ),
                              // Expanded(
                              //   child: CustomSmallTextFormField(
                              //     prefixIcon: Bootstrap.whatsapp,
                              //     controller: model.whatsappController,
                              //     labelText: 'WhatsApp Number',
                              //     hintText: 'whatsapp number',
                              //     onChanged: model.setWhatsapp,
                              //     validator: model.validateMobile,
                              //     length: 10,
                              //     keyboardtype: TextInputType.phone,
                              //   ),
                              // )
                            ],
                          ),
                          CustomSmallTextFormField(
                            prefixIcon: EvaIcons.email_outline,
                            controller: model.emailController,
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            onChanged: model.setEmail,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomDropdownButton2(
                            labelText: 'Territory',
                            value: model.leadData.territory,
                            prefixIcon: Icons.location_on,
                            items: model.territories,
                            hintText: 'select territory',
                            onChanged: model.setTerritory,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomSmallTextFormField(
                            prefixIcon: Icons.shopify_outlined,
                            controller: model.gstinController,
                            labelText: 'GST IN',
                            hintText: 'GST IN',
                            onChanged: model.setGstin,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomSmallTextFormField(
                            prefixIcon: Icons.note,
                            controller: model.addressController,
                            labelText: 'Address',
                            hintText: 'Address',
                            onChanged: model.setAddress,
                            validator: model.validateAddress,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomSmallTextFormField(
                                  prefixIcon: Icons.location_on,
                                  controller: model.cityController,
                                  labelText: 'City',
                                  hintText: 'Enter the City',
                                  onChanged: model.setCity,
                                  validator: model.validateCity,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: CustomDropdownButton2(
                                  labelText: 'State',
                                  value: model.leadData.state..toString,
                                  items: model.states,
                                  hintText: 'select state',
                                  onChanged: model.setState,
                                  searchController: model.stateController,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomSmallTextFormField(
                              prefixIcon: Icons.location_on_outlined,
                              controller: model.pincodeController,
                              labelText: 'Pincode',
                              hintText: 'pincode',
                              onChanged: model.setPincode,
                              validator: model.validatePincode,
                              length: 6,
                              keyboardtype: TextInputType.number),
                          const SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomDropdownButton2(
                                  labelText: 'Source',
                                  value: model.leadData.source..toString,
                                  items: model.leadSources,
                                  hintText: 'select source',
                                  onChanged: model.setSource,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              if (model.leadData.source == "Existing Customer")
                                Expanded(
                                  child: CustomDropdownButton2(
                                    labelText: 'From Customer',
                                    value: model.leadData.customer..toString,
                                    items: model.customers,
                                    hintText: 'select customer',
                                    onChanged: model.setCustomer,
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomSmallTextFormField(
                            lineLength: 3,
                            prefixIcon: Icons.person,
                            controller: model.lastnameController,
                            labelText: 'Description',
                            hintText: 'Description',
                            onChanged: model.setLastName,
                            validator: model.validateLastName,
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                  child: CTextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                text: 'Cancel',
                                buttonColor: Colors.red.shade500,
                              )),
                              SizedBox(width: 20),
                              Expanded(
                                child: CTextButton(
                                  onPressed: model.selectedImage == null &&
                                          model.isEdit == false
                                      ? () => model.pickPhoto(fromCamera: true)
                                      : () => model.onSavePressed(context),
                                  text: model.isEdit
                                      ? 'Update Lead'
                                      : model.selectedImage == null
                                          ? 'Add Photo'
                                          : 'Create Lead',
                                  buttonColor: Colors.blueAccent.shade400,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }
}
