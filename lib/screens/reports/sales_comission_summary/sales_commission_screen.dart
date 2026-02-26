import 'package:flutter/material.dart';
import 'package:geolocation/screens/reports/sales_comission_summary/sales_commission_viewmodel.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';

class SalesCommissionSummaryScreen extends StatelessWidget {
  const SalesCommissionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SalesCommissionViewmodel>.reactive(
      viewModelBuilder: () => SalesCommissionViewmodel(),
      onViewModelReady: (vm) => vm.initialize(),
      builder: (context, vm, child) {
        return Scaffold(
          appBar:
              AppBar(title: const Text('Sales Person-wise Commission report')),
          body: fullScreenLoader(
            context: context,
            loader: vm.isBusy,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Sales Person')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Id')),
                    DataColumn(label: Text('Customer')),
                    // DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Contribution')),
                    DataColumn(label: Text('Contribution Amount')),
                    DataColumn(label: Text('Incentive')),
                  ],
                  rows: vm.orders.map((order) {
                    return DataRow(cells: [
                      DataCell(Text(order.salesPerson ?? "")),
                      DataCell(Text(order.postingDate ?? "")),
                      DataCell(Text(order.salesOrder ?? "")),
                      DataCell(Text(order.customer ?? "")),
                      DataCell(Text(order.amount.toString())),
                      DataCell(Text(order.contributionPercentage.toString())),
                      DataCell(Text(order.contributionAmount.toString())),
                      DataCell(Text(order.incentives.toString())),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
