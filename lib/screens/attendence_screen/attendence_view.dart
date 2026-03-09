import 'package:flutter/material.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

import 'attendence_viewmodel.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ViewModelBuilder<AttendenceViewModel>.reactive(
      viewModelBuilder: () => AttendenceViewModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Attendance'),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: _FilterHeader(model: model),
          ),
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: RefreshIndicator(
            onRefresh: () async {
              // if you have a refresh method in VM call it, else just re-init
              await model.initialise(context);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Legend
                  _LegendRow(model: model),
                  const SizedBox(height: 12),

                  // Calendar Card
                  _SectionCard(
                    child: TableCalendar(
                      focusedDay: DateTime(
                        model.selectedYear ?? DateTime.now().year,
                        model.selectedMonth ?? DateTime.now().month,
                        1,
                      ),
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      calendarFormat: model.calendarFormat,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      onFormatChanged: model.updateCalendarFormat,

                      // Don't use eventLoader like this; markerBuilder already checks per date.
                      eventLoader: (_) => const [],

                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        leftChevronIcon: Icon(Icons.chevron_left),
                        rightChevronIcon: Icon(Icons.chevron_right),
                        formatButtonVisible: false,
                        titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        weekendStyle: theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        todayDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: theme.textTheme.bodyMedium!,
                        weekendTextStyle: theme.textTheme.bodyMedium!,
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          final attendance = model.getAttendanceForDate(date);
                          if (attendance == null) return const SizedBox();

                          final color =
                              model.getColorForStatus(attendance.status ?? "");
                          return Positioned(
                            bottom: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Summary Title
                  Text(
                    "${model.getMonthName(model.selectedMonth ?? DateTime.now().month)} ${model.selectedYear ?? DateTime.now().year}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats (Attendance summary)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      _StatCard(
                        title: "Present",
                        value: model.attendanceDetails.present ?? 0,
                        color: Colors.green,
                      ),
                      _StatCard(
                        title: "Absent",
                        value: model.attendanceDetails.absent ?? 0,
                        color: Colors.red,
                      ),
                      _StatCard(
                        title: "Half Day",
                        value: model.attendanceDetails.halfDay ?? 0,
                        color: Colors.indigo,
                      ),
                      _StatCard(
                        title: "Leave/Off",
                        value: model.attendanceDetails.onLeave ?? 0,
                        color: Colors.amber.shade800,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // List title
                  Text(
                    "Daily Details",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Attendance list
                  if (model.attendanceList.isNotEmpty)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: model.attendanceList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final item = model.attendanceList[index];
                        return _AttendanceRow(
                          item: item,
                          statusColor:
                              model.getColorForStatus(item.status ?? ""),
                          statusText: (item.status ?? "Unknown"),
                        );
                      },
                    )
                  else
                    const _EmptyState(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- Header Filters ---------------- */

class _FilterHeader extends StatelessWidget {
  const _FilterHeader({required this.model});
  final AttendenceViewModel model;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
              onChanged: (m) {
                if (m == null) return;
                model.updateSelectedMonth(m);
              },
              decoration: _decoration(cs, "Month", Icons.calendar_month),
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
              onChanged: (y) {
                if (y == null) return;
                model.updateSelectedYear(y);
              },
              decoration: _decoration(cs, "Year", Icons.event),
              items: model.availableYears
                  .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(ColorScheme cs, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: cs.surface,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

/* ---------------- Legend ---------------- */

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.model});
  final AttendenceViewModel model;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget dot(String label, Color color) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    // If your status names differ, adjust here
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.spaceBetween,
      spacing: 14,
      runSpacing: 8,
      children: [
        dot("Present", Colors.green),
        dot("Absent", Colors.red),
        dot("Half Day", Colors.indigo),
        dot("Leave/Off", Colors.amber.shade800),
      ],
    );
  }
}

/* ---------------- Reusable Card ---------------- */

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

/* ---------------- Stat Card ---------------- */

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.toString(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- Attendance Row ---------------- */

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.item,
    required this.statusColor,
    required this.statusText,
  });

  final dynamic item;
  final Color statusColor;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final date = _safeDate(item.attendanceDate);
    final dateLabel =
        date == null ? "-" : DateFormat("EEE, dd MMM").format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black87.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Date + Status
          Row(
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusChip(color: statusColor, label: statusText),
            ],
          ),
          const SizedBox(height: 12),

          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeColumn("Check In", item.inTime),
              _TimeColumn("Check Out", item.outTime),
              _TimeColumn("Hours", item.workingHours?.toString()),
            ],
          ),
        ],
      ),
    );
  }

  DateTime? _safeDate(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Text(
          value?.isNotEmpty == true ? value! : "--",
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

/* ---------------- Empty ---------------- */

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, color: cs.primary, size: 34),
          const SizedBox(height: 10),
          Text(
            "No attendance found",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            "Try selecting another month/year.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
