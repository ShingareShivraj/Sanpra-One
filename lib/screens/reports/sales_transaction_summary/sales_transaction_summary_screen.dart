import 'package:flutter/material.dart';
import 'package:geolocation/screens/reports/sales_transaction_summary/sales_transaction_summary_viewmodel.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';

class SalesTransactionSummaryScreen extends StatelessWidget {
  const SalesTransactionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SalesTransactionSummaryViewModel>.reactive(
      viewModelBuilder: () => SalesTransactionSummaryViewModel(),
      onViewModelReady: (vm) => vm.initialize(),
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sales Person-wise Transaction')),
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
                    DataColumn(label: Text('Item Code')),
                    // DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Contribution')),
                    DataColumn(label: Text('Contribution Amount')),
                    // DataColumn(label: Text('Incentive')),
                  ],
                  rows: vm.orders.map((order) {
                    return DataRow(cells: [
                      DataCell(Text(order.salesPerson ?? "")),
                      DataCell(Text(order.postingDate ?? "")),
                      DataCell(Text(order.salesOrder ?? "")),
                      DataCell(Text(order.itemCode ?? "")),
                      DataCell(Text(order.qty.toString())),
                      DataCell(Text(order.amount.toString())),
                      DataCell(Text(order.contribution.toString())),
                      DataCell(Text(order.contributionAmt.toString())),
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
