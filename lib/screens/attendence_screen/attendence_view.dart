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
            child: Container(
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
                      onChanged: (int? month) {
                        // Update the selected month when the user changes the dropdown value
                        model.updateSelectedMonth(month!);
                      },
                      decoration: _filterDecoration(
                          label: 'Month', icon: Icons.calendar_month),
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(model.getMonthName(index + 1)),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: model.selectedYear,
                      onChanged: (int? year) {
                        // Update the selected year when the user changes the dropdown value
                        model.updateSelectedYear(year!);
                      },
                      decoration:
                          _filterDecoration(label: 'Year', icon: Icons.event),
                      items: model.availableYears
                          .map((y) =>
                              DropdownMenuItem(value: y, child: Text('$y')))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// ---------------- CALENDAR ----------------
                _sectionCard(
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
                    onFormatChanged: (format) {
                      model.updateCalendarFormat(format);
                    },
                    eventLoader: (day) => model.attendanceList,
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      formatButtonTextStyle:
                          const TextStyle(color: Colors.white),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final attendance = model.getAttendanceForDate(date);
                        if (attendance == null) return const SizedBox();
                        return Positioned(
                          bottom: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: model
                                  .getColorForStatus(attendance.status ?? ""),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ---------------- SUMMARY ----------------
                _sectionTitle(
                    "${model.getMonthName(model.selectedMonth ?? 0)} ${model.selectedYear}"),

                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _statCard("Present", model.attendanceDetails.present ?? 0,
                        Colors.green),
                    _statCard("Absent", model.attendanceDetails.absent ?? 0,
                        Colors.red),
                    _statCard("Half Day", model.attendanceDetails.halfDay ?? 0,
                        Colors.indigo),
                    _statCard("Day Off", model.attendanceDetails.onLeave ?? 0,
                        Colors.amber),
                  ],
                ),

                const SizedBox(height: 24),

                /// ---------------- LIST ----------------
                model.attendanceList.isNotEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: model.attendanceList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final item = model.attendanceList[index];
                          return _attendanceTile(item);
                        },
                      )
                    : _emptyState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================

  static InputDecoration _filterDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  static Widget _sectionCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }

  static Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  static Widget _statCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value.toString(),
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text(title,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static Widget _attendanceTile(dynamic item) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat("EEEE, dd MMM")
                  .format(DateTime.parse(item.attendanceDate ?? "")),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeColumn("Check In", item.inTime),
                _timeColumn("Check Out", item.outTime),
                _timeColumn("Hours", item.workingHours?.toString()),
              ],
            )
          ],
        ),
      ),
    );
  }

  static Widget _timeColumn(String label, String? value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(value ?? "--",
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  static Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child:
            Text("No attendance found", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
