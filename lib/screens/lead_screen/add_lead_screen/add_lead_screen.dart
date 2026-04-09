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
    final theme = Theme.of(context);

    return ViewModelBuilder<AddLeadViewModel>.reactive(
      viewModelBuilder: () => AddLeadViewModel(),
      onViewModelReady: (model) => model.initialise(context, widget.leadId),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            model.isEdit ? model.leadData.name.toString() : 'Create Lead',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: model.formKey,
              child: Column(
                children: [
                  _SectionCard(
                    title: "Basic Info",
                    child: Column(
                      children: [
                        CustomSmallTextFormField(
                          prefixIcon: Icons.person,
                          controller: model.firstnameController,
                          labelText: 'Person Name',
                          hintText: 'Person name',
                          onChanged: model.setFirstName,
                          validator: model.validateFirstName,
                        ),
                        const SizedBox(height: 12),
                        CustomSmallTextFormField(
                          prefixIcon: Icons.factory_outlined,
                          controller: model.companyNameController,
                          labelText: 'Organisation Name',
                          hintText: 'Enter the organisation',
                          onChanged: model.setCompany,
                          validator: model.validateCompany,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomDropdownButton2(
                                prefixIcon: Icons.factory_sharp,
                                labelText: 'Category',
                                value: model.leadData.industry,
                                items: model.industryTypes,
                                hintText: 'industry',
                                onChanged: model.setIndustry,
                              ),
                            ),
                            // const SizedBox(width: 5),
                            // Expanded(
                            //   child: CustomDropdownButton2(
                            //     prefixIcon: Icons.type_specimen,
                            //     labelText: 'Lead Type',
                            //     value: model.leadData.marketSegment,
                            //     items: model.types,
                            //     hintText: 'type',
                            //     onChanged: model.setLeadType,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: "Contact",
                    child: Column(
                      children: [
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
                                keyboardtype: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomSmallTextFormField(
                          prefixIcon: EvaIcons.email_outline,
                          controller: model.emailController,
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          onChanged: model.setEmail,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: "Address Details",
                    child: Column(
                      children: [
                        CustomDropdownButton2(
                          labelText: 'Territory',
                          value: model.leadData.territory,
                          prefixIcon: Icons.location_on,
                          items: model.territories,
                          hintText: 'select territory',
                          onChanged: model.setTerritory,
                        ),
                        // const SizedBox(height: 12),
                        // CustomSmallTextFormField(
                        //   prefixIcon: Icons.shopify_outlined,
                        //   controller: model.gstinController,
                        //   labelText: 'GST IN',
                        //   hintText: 'GST IN',
                        //   onChanged: model.setGstin,
                        // ),
                        const SizedBox(height: 12),
                        CustomSmallTextFormField(
                          prefixIcon: Icons.note,
                          controller: model.addressController,
                          labelText: 'Address',
                          hintText: 'Address',
                          onChanged: model.setAddress,
                          validator: model.validateAddress,
                        ),
                        const SizedBox(height: 12),
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomDropdownButton2(
                                labelText: 'State',
                                value: model.leadData.state,
                                items: model.states,
                                hintText: 'select state',
                                onChanged: model.setState,
                                searchController: model.stateController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomSmallTextFormField(
                          prefixIcon: Icons.location_on_outlined,
                          controller: model.pincodeController,
                          labelText: 'Pincode',
                          hintText: 'pincode',
                          onChanged: model.setPincode,
                          validator: model.validatePincode,
                          length: 6,
                          keyboardtype: TextInputType.number,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: "Lead Source",
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomDropdownButton2(
                                labelText: 'Source',
                                value: model.leadData.source,
                                items: model.leadSources,
                                hintText: 'select source',
                                onChanged: model.setSource,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if ((model.leadData.source ?? "")
                                .trim()
                                .toLowerCase() ==
                                "existing customer")
                              Expanded(
                                child: CustomDropdownButton2(
                                  labelText: 'From Customer',
                                  value: model.leadData.customer,
                                  items: model.customers,
                                  hintText: 'select customer',
                                  onChanged: model.setCustomer,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: "Description",
                    child: CustomSmallTextFormField(
                      lineLength: 3,
                      prefixIcon: Icons.description_outlined,
                      controller: model.lastnameController,
                      labelText: 'Description',
                      hintText: 'Description',
                      onChanged: model.setLastName,
                      validator: model.validateLastName,
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// ACTIONS
                  Row(
                    children: [
                      Expanded(
                        child: CTextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          text: 'Cancel',
                          buttonColor: Colors.red.shade500,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CTextButton(
                          onPressed: () => model.onSavePressed(context),
                          text: model.isEdit ? 'Update Lead' : 'Create Lead',
                          buttonColor: Colors.blueAccent.shade400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// OPTIONAL NOTE / UI polish
                  Text(
                    "Tip: Fill basic details first, then contact & address.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ✅ Reusable Section Card
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final border = Colors.black.withOpacity(0.10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}