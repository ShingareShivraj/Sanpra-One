import 'package:flutter/material.dart';
import 'package:geolocation/services/add_project_lead_services.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

import '../../../model/project_details.dart';
import '../../../model/project_lead_model.dart';

class ProjectLeadViewModel extends BaseViewModel {
  // -------------------------
  // FORM KEY
  // -------------------------
  final formKey = GlobalKey<FormState>();
  ProjectLead projectLead = ProjectLead();
  final _logger = Logger();
  final _service = ProjectLeadService();

  // -------------------------
  // TEXT CONTROLLERS
  // -------------------------
  final contactPerson = TextEditingController();
  final mobileNumber = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final pincode = TextEditingController();
  final description = TextEditingController();

  // -------------------------
  // ADD / EDIT FLAGS
  // -------------------------
  bool isEdit = false; // true = edit
  String name = ""; // docname for edit
  bool isSubmitted = false;
  ProjectLeadDetails details = ProjectLeadDetails();
  // -------------------------
  // DROPDOWNS
  // -------------------------
  String? projectIs;
  String? projectType;
  String? plan;
  String? siteStatus;

  List<String> projectIsList = ["Residential", "Commercial", "Industrial"];
  List<String> projectTypeList = [];
  List<String> planList = [];
  List<String> siteStatusList = [];
  List<String> territories = [];
  // -------------------------
  // INITIALISE (FOR EDIT MODE)
  // -------------------------
  Future<void> initialise(BuildContext context, String leadId) async {
    setBusy(true);

    try {
      // Fetch dropdown master data
      details = await _service.leadDetails() ?? details;

      territories = (details.territory ?? []).cast<String>();
      projectTypeList = (details.projectLeadType ?? []).cast<String>();
      planList = (details.projectPlan ?? []).cast<String>();
      siteStatusList = (details.siteStatus ?? []).cast<String>();

      // If leadId is null → NEW mode
      if (leadId.isEmpty) {
        isEdit = false;
        setBusy(false);
        return;
      }

      // EDIT mode
      isEdit = true;
      name = leadId;

      // Fetch data for editing
      projectLead = await _service.getProjectLead(leadId) ?? ProjectLead();

      // Assign to text controllers
      contactPerson.text = projectLead.contactPerson ?? "";
      mobileNumber.text = projectLead.mobileNumber ?? "";
      address.text = projectLead.address ?? "";
      city.text = projectLead.city ?? "";
      state.text = projectLead.state ?? "";
      pincode.text = projectLead.pincode ?? "";

      // Assign dropdown values
      projectIs = projectLead.projectIs;
      projectType = projectLead.projectType;
      plan = projectLead.plan;
      siteStatus = projectLead.siteStatus;

      notifyListeners();
    } catch (e) {
      print("Error in initialise(): $e");
    }

    setBusy(false);
  }

  // -------------------------
  // SET METHODS FOR CONTROLLERS (onChange)
  // -------------------------
  void onContactPersonChanged(String value) {
    projectLead.contactPerson = value;
    notifyListeners();
  }

  void onMobileChanged(String value) {
    projectLead.mobileNumber = value;
    notifyListeners();
  }

  void onDescriptionChanged(String value) {
    projectLead.description = value;
    notifyListeners();
  }

  void onAddressChanged(String value) {
    projectLead.address = value;
    notifyListeners();
  }

  void onCityChanged(String value) {
    projectLead.city = value;
    notifyListeners();
  }

  void onStateChanged(String value) {
    projectLead.state = value;
    notifyListeners();
  }

  void onPincodeChanged(String value) {
    projectLead.pincode = value;
    notifyListeners();
  }

  // -------------------------
  // SET METHODS FOR DROPDOWNS
  // -------------------------
  void setProjectIs(String? value) {
    projectIs = value;
    projectLead.projectIs = value;
    notifyListeners();
  }

  void setProjectType(String? value) {
    projectType = value;
    projectLead.projectType = value;
    notifyListeners();
  }

  void setPlan(String? value) {
    plan = value;
    projectLead.plan = value;
    notifyListeners();
  }

  void setSiteStatus(String? value) {
    siteStatus = value;
    projectLead.siteStatus = value;
    notifyListeners();
  }

  void setTerritory(String? value) {
    projectLead.territory = value;
    notifyListeners();
  }

  // -------------------------
  // VALIDATORS
  // -------------------------
  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter Mobile Number";
    if (value.length != 10) return "Enter valid 10-digit number";
    return null;
  }

  // -------------------------
  // SAVE BUTTON ACTION
  // -------------------------
  Future<void> onSavePressed(BuildContext context) async {
    if (isSubmitted) return;

    if (!formKey.currentState!.validate()) return;

    setBusy(true);

    try {
      if (isEdit) {
        await _submitEditLead(context);
      } else {
        await _submitNewLead(context);
      }

      // 🔥 Pop only when successful
      Navigator.pop(context, true);
    } catch (e) {
      _showToast(context, "Error while saving lead", isError: true);
    }

    notifyListeners();
    setBusy(false);
  }

// -------------------------
// ADD NEW LEAD
// -------------------------
  Future<void> _submitNewLead(BuildContext context) async {
    await _service.addProjectLead(projectLead);
    _showToast(context, "Lead Created Successfully");
    isSubmitted = true;
  }

// -------------------------
// UPDATE EXISTING LEAD
// -------------------------
  Future<void> _submitEditLead(BuildContext context) async {
    await _service.updateProjectLead(projectLead);
    _showToast(context, "Lead Updated Successfully");
    isSubmitted = true;
  }

  // -------------------------
  // TOAST
  // -------------------------
  void _showToast(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
