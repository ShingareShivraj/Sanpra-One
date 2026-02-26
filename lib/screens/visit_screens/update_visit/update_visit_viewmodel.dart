import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

import '../../../model/add_visit_model.dart';
import '../../../services/add_visit_services.dart';

class UpdateVisitModel extends BaseViewModel {
  AddVisitModel visitData = AddVisitModel();

  /// Initialize visit data for update screen
  Future<void> initialise(BuildContext context, String visitId) async {
    if (visitId.isEmpty) return;

    setBusy(true);
    try {
      visitData = await AddVisitServices().getVisit(visitId) ?? AddVisitModel();
      Logger().i(visitData.toJson());
    } catch (e) {
      debugPrint('UpdateVisitModel initialise error: $e');
    } finally {
      setBusy(false);
    }
  }
}
