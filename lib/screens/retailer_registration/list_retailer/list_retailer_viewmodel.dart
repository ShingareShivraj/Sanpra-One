import 'package:flutter/material.dart';
import 'package:geolocation/model/retailer_model.dart';
import 'package:stacked/stacked.dart';

import '../../../services/add_retailer_services.dart';

class RetailerListViewModel extends BaseViewModel {
  final _service = RetailerServices();

  List<Retailer> _retailers = [];
  List<Retailer> get retailers => _retailers;

  Future<void> fetchRetailers() async {
    setBusy(true);
    try {
      final response =
          await _service.getAllRetailers(); // You need to implement this
      _retailers = response;
    } catch (e) {
      debugPrint('Error fetching retailers: $e');
    }
    setBusy(false);
  }
}
