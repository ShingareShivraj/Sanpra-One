import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../router.router.dart';
import '../../../widgets/full_screen_loader.dart';
import 'list_leave_viewmodel.dart';

// ─── Design Tokens ───────────────────────────────────────────────────────────
class _T {
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryLight = Color(0xFF3B76EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF0F4FA);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color upcoming = Color(0xFF1A56DB);
  static const Color taken = Color(0xFF6D28D9);
}

class ListLeaveScreen extends StatefulWidget {
  const ListLeaveScreen({super.key});

  @override
  State<ListLeaveScreen> createState() => _ListLeaveScreenState();
}

class _ListLeaveScreenState extends State<ListLeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LeaveViewModel>.reactive(
      viewModelBuilder: () => LeaveViewModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, _) {
        return Scaffold(
          backgroundColor: _T.background,
          appBar: AppBar(
            title: const Text("My Leaves"),
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
             child:  Column(
                children: [
                  _FilterBar(model: model),
                  _StyledTabBar(controller: _tabController, model: model),
                ],
              ),
            ),
          ),
          body: fullScreenLoader(
            loader: model.isBusy,
            context: context,
            child: NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (context, _) => [
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _LeaveTabView(
                    leaves: model.leavelist,
                    model: model,
                    color: _T.upcoming,
                    icon: Icons.event_available_rounded,
                    title: "Upcoming Leaves",
                    onRefresh: model.refresh,
                  ),
                  _LeaveTabView(
                    leaves: model.takenlist,
                    model: model,
                    color: _T.taken,
                    icon: Icons.history_rounded,
                    title: "Taken Leaves",
                    onRefresh: model.refresh,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFab(context, model),
        );
      },
    );
  }


  Widget _buildFab(BuildContext context, LeaveViewModel model) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.pushNamed(
          context,
          Routes.addLeaveScreen,
          arguments: AddLeaveScreenArguments(leaveId: ""),
        );
        if (result == true) model.refresh();
      },
      backgroundColor: _T.primary,
      elevation: 3,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        "Apply Leave",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─── Summary Row ─────────────────────────────────────────────────────────────

// ─── Styled Tab Bar ──────────────────────────────────────────────────────────

class _StyledTabBar extends StatelessWidget {
  final TabController controller;
  final LeaveViewModel model;
  const _StyledTabBar({required this.controller, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TabBar(
        controller: controller,
        labelColor: _T.primary,
        unselectedLabelColor: _T.textSecondary,
        indicatorColor: _T.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_available_rounded, size: 15),
                const SizedBox(width: 6),
                const Text("Upcoming"),
                const SizedBox(width: 6),
                _TabCount(count: model.leavelist.length, color: _T.upcoming),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_rounded, size: 15),
                const SizedBox(width: 6),
                const Text("Taken"),
                const SizedBox(width: 6),
                _TabCount(count: model.takenlist.length, color: _T.taken),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabCount extends StatelessWidget {
  final int count;
  final Color color;
  const _TabCount({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$count",
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final LeaveViewModel model;
  const _SummaryRow({required this.model});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryBadge(
          label: "Upcoming",
          count: model.leavelist.length,
          icon: Icons.event_available_rounded,
          color: Colors.white,
        ),
        const SizedBox(width: 10),
        _SummaryBadge(
          label: "Taken",
          count: model.takenlist.length,
          icon: Icons.history_rounded,
          color: Colors.white,
        ),
      ],
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _SummaryBadge({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            "$count $label",
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Bar ──────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final LeaveViewModel model;
  const _FilterBar({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: model.selectedMonth,
              onChanged: model.updateSelectedmonth,
              isDense: true,
              decoration: _deco("Month"),
              items: List.generate(
                12,
                    (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(model.getMonthName(i + 1),
                      style: const TextStyle(fontSize: 13)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: model.selectedYear,
              onChanged: model.updateSelectedYear,
              isDense: true,
              decoration: _deco("Year"),
              items: model.availableYears
                  .map((y) => DropdownMenuItem(
                value: y,
                child: Text(y.toString(),
                    style: const TextStyle(fontSize: 13)),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _deco(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 12, color: _T.textSecondary),
    filled: true,
    fillColor: _T.background,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _T.divider),
    ),
  );
}

// ─── Leave Tab View ──────────────────────────────────────────────────────────

class _LeaveTabView extends StatelessWidget {
  final List leaves;
  final LeaveViewModel model;
  final Color color;
  final IconData icon;
  final String title;
  final Future<void> Function() onRefresh;

  const _LeaveTabView({
    required this.leaves,
    required this.model,
    required this.color,
    required this.icon,
    required this.title,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: color,
      onRefresh: onRefresh,
      child: leaves.isEmpty
          ? ListView(
        padding: const EdgeInsets.all(16),
        children: [_EmptyLeave(color: color)],
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: leaves.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final leave = leaves[index];
          return _AnimatedCard(
            index: index,
            child: _LeaveCard(
              leave: leave,
              model: model,
              accentColor: color,
              onTap: () => Navigator.pushNamed(
                context,
                Routes.addLeaveScreen,
                arguments:
                AddLeaveScreenArguments(leaveId: leave.name),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Leave Card ──────────────────────────────────────────────────────────────

class _LeaveCard extends StatelessWidget {
  final dynamic leave;
  final LeaveViewModel model;
  final VoidCallback onTap;
  final Color accentColor;

  const _LeaveCard({
    required this.leave,
    required this.model,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = model.getColorForStatus(leave.status ?? '');
    final hasHalfDay = (leave.halfDay == 1);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _T.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Colored top strip ──────────────────────────
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.06),
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  // Leave type pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      leave.leaveType ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status chip
                  _StatusChip(
                      label: leave.status ?? '', color: statusColor),
                  if (hasHalfDay) ...[
                    const SizedBox(width: 6),
                    _HalfDayBadge(),
                  ],
                ],
              ),
            ),

            // ── Card body ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date range row
                  Row(
                    children: [
                      _DateBlock(
                          label: "From", date: leave.fromDate ?? ''),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 24,
                        height: 1,
                        color: _T.divider,
                      ),
                      _DateBlock(
                          label: "To", date: leave.toDate ?? ''),
                    ],
                  ),

                  if (leave.halfDayDate?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.wb_sunny_outlined,
                      text: "Half Day: ${leave.halfDayDate}",
                      color: Colors.orange,
                    ),
                  ],

                  if (leave.description?.isNotEmpty == true) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: _T.divider),
                    ),
                    _InfoRow(
                      icon: Icons.notes_rounded,
                      text: leave.description,
                      color: _T.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _DateBlock extends StatelessWidget {
  final String label;
  final String date;
  const _DateBlock({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: _T.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(date,
            style: const TextStyle(
                fontSize: 13,
                color: _T.textPrimary,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoRow(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 13, color: _T.textSecondary, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _HalfDayBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "½ Day",
        style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.w600,
            fontSize: 11),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _EmptyLeave extends StatelessWidget {
  final Color color;
  const _EmptyLeave({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _T.divider),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 18, color: color.withOpacity(0.4)),
            const SizedBox(width: 8),
            Text(
              "No leaves found",
              style: TextStyle(
                color: _T.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Staggered animation card ────────────────────────────────────────────────

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedCard({required this.child, required this.index});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // stagger each card by 60ms
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
    _slide = Tween<Offset>(
        begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}