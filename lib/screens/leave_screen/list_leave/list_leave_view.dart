import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../router.router.dart';
import '../../../widgets/full_screen_loader.dart';
import 'list_leave_viewmodel.dart';

class ListLeaveScreen extends StatelessWidget {
  const ListLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LeaveViewModel>.reactive(
      viewModelBuilder: () => LeaveViewModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text("My Leaves"),
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(86),
              child: _FilterBar(model: model),
            ),
          ),
          body: fullScreenLoader(
            loader: model.isBusy,
            context: context,
            child: RefreshIndicator(
              onRefresh: model.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                children: [
                  _LeaveSection(
                    title: "Upcoming Leaves",
                    icon: Icons.upcoming,
                    leaves: model.leavelist,
                    model: model,
                  ),
                  const SizedBox(height: 24),
                  _LeaveSection(
                    title: "Taken Leaves",
                    icon: Icons.history,
                    leaves: model.takenlist,
                    model: model,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                Routes.addLeaveScreen,
                arguments: AddLeaveScreenArguments(leaveId: ""),
              );

              if (result == true) {
                model.refresh(); // 👈 reload API
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Create Leave"),
          ),
        );
      },
    );
  }
}

/* ============================================================
                          FILTER BAR
============================================================ */
class _FilterBar extends StatelessWidget {
  final LeaveViewModel model;

  const _FilterBar({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: model.selectedMonth,
              onChanged: model.updateSelectedmonth,
              decoration: const InputDecoration(
                labelText: 'Month',
                isDense: true,
                border: OutlineInputBorder(),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Year',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: model.availableYears
                  .map(
                    (y) => DropdownMenuItem(
                      value: y,
                      child: Text(y.toString()),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
                        LEAVE SECTION
============================================================ */
class _LeaveSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List leaves;
  final LeaveViewModel model;

  const _LeaveSection({
    required this.title,
    required this.icon,
    required this.leaves,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blueGrey),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Chip(
              label: Text(leaves.length.toString()),
              backgroundColor: Colors.blue.shade50,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (leaves.isEmpty)
          const _EmptyLeave(message: 'No leaves found')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaves.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final leave = leaves[index];
              return _LeaveCard(
                leave: leave,
                model: model,
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.addLeaveScreen,
                  arguments: AddLeaveScreenArguments(leaveId: leave.name),
                ),
              );
            },
          ),
      ],
    );
  }
}

/* ============================================================
                          LEAVE CARD
============================================================ */
class _LeaveCard extends StatelessWidget {
  final dynamic leave;
  final LeaveViewModel model;
  final VoidCallback onTap;

  const _LeaveCard({
    required this.leave,
    required this.model,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = model.getColorForStatus(leave.status ?? '');
    final hasHalfDay =
        (leave.halfDay == 1); // adjust if your leave model differs

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
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
                /// LEAVE TYPE (like reason pill)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    leave.leaveType ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Spacer(),

                /// STATUS CHIP (optional)
                _StatusChip(
                  label: leave.status ?? '',
                  color: statusColor,
                ),

                const SizedBox(width: 8),

                /// HALF DAY TAG
                if (hasHalfDay)
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

                /// DELETE (only draft)
              ],
            ),

            const SizedBox(height: 12),

            /// DATE RANGE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "From: ${leave.fromDate ?? ''}",
                  style: const TextStyle(color: Colors.black87),
                ),
                Text(
                  "To: ${leave.toDate ?? ''}",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// HALF DAY DATE (optional)
            if (leave.halfDayDate?.isNotEmpty == true)
              Text(
                "Half Day:- ${leave.halfDayDate}",
                style: const TextStyle(
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),

            const Divider(height: 24),

            /// DESCRIPTION / EXPLANATION
            if (leave.description?.isNotEmpty == true)
              Text(
                "Explanation:- ${leave.description}",
                style: const TextStyle(
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
                          STATUS CHIP
============================================================ */
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

/* ============================================================
                          EMPTY STATE
============================================================ */
class _EmptyLeave extends StatelessWidget {
  final String message;

  const _EmptyLeave({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
