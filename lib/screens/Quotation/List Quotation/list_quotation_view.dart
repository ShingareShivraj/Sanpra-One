import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';

import '../../../router.router.dart';
import '../../../widgets/drop_down.dart';
import '../../../widgets/full_screen_loader.dart';
import '../../../widgets/text_button.dart';
import 'list_quotation_model.dart';

class ListQuotationScreen extends StatelessWidget {
  const ListQuotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListQuotationModel>.reactive(
      viewModelBuilder: () => ListQuotationModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          elevation: 0,
          title: const Text('Quotations',
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.white),
              onPressed: () => _showBottomSheet(context, model),
            ),
          ],
        ),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return true;
          },
          child: fullScreenLoader(
            context: context,
            loader: model.isBusy,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: model.filterquotationlist.isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: () => model.refresh(),
                      child: ListView.separated(
                        itemCount: model.filterquotationlist.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = model.filterquotationlist[index];
                          return GestureDetector(
                            onTap: () => model.onRowClick(context, item),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey.shade100],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name ?? "",
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                            Text(
                                              item.transactionDate ?? "",
                                              style: TextStyle(
                                                  color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 12.0),
                                          decoration: BoxDecoration(
                                            color: model.getColorForStatus(
                                                item.status ?? ""),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: AutoSizeText(
                                            item.status ?? "",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildColumnInfo(
                                            'Customer', item.customerName),
                                        _buildColumnInfo(
                                            'Items', item.totalQty?.toString()),
                                        _buildColumnInfo(
                                          'Amount',
                                          '${item.grandTotal?.toString() ?? "0.0"}',
                                          valueColor: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline,
                                size: 48, color: Colors.grey.shade600),
                            const SizedBox(height: 10),
                            const Text(
                              'No Quotations Found',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.addQuotationView,
              arguments: const AddQuotationViewArguments(quotationid: ""),
            );
          },
          label: const Text('Create Quote'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildColumnInfo(String label, String? value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(
          value ?? "",
          style: TextStyle(fontSize: 14, color: valueColor ?? Colors.black),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context, ListQuotationModel model) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomDropdownButton2(
                  value: model.quotationto,
                  prefixIcon: Icons.person_2,
                  items: model.quotation,
                  hintText: 'Select Quotation To',
                  labelText: 'Quotation To',
                  onChanged: model.setquotationto,
                ),
                const SizedBox(height: 12.0),
                CustomDropdownButton2(
                  value: model.custm,
                  prefixIcon: Icons.person_2,
                  items: model.customer,
                  hintText: 'Select Customer',
                  labelText: 'Customer',
                  onChanged: model.setcustomer,
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CTextButton(
                      onPressed: () {
                        model.clearfilter();
                        Navigator.pop(context);
                      },
                      text: 'Clear Filter',
                      buttonColor: Colors.grey,
                    ),
                    CTextButton(
                      onPressed: () {
                        model.setfilter(
                            model.quotationto ?? "", model.custm ?? "");
                        Navigator.pop(context);
                      },
                      text: 'Apply Filter',
                      buttonColor: Colors.blueAccent,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
