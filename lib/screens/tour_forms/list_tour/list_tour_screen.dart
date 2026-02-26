import 'package:flutter/material.dart';
import 'package:geolocation/screens/tour_forms/list_tour/list_tour_viewmodel.dart';
import 'package:stacked/stacked.dart';

import '../../../model/tour_model.dart';
import '../../../widgets/full_screen_loader.dart';
import '../add_tour/add_tour.dart';

class ListTourScreen extends StatelessWidget {
  const ListTourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListTourViewModel>.reactive(
      viewModelBuilder: () => ListTourViewModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, _) => Scaffold(
        appBar: AppBar(
          title: const Text('My Tours'),
          centerTitle: true,
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: RefreshIndicator(
            onRefresh: () => model.refresh(context),
            child: model.visitList.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: model.visitList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final Tour visit = model.visitList[index];
                      return _VisitCard(
                        visit: visit,
                        model: model,
                      );
                    },
                  ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Create Tour'),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateTourScreen(),
              ),
            );

            if (result == true) {
              model.refresh(context);
            }
          },
        ),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final Tour visit;
  final ListTourViewModel model;

  const _VisitCard({
    required this.visit,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primary.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= TOP ROW =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// LOCATION ICON
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: primary,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                /// AREA NAME
                Expanded(
                  child: Text(
                    visit.area ?? "-",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                ),

                /// CALLS BADGE
                _CallsBadge(count: visit.totalCalls ?? 0),

                const SizedBox(width: 6),

                /// DELETE
                IconButton(
                  tooltip: "Delete Tour",
                  onPressed: model.isBusy
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Delete Tour"),
                              content: const Text(
                                  "Are you sure you want to delete this tour?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            model.deleteTour(visit.name, context);
                          }
                        },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// ================= DATE ROW =================
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  visit.date ?? "-",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              "Description: ${visit.description}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallsBadge extends StatelessWidget {
  final int count;

  const _CallsBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primary.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.call_rounded,
            size: 14,
            color: primary,
          ),
          const SizedBox(width: 6),
          Text(
            "$count Calls",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.tour,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No tours found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
