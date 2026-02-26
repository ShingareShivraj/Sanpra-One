import 'package:flutter/material.dart';
import 'package:geolocation/model/add_retailer_sale_model.dart';
import 'package:stacked/stacked.dart';

import '../../../services/add_retailer_sale_services.dart';

class RetailerSaleListViewModel extends BaseViewModel {
  final _service = RetailerSaleService();

  List<RetailerSale> _retailers = [];
  List<RetailerSale> get retailers => _retailers;

  Future<void> fetchRetailers() async {
    setBusy(true);
    try {
      final response =
          await _service.getAllRetailersSale(); // You need to implement this
      _retailers = response;
    } catch (e) {
      debugPrint('Error fetching retailers: $e');
    }
    setBusy(false);
  }
}
