import 'package:flutter/material.dart';
import 'package:geolocation/model/retailer_model.dart';
import 'package:stacked/stacked.dart';

import '../../../services/add_retailer_services.dart';

class RetailerFormViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();
  final _service = RetailerServices();

  // Controllers
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final pinCodeController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();

  bool isUpdateMode = false;
  String? retailerId;

  // Dispose controllers
  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    pinCodeController.dispose();
    cityController.dispose();
    addressController.dispose();
    super.dispose();
  }

  /// Initialize form with data if editing
  Future<void> initializeForm({String? id}) async {
    if (id == null || id.isEmpty) return;

    setBusy(true);
    final existingRetailer = await _service.getRetailer(id);
    if (existingRetailer != null) {
      isUpdateMode = true;
      retailerId = existingRetailer.name;

      nameController.text = existingRetailer.name1 ?? '';
      mobileController.text = existingRetailer.mobile ?? '';
      emailController.text = existingRetailer.email ?? '';
      pinCodeController.text = existingRetailer.pincode?.toString() ?? '';
      cityController.text = existingRetailer.city ?? '';
      addressController.text = existingRetailer.addressLine1 ?? '';
    }
    setBusy(false);
  }

  /// Validate and submit the form
  Future<void> submitForm(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setBusy(true);

    final retailer = Retailer(
      name: retailerId,
      name1: nameController.text.trim(),
      mobile: mobileController.text.trim(),
      email: emailController.text.trim(),
      pincode: int.tryParse(pinCodeController.text.trim()),
      city: cityController.text.trim(),
      addressLine1: addressController.text.trim(),
    );

    final success = isUpdateMode
        ? await _service.updateRetailer(retailer)
        : await _service.addRetailer(retailer);

    setBusy(false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isUpdateMode
              ? 'Retailer updated successfully!'
              : 'Retailer added successfully!'),
        ),
      );
      Navigator.pop(context); // Go back after success
    }
  }
}
