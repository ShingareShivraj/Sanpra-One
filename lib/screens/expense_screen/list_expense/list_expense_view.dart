import 'package:flutter/material.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';

import '../../../router.router.dart';
import '../../../widgets/view_docs_from_internet.dart';
import 'list_expense_viewmodel.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return ViewModelBuilder<ExpenseViewModel>.reactive(
      viewModelBuilder: () => ExpenseViewModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, child) => Scaffold(
        /// ================= APP BAR =================
        appBar: AppBar(
          title: const Text("My Expenses"),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: _filterBar(context, model),
          ),
        ),

        /// ================= BODY =================
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: RefreshIndicator(
            onRefresh: () => model.refresh(),
            child: model.expenselist.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: model.expenselist.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) =>
                        _expenseCard(context, model, index),
                  ),
          ),
        ),

        /// ================= FAB =================
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.pushNamed(
                context, Routes.addExpenseScreen,
                arguments: AddExpenseScreenArguments(expenseId: ""));
            if (result == true) model.refresh();
          },
          icon: const Icon(Icons.add),
          label: const Text("Create Expense"),
        ),
      ),
    );
  }

  // ================= FILTER BAR =================
  Widget _filterBar(BuildContext context, ExpenseViewModel model) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: model.selectedMonth,
              onChanged: (v) => model.updateSelectedmonth(v!),
              decoration: _inputDecoration("Month"),
              items: List.generate(
                12,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(model.getMonthName(i + 1)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: model.selectedYear,
              onChanged: model.updateSelectedYear,
              decoration: _inputDecoration("Year"),
              items: model.availableYears
                  .map((y) => DropdownMenuItem(value: y, child: Text("$y")))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseCard(
    BuildContext context,
    ExpenseViewModel model,
    int index,
  ) {
    final e = model.expenselist[index];
    return GestureDetector(
        onTap: () async {
          final result = await Navigator.pushNamed(
              context, Routes.addExpenseScreen,
              arguments:
                  AddExpenseScreenArguments(expenseId: e.name.toString()));
          if (result == true) model.refresh();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  /// TYPE
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${e.expenseType} Expense",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),

                  /// STATUS
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: model
                          .getColorForStatus(e.approvalStatus ?? "")
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      e.approvalStatus ?? "",
                      style: TextStyle(
                        color: model.getColorForStatus(e.approvalStatus ?? ""),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// DATE & AMOUNT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Date: ${e.expenseDate ?? "-"}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  Text(
                    "₹ ${e.totalClaimedAmount ?? 0}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const Divider(height: 14),

              Row(
                children: [
                  if (e.expenseDescription?.isNotEmpty == true)
                    Expanded(
                      child: Text(
                        "Description:- ${e.expenseDescription}",
                        style: const TextStyle(
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ),
                  if (e.attachments?.isNotEmpty == true)
                    Expanded(
                        child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text("View Attachment"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewImageInternet(
                                url: e.attachments!.first.fileUrl ?? "",
                              ),
                            ),
                          );
                        },
                      ),
                    ))

                  /// DESCRIPTION

                  /// ATTACHMENT
                ],
              )
            ],
          ),
        ));
  }

  // ================= HELPERS =================
  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No expenses found",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
