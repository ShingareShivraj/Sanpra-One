import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

import '../../../constants.dart';
import '../../../model/expense_model.dart';
import '../../../services/add_expense_services.dart';

class AddExpenseViewModel extends BaseViewModel {
  /// SERVICES
  final AddExpenseServices _service = AddExpenseServices();
  final Logger _logger = Logger();

  /// CONTROLLERS
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final kmController = TextEditingController(); // for bike/car

  /// FORM
  final formKey = GlobalKey<FormState>();

  /// DATA
  ExpenseData expenseData = ExpenseData();
  List<String> expenseTypes = [];
  DateTime? selectedDate;
  Attachments? attachment; // single attachment
  bool isEdit = false;
  File? selectedImageFile; // newly picked image (for create/edit)
  Attachments? existingAttachment; // existing attachment from API (edit mode)

  // -------------------- TRAVEL EXPENSE --------------------
  bool get isTravelExpense =>
      expenseData.expenseType != null &&
      (expenseData.expenseType!.toLowerCase() == 'bike' ||
          expenseData.expenseType!.toLowerCase() == 'car');

  double? ratePerKm; // fetched from ERP
  double? calculatedAmount;

  // -------------------- INIT --------------------
  Future<void> initialise(BuildContext context, String id) async {
    setBusy(true);
    try {
      expenseTypes = await _service.fetExpenseType();

      if (id.isNotEmpty) {
        isEdit = true;
        expenseData = await _service.getExpense(id) ?? ExpenseData();

        dateController.text = expenseData.expenseDate ?? "";
        amountController.text = expenseData.amount?.toString() ?? "";
        descriptionController.text = expenseData.expenseDescription ?? "";

        ratePerKm = expenseData.rate ?? 0;
        km = expenseData.km ?? 0;
        calculatedAmount = expenseData.amount ?? 0;

        // ✅ keep existing attachment for edit screen
        existingAttachment = (expenseData.attachments != null &&
                expenseData.attachments!.isNotEmpty)
            ? expenseData.attachments!.first
            : null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load expense types');
    }
    setBusy(false);
  }

  Future<void> pickOrCaptureImage(
      {ImageSource source = ImageSource.camera}) async {
    final XFile? photo = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );

    if (photo == null) return;

    selectedImageFile = await compressFile(fileFromXFile(photo));
    notifyListeners();
  }

  // -------------------- SAVE --------------------
  Future<void> onSavePressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    // ✅ Create: photo required
    if (!isEdit && selectedImageFile == null) {
      Fluttertoast.showToast(msg: "Photo is required");
      return;
    }

    setBusy(true);

    try {
      // ✅ Upload only if user picked a NEW image
      if (selectedImageFile != null) {
        final Attachments? uploaded =
            await _service.uploadDocs(selectedImageFile!);

        if (uploaded == null) {
          Fluttertoast.showToast(msg: 'Image upload failed');
          return;
        }

        expenseData.attachments = [uploaded]; // replace / set new
      } else {
        // ✅ Edit mode: keep old attachment if no new image selected
        if (isEdit && existingAttachment != null) {
          expenseData.attachments = [existingAttachment!];
        }
      }

      _logger.i(expenseData.toJson());

      final bool success = isEdit
          ? await _service
              .updateExpense(expenseData) // ✅ create this in service
          : await _service.bookexpense(expenseData); // create

      if (success && context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e, s) {
      _logger.e('Expense save failed', error: e, stackTrace: s);
      Fluttertoast.showToast(msg: 'Something went wrong');
    } finally {
      setBusy(false);
    }
  }

  bool delete = false;
  Future<void> deleteNote(String leaveId, BuildContext context) async {
    if (leaveId.isEmpty) return;

    try {
      final deleted = await _service.delete(leaveId);

      if (deleted) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true)
              .pop(true); // ✅ ALWAYS WORKS
        }
      } else {
        Fluttertoast.showToast(
          msg: "expense cannot be deleted (only Draft leaves allowed)",
        );
      }
    } catch (e, stack) {
      _logger.e('Error deleting leave', error: e, stackTrace: stack);
    }
  }

  // -------------------- IMAGE --------------------
  Future<File?> _captureImage() async {
    final XFile? photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo == null) {
      Fluttertoast.showToast(msg: 'Camera cancelled');
      return null;
    }

    return await compressFile(fileFromXFile(photo));
  }

  // -------------------- DATE --------------------
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    selectedDate = picked;
    final formattedDate = DateFormat('yyyy-MM-dd').format(picked);

    dateController.text = formattedDate;
    expenseData.expenseDate = formattedDate;

    notifyListeners();
  }

  // -------------------- SETTERS --------------------
  void setDescription(String value) {
    expenseData.expenseDescription = value.trim();
  }

  void setAmount(String value) {
    if (!isTravelExpense) {
      expenseData.amount = double.tryParse(value);
    }
  }

  double km = 0;
  void setExpenseType(String? value) async {
    expenseData.expenseType = value;

    // Reset travel-related data first
    ratePerKm = null;
    km = 0;
    calculatedAmount = null;
    amountController.text = '';

    // Only fetch travel data if this is a travel expense type
    if (isTravelExpense && value != null && expenseData.expenseDate != null) {
      setBusy(true);
      try {
        final travelData = await _service.getTravelExpenseData(
          vehicleType: expenseData.expenseType!,
          date: expenseData.expenseDate!,
        );

        if (travelData != null) {
          km = travelData["km"];
          ratePerKm = travelData["ratePerKm"];
          calculatedAmount = travelData["amount"];
          expenseData.km = km;
          expenseData.rate = ratePerKm;
          expenseData.amount = calculatedAmount;
          amountController.text = calculatedAmount?.toStringAsFixed(2) ?? '';
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Failed to fetch travel data");
      } finally {
        setBusy(false);
      }
    }

    notifyListeners();
  }

// Call this when user manually changes KM
  void onKmChanged(String value) {
    _calculateAmount();
    notifyListeners();
  }

  void _calculateAmount() {
    final double? enteredKm = double.tryParse(kmController.text);

    if (enteredKm != null && ratePerKm != null) {
      calculatedAmount = enteredKm * ratePerKm!;
      expenseData.amount = calculatedAmount;
      expenseData.rate = ratePerKm;
      expenseData.km = enteredKm;
      amountController.text = calculatedAmount!.toStringAsFixed(2);
    } else {
      calculatedAmount = null;
      expenseData.amount = null;
      amountController.text = '';
    }
  }

  // -------------------- VALIDATORS --------------------
  String? validateDate(String? value) =>
      value == null || value.isEmpty ? 'Please select date' : null;

  String? validateExpenseType(String? value) =>
      value == null || value.isEmpty ? 'Please select expense type' : null;

  String? validateDescription(String? value) =>
      value == null || value.isEmpty ? 'Please enter description' : null;

  String? validateAmount(String? value) =>
      value == null || value.isEmpty ? 'Please enter amount' : null;

  String? validateKm(String? value) {
    if (isTravelExpense) {
      final km = double.tryParse(value ?? '');
      if (km == null || km <= 0) return 'Enter valid distance';
    }
    return null;
  }

  // -------------------- DISPOSE --------------------
  @override
  void dispose() {
    dateController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    kmController.dispose();
    super.dispose();
  }
}
