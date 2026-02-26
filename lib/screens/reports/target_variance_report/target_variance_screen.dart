import 'package:flutter/material.dart';
import 'package:geolocation/screens/reports/target_variance_report/target_variance_viewmodel.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';

class SalesTargetScreen extends StatelessWidget {
  const SalesTargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SalesTargetViewModel>.reactive(
      viewModelBuilder: () => SalesTargetViewModel(),
      onViewModelReady: (vm) => vm.initialize(),
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sales Person Target Variance')),
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
                    DataColumn(label: Text('Target')),
                    DataColumn(label: Text('Achieved')),
                    DataColumn(label: Text('Variance')),
                    // DataColumn(label: Text('Item Name')),
                  ],
                  rows: vm.orders.map((order) {
                    return DataRow(cells: [
                      DataCell(Text(order.salesPerson ?? "")),
                      DataCell(Text(order.totalTarget.toString())),
                      DataCell(Text(order.totalAchieved.toString())),
                      DataCell(Text(order.totalVariance.toString())),
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
