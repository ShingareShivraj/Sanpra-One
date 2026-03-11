import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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

  Future<void> pickOrCaptureImage({ImageSource source = ImageSource.camera}) async {

    final XFile? photo = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );

    if (photo == null) return;

    File file = fileFromXFile(photo);

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    File labeledImage = await addLocationLabel(
      file,
      pos.latitude,
      pos.longitude,
    );

    selectedImageFile = await compressFile(labeledImage);

    notifyListeners();
  }

  // -------------------- SAVE --------------------
  Future<void> onSavePressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    // ✅ Create: photo required
    final type = (expenseData.expenseType ?? "").toLowerCase();

    if (!isEdit &&
        selectedImageFile == null &&
        type != "car" &&
        type != "bike") {
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
//---------------------------getolocator added by shivraj-----------------------------------

  Future<File> addLocationLabel(
      File imageFile,
      double lat,
      double lng,
      ) async {

    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) return imageFile;

    final time = DateTime.now();

    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemarks.first;

    List<String> parts = [];

    if ((place.subLocality ?? "").isNotEmpty) parts.add(place.subLocality!);
    if ((place.locality ?? "").isNotEmpty) parts.add(place.locality!);
    if ((place.administrativeArea ?? "").isNotEmpty) parts.add(place.administrativeArea!);

    String address = parts.join(", ");

    String label =
        "$address\n"
        "${time.day}-${time.month}-${time.year} ${time.hour}:${time.minute}";

    img.fillRect(
      image,
      x1: 0,
      y1: image.height - 100,
      x2: image.width,
      y2: image.height,
      color: img.ColorRgb8(0, 0, 0),
    );

    img.drawString(
      image,
      label,
      x: 20,
      y: image.height - 80,
      font: img.arial24,
      color: img.ColorRgb8(255, 255, 255),
    );

    final dir = await getTemporaryDirectory();
    final newPath =
        "${dir.path}/expense_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final newFile = File(newPath);
    await newFile.writeAsBytes(img.encodeJpg(image));

    return newFile;
  }

  // -------------------- IMAGE --------------------

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
// Only fetch travel data if this is a travel expense type
    if (isTravelExpense &&
        expenseData.expenseType != null &&
        expenseData.expenseDate != null) {
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
