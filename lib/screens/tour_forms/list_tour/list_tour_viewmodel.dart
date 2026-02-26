import 'package:flutter/material.dart';
import 'package:geolocation/model/tour_model.dart';
import 'package:stacked/stacked.dart';

import '../../../services/tour_services.dart';

class ListTourViewModel extends BaseViewModel {
  /// Visit list
  List<Tour> visitList = [];
  bool res = false;

  /// Initial load
  Future<void> initialise(BuildContext context) async {
    setBusy(true);

    try {
      visitList = await TourServices().fetchTours();
    } catch (e) {
      visitList = [];
      debugPrint("Visit fetch error: $e");
    }

    setBusy(false);
    notifyListeners();
  }

  /// Row click
  // void onRowClick(BuildContext context, AddVisitModel visit) {
  //   Navigator.pushNamed(
  //     context,
  //     Routes.updateVisitScreen,
  //     arguments: UpdateVisitScreenArguments(
  //       updateId: visit.name ?? "",
  //     ),
  //   );
  // }

  Future<void> deleteTour(String? id, BuildContext context) async {
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Tour ID')),
      );
      return;
    }

    if (isBusy) return; // prevent double call

    setBusy(true);

    try {
      final bool isDeleted = await TourServices().deleteTour(id);

      if (isDeleted) {
        // ✅ Remove locally instead of refetch
        visitList.removeWhere((e) => e.name == id);
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tour deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete tour'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete tour $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setBusy(false);
    }
  }

  /// Refresh
  Future<void> refresh(BuildContext context) async {
    await initialise(context);
  }
}
