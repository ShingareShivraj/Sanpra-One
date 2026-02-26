import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/screens/visit_screens/visit_List/visit_list_model.dart';
import 'package:stacked/stacked.dart';

import '../../../model/add_visit_model.dart';
import '../../../router.router.dart';
import '../../../widgets/full_screen_loader.dart';

class VisitScreen extends StatelessWidget {
  const VisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ViewModelBuilder<VisitViewModel>.reactive(
      viewModelBuilder: () => VisitViewModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, _) => Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        appBar: AppBar(
          title: const Text('My Visits'),
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: RefreshIndicator(
            onRefresh: () => model.refresh(context),
            child: model.visitList.isEmpty
                ? _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: model.visitList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final visit = model.visitList[index];
                      return _VisitCard(
                        visit: visit,
                        onTap: () async {
                          model.onRowClick(context, visit);
                          // Refresh after returning from details/edit screen
                          await model.refresh(context);
                        },
                      );
                    },
                  ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // Navigate to AddVisitScreen
            await Navigator.pushNamed(
              context,
              Routes.addVisitScreen,
              arguments: AddVisitScreenArguments(VisitId: ""),
            );
            // Refresh after coming back from AddVisitScreen
            await model.refresh(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Visit'),
        ),
      ),
    );
  }
}

/* =========================
   VISIT CARD
========================= */

class _VisitCard extends StatelessWidget {
  final AddVisitModel visit;
  final VoidCallback onTap;

  const _VisitCard({
    required this.visit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
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
              /// HEADER
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      visit.visitorsName ?? 'Unknown Customer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _StatusChip(visit: visit),
                ],
              ),

              const SizedBox(height: 4),

              AutoSizeText(
                "${visit.name} • ${visit.date}",
                maxLines: 1,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),

              const SizedBox(height: 12),

              /// IN / OUT
              Row(
                children: [
                  _TimeItem(
                    icon: Icons.login,
                    color: Colors.green,
                    label: visit.visitInTime != null
                        ? _formatTime(context, visit.visitInTime!)
                        : "--",
                  ),
                  const SizedBox(width: 20),
                  _TimeItem(
                    icon: Icons.logout,
                    color: Colors.red,
                    label: visit.visitOutTime != null
                        ? _formatTime(context, visit.visitOutTime!)
                        : "--",
                  ),
                  const SizedBox(width: 20),
                  _TimeItem(
                    icon: Icons.timelapse_outlined,
                    color: Colors.blueAccent,
                    label: visit.visitOutTime != null
                        ? "${visit.duration.toString()} min."
                        : "--",
                  ),

                  /// TOTAL DIFFERENCE
                ],
              ),

              if (visit.visitOutAddress?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        visit.visitOutAddress!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
   STATUS CHIP
========================= */

class _StatusChip extends StatelessWidget {
  final AddVisitModel visit;
  const _StatusChip({required this.visit});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(visit);
    final label = _getStatusText(visit);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/* =========================
   TIME ITEM
========================= */

class _TimeItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _TimeItem({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

/* =========================
   EMPTY STATE
========================= */

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No visits found',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

/* =========================
   HELPERS
========================= */

String _formatTime(BuildContext context, String dateTime) {
  final dt = DateTime.tryParse(dateTime);
  if (dt == null) return "--";
  return TimeOfDay.fromDateTime(dt).format(context);
}

String _getStatusText(AddVisitModel visit) {
  if (visit.visitInTime != null && visit.visitOutTime != null) {
    return "COMPLETED";
  }
  if (visit.visitInTime != null) {
    return "IN PROGRESS";
  }
  return "PENDING";
}

Color _getStatusColor(AddVisitModel visit) {
  if (visit.visitInTime != null && visit.visitOutTime != null) {
    return Colors.green;
  }
  if (visit.visitInTime != null) {
    return Colors.orange;
  }
  return Colors.grey;
}
