import 'package:flutter/material.dart';
import 'package:geolocation/model/add_visit_model.dart';
import 'package:geolocation/services/list_visit_service.dart';
import 'package:stacked/stacked.dart';

import '../../../router.router.dart';

class VisitViewModel extends BaseViewModel {
  /// Visit list
  List<AddVisitModel> visitList = [];

  /// Initial load
  Future<void> initialise(BuildContext context) async {
    setBusy(true);

    try {
      visitList = await ListVisitServices().fetchVisit();
    } catch (e) {
      visitList = [];
      debugPrint("Visit fetch error: $e");
    }

    setBusy(false);
    notifyListeners();
  }

  /// Row click
  void onRowClick(BuildContext context, AddVisitModel visit) {
    Navigator.pushNamed(
      context,
      Routes.updateVisitScreen,
      arguments: UpdateVisitScreenArguments(
        updateId: visit.name ?? "",
      ),
    );
  }

  /// Refresh
  Future<void> refresh(BuildContext context) async {
    await initialise(context);
  }
}
