import 'package:flutter/cupertino.dart';
import 'package:geolocation/model/customer_list_model.dart';
import 'package:stacked/stacked.dart';

import '../../../router.router.dart';
import '../../../services/customer_list_services.dart';

class CustomerListViewModel extends BaseViewModel {
  List<CustomerList> customerList = [];
  List<CustomerList> filterCustomerList = [];
  List<String> customerShowList = [];
  List<String> territoryList = [];
  Future<void> initialise(BuildContext context) async {
    setBusy(true);
    customerList = await CustomerListService().fetchCustomerList();
// customerShowList=await CustomerListService().getcustomer();
// territoryList=await CustomerListService().fetchterritory();
    filterCustomerList = customerList;
    setBusy(false);
  }

  Future<void> refresh() async {
    filterCustomerList = await CustomerListService().fetchCustomerList();
    notifyListeners();
  }

  void onRowClick(BuildContext context, CustomerList? cusList) {
    Navigator.pushNamed(
      context,
      Routes.updateCustomer,
      arguments: UpdateCustomerArguments(id: cusList?.name ?? ""),
    );
  }

  String _customer = "";

  String get customer => _customer;

  Future<void> setCustomerFilter(String? customer) async {
    _customer = customer ?? "";
    if (_customer.isEmpty) {
      filterCustomerList = await CustomerListService().fetchCustomerList();
    } else {
      filterCustomerList =
          await CustomerListService().fetchFilterCustomer("", _customer);
    }
    notifyListeners();
  }

  Future<void> clearFilter() async {
    _customer = "";
    filterCustomerList = await CustomerListService().fetchCustomerList();
    notifyListeners();
  }
}
