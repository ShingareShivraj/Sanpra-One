import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'add_retailer_viewmodel.dart';

class RetailerFormView extends StatelessWidget {
  final String retailerId;
  const RetailerFormView({super.key, required this.retailerId});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RetailerFormViewModel>.reactive(
      viewModelBuilder: () => RetailerFormViewModel(),
      onViewModelReady: (model) => model.initializeForm(id: retailerId),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Retailer Form'),
        ),
        body: model.isBusy
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: model.formKey,
                  child: ListView(
                    children: [
                      _buildTextField(
                        controller: model.nameController,
                        label: 'Retailer Name',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter name'
                            : null,
                      ),
                      _buildTextField(
                        controller: model.mobileController,
                        label: 'Mobile',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Enter mobile';
                          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Enter valid 10-digit mobile';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: model.emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Enter email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                              .hasMatch(value)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: model.pinCodeController,
                        label: 'Pincode',
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter pincode'
                            : null,
                      ),
                      _buildTextField(
                        controller: model.cityController,
                        label: 'City',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter city'
                            : null,
                      ),
                      _buildTextField(
                        controller: model.addressController,
                        label: 'Address Line 1',
                        maxLines: 2,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter address'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => model.submitForm(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: validator,
      ),
    );
  }
}
