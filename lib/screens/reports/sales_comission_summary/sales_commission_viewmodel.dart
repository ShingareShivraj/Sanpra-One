import 'package:geolocation/model/sales_person_commission.dart';
import 'package:geolocation/services/report_services.dart';
import 'package:stacked/stacked.dart';

class SalesCommissionViewmodel extends BaseViewModel {
  List<SalesPersonWiseCommission> orders = []; // Displayed (filtered) list

  Future<void> initialize() async {
    setBusy(true);
    orders = await ReportServices().fetchCommissionSummary(); // store full list
    setBusy(false);
    notifyListeners();
  }
}
