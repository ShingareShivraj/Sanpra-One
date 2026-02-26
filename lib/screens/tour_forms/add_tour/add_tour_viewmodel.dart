import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../model/tour_model.dart';
import '../../../services/add_customer_services.dart';
import '../../../services/tour_services.dart';

class CreateTourViewModel extends BaseViewModel {
  /// MODEL (single source of truth)
  final Tour tour = Tour();

  /// UI DATA
  List<String> areaList = [];

  DateTime? selectedDate;

  /// CONTROLLERS
  final TextEditingController dateController = TextEditingController();
  final TextEditingController callsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  /// INIT
  Future<void> initialise() async {
    setBusy(true);
    try {
      areaList = await AddCustomerServices().fetchTerritory();
      reset();
    } finally {
      setBusy(false);
    }
  }

  /// AREA CHANGE
  void onAreaChanged(String? value) {
    tour.area = value;
    notifyListeners();
  }

  /// TOTAL CALLS CHANGE
  void onCallsChanged(String value) {
    tour.totalCalls = int.tryParse(value) ?? 0;
    notifyListeners();
  }

  void onDescriptionChanged(String value) {
    tour.description = value;
    notifyListeners();
  }

  /// DATE PICKER
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked == null) return;

    selectedDate = picked;
    tour.date = DateFormat('yyyy-MM-dd').format(picked);
    dateController.text = tour.date!;
    notifyListeners();
  }

  /// VALIDATION
  bool get isValid =>
      (tour.area?.isNotEmpty ?? false) &&
      (tour.totalCalls ?? 0) > 0 &&
      tour.date != null;

  /// SUBMIT
  Future<void> submit(BuildContext context) async {
    if (!isValid) return;

    setBusy(true);
    try {
      debugPrint('Create Tour Payload: ${tour.toJson()}');

      final success = await TourServices().addTour(tour);

      if (success) {
        Navigator.pop(context, true);
        reset();
      }
    } finally {
      setBusy(false);
    }
  }

  /// RESET FORM
  void reset() {
    tour
      ..area = null
      ..totalCalls = null
      ..date = null;

    selectedDate = null;
    dateController.clear();
    callsController.clear();
    descriptionController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    dateController.dispose();
    callsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
