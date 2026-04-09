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
    final theme = Theme.of(context);

    return ViewModelBuilder<ListQuotationModel>.reactive(
      viewModelBuilder: () => ListQuotationModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, child) => Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,

        /// APPBAR
        appBar: AppBar(
          title: const Text("Quotations"),
          centerTitle: true,

        ),

        /// BODY
        body: fullScreenLoader(
          context: context,
          loader: model.isBusy,
          child: Column(
            children: [

              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: SearchBar(
                  hintText: "Search by customer name",
                  leading: const Icon(Icons.search),
                  onChanged: model.searchPartyName,
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    theme.colorScheme.surfaceContainerHigh,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              /// LIST
              Expanded(
                child: model.filterquotationlist.isNotEmpty
                    ? RefreshIndicator(
                  onRefresh: () => model.refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: model.filterquotationlist.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),

                    itemBuilder: (context, index) {
                      final item = model.filterquotationlist[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => model.onRowClick(context, item),

                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant),
                          ),

                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              /// HEADER
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {
                                      model.shareQuotation(item);
                                    },
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: model.getQuotationForStatus(
                                          item.quotationTo ?? ""),
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.quotationTo ?? "",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  /// STATUS CHIP
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: model.getColorForStatus(
                                          item.status ?? ""),
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.status ?? "",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              /// DATE
                              Text(
                                item.transactionDate ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const Divider(height: 18),

                              /// INFO ROW
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  _infoTile(
                                      "Customer", item.customerName),
                                  _infoTile(
                                      "Items",
                                      item.totalQty?.toString() ??
                                          "0"),
                                  _infoTile(
                                    "Amount",
                                    "₹ ${item.grandTotal ?? 0}",
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : const _EmptyState(),
              ),
            ],
          ),
        ),

        /// CREATE BUTTON
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text("New Quote"),
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.addQuotationView,
              arguments: const AddQuotationViewArguments(quotationid: ""),
            );
          },
        ),
      ),
    );
  }

  /// SMALL INFO TILE
  Widget _infoTile(String label, String? value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          value ?? "",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined,
              size: 60, color: Colors.grey.shade500),
          const SizedBox(height: 10),
          const Text(
            "No Quotations Found",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}