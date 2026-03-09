import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../add_marketing/add_marketing_screen.dart';
import 'list_marketing_viewmodel.dart';

class MarketingListScreen extends StatelessWidget {
  const MarketingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MarketingListViewModel>.reactive(
      viewModelBuilder: () => MarketingListViewModel(),
      onViewModelReady: (vm) => vm.fetchLeads(),
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Merchandise"),
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarketingFormScreen(Id: ''),
                ),
              );
              if (result == true) vm.fetchLeads();
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Merchandise"),
          ),
          body: vm.isBusy
              ? const Center(child: CircularProgressIndicator())
              : vm.leads.isEmpty
                  ? _EmptyState(
                      title: "No Merchandise Found",
                      subtitle: "Tap “Add Merchandise” to create a new entry.",
                    )
                  : RefreshIndicator(
                      onRefresh: vm.fetchLeads,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        itemCount: vm.leads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final lead = vm.leads[index];

                          return _MerchandiseCard(
                            customer: lead.customer ?? "Unknown Customer",
                            workflowState: lead.workflowState,
                            date: lead.date ?? "-",
                            totalQty: lead.totalQty?.toString() ?? "0",
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MarketingFormScreen(Id: lead.name ?? ""),
                                ),
                              );
                              if (result == true) vm.fetchLeads();
                            },
                            onEdit: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MarketingFormScreen(Id: lead.name ?? ""),
                                ),
                              );
                              if (result == true) vm.fetchLeads();
                            },
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }
}

class _MerchandiseCard extends StatelessWidget {
  const _MerchandiseCard({
    required this.customer,
    required this.workflowState,
    required this.date,
    required this.totalQty,
    required this.onTap,
    required this.onEdit,
  });

  final String customer;
  final String? workflowState;
  final String date;
  final String totalQty;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left icon
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.campaign_outlined,
                  color: cs.primary,
                ),
              ),

              const SizedBox(width: 12),

              // Middle content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer + status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _WorkflowChip(state: workflowState),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Meta row
                    Row(
                      children: [
                        _MetaPill(
                          icon: Icons.calendar_today_outlined,
                          value: date,
                        ),
                        const SizedBox(width: 10),
                        _MetaPill(
                          icon: Icons.inventory_2_outlined,
                          value: "Qty: $totalQty",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right action
              IconButton(
                tooltip: "Edit",
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: cs.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowChip extends StatelessWidget {
  const _WorkflowChip({required this.state});

  final String? state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label =
        (state == null || state!.trim().isEmpty) ? "Draft" : state!.trim();

    late final Color bg;
    late final Color fg;

    switch (label) {
      case "Approved":
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
      case "Rejected":
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        break;
      case "Pending":
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        break;
      default:
        bg = cs.surfaceContainerHighest;
        fg = cs.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.campaign_outlined, size: 34, color: cs.primary),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
