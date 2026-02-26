import 'package:geolocation/services/report_services.dart';
import 'package:stacked/stacked.dart';

import '../../../model/sale_person_transaction_summary.dart';

class SalesTransactionSummaryViewModel extends BaseViewModel {
  List<SalesPersonWiseTransaction> allOrders = []; // Full unfiltered list
  List<SalesPersonWiseTransaction> orders = []; // Displayed (filtered) list

  Future<void> initialize() async {
    setBusy(true);
    allOrders =
        await ReportServices().fetchTransactionSummary(); // store full list
    orders = List.from(allOrders); // initially show all
    setBusy(false);
    notifyListeners();
  }

  DateTime? fromDate;
  DateTime? toDate;
  String? salesPerson;

  Future<void> fetchReport() async {
    setBusy(true);

    // Ensure filters are properly parsed
    final from = fromDate;
    final to = toDate;
    final person = salesPerson?.toLowerCase().trim();

    orders = allOrders.where((order) {
      final dateMatch = () {
        if (from == null && to == null) return true;
        final date = DateTime.tryParse(order.postingDate ?? '');
        if (date == null) return false;
        if (from != null && date.isBefore(from)) return false;
        if (to != null && date.isAfter(to)) return false;
        return true;
      }();

      final personMatch = () {
        if (person == null || person.isEmpty) return true;
        return (order.salesPerson ?? '').toLowerCase().contains(person);
      }();

      return dateMatch && personMatch;
    }).toList();

    setBusy(false);
    notifyListeners();
  }
}
