import 'package:flutter/material.dart';
import 'package:geolocation/screens/comp_off_screen/add_comp_off/add_comp_off_view.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';

import 'list_comp_off_viewmodel.dart';

class ListCompOffView extends StatelessWidget {
  const ListCompOffView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CompOffViewModel>.reactive(
      viewModelBuilder: () => CompOffViewModel(),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) => Scaffold(
        /// ================= APP BAR =================
        appBar: AppBar(
          title: const Text("My Comp Off Requests"),
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
            onRefresh: model.refresh,
            child: model.requests.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: model.requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) =>
                        _attendanceCard(context, model, index),
                  ),
          ),
        ),

        /// ================= FAB =================
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddCompOffView(leaveId: ""),
              ),
            );

            if (result == true) {
              model.refresh();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("Create Request"),
        ),
      ),
    );
  }

  // ================= FILTER BAR =================
  Widget _filterBar(
    BuildContext context,
    CompOffViewModel model,
  ) {
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
              initialValue: model.selectedMonth,
              onChanged: (v) => model.updateSelectedMonth(v!),
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
              initialValue: model.selectedYear,
              onChanged: model.updateSelectedYear,
              decoration: _inputDecoration("Year"),
              items: model.availableYears
                  .map(
                    (y) => DropdownMenuItem(
                      value: y,
                      child: Text("$y"),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _attendanceCard(
    BuildContext context,
    CompOffViewModel model,
    int index,
  ) {
    final r = model.requests[index];
    final isHalfDay = r.halfDay == 1;

    return Container(
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
              /// REASON
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r.reason ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),

              /// HALF DAY
              if (isHalfDay)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Half Day",
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (r.docstatus == 0)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await _confirmDelete(context);
                    if (confirm == true) {
                      await model.deleteRequest(r.name, r.docstatus ?? 0);
                    }
                  },
                ),
            ],
          ),

          const SizedBox(height: 12),

          /// DATE RANGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "From: ${r.workFromDate}",
                style: const TextStyle(color: Colors.black87),
              ),
              Text(
                "To: ${r.workEndDate}",
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (r.halfDayDate?.isNotEmpty == true)
            Text(
              "Half Day:- ${r.halfDayDate}",
              style: const TextStyle(
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          const Divider(height: 24),

          /// EXPLANATION
          if (r.reason?.isNotEmpty == true)
            Text(
              "Reason:- ${r.reason}",
              style: const TextStyle(
                color: Colors.grey,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  // ================= DELETE CONFIRM =================
  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Attendance Request"),
        content: const Text(
          "Are you sure you want to delete this request?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
        "No attendance requests found",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
