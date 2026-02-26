import 'package:geolocation/model/Sales%20Person%20target%20model.dart';
import 'package:geolocation/services/report_services.dart';
import 'package:stacked/stacked.dart';

class SalesTargetViewModel extends BaseViewModel {
  List<SalesPersonWiseTarget> orders = []; // Full unfiltered list

  Future<void> initialize() async {
    setBusy(true);
    orders = await ReportServices().fetchTarget(); // store full list
    setBusy(false);
    notifyListeners();
  }
}
