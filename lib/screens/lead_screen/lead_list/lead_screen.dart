import 'package:flutter/material.dart';
import 'package:geolocation/screens/lead_screen/lead_list/lead_viewmodel.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../router.router.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LeadListViewModel>.reactive(
      viewModelBuilder: LeadListViewModel.new,
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,

          /// APP BAR
          appBar: AppBar(
            title: const Text('Leads'),
            centerTitle: true,
            elevation: 0,
          ),

          /// BODY
          body: fullScreenLoader(
            context: context,
            loader: model.isBusy,
            child: Column(
              children: [
                /// 🔍 SEARCH BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: TextField(
                    controller: _searchController,
                    onChanged: model.filterBySearch,
                    decoration: InputDecoration(
                      hintText: "Search by company...",
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                /// 📋 LEAD LIST
                Expanded(
                  child: model.filterleadlist.isEmpty
                      ? const _EmptyState()
                      : RefreshIndicator(
                          onRefresh: model.refresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 90),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: model.filterleadlist.length,
                            itemBuilder: (context, index) {
                              final lead = model.filterleadlist[index];

                              return InkWell(
                                onTap: () => model.onRowClick(context, lead),
                                child: LeadCard(
                                  status: lead.status ?? '',
                                  name: lead.name ?? '',
                                  company: lead.companyName ?? '',
                                  region: lead.territory ?? 'N/A',
                                  location: lead.customLocationAddress ??
                                      'Location not available',
                                  date: lead.creation ?? '',
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),

          /// ➕ CREATE LEAD
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Create Lead'),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                Routes.addLeadScreen,
                arguments: const AddLeadScreenArguments(leadId: ''),
              );
              if (result == true) model.refresh();
            },
          ),
        );
      },
    );
  }
}

/// =======================
/// LEAD CARD
/// =======================
class LeadCard extends StatelessWidget {
  final String status;
  final String name;
  final String company;
  final String region;
  final String location;
  final String date;

  const LeadCard({
    super.key,
    required this.status,
    required this.name,
    required this.company,
    required this.region,
    required this.location,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String formattedDate;
    try {
      formattedDate =
          DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.parse(date));
    } catch (_) {
      formattedDate = date;
    }

    _statusColor(status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0.8,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ─── HEADER ─────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: status),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ─── COMPANY ───────────────────────────
            Text(
              company,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.blue,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: 2),

            /// CONTACT PERSON
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 12),

            /// ─── META INFO ─────────────────────────
            Row(
              children: [
                _IconText(
                  icon: Icons.public,
                  text: region,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconText(
                  icon: Icons.location_on_outlined,
                  text: location,
                  maxLines: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Converted":
        return Colors.green.shade700;
      case "Interested":
        return Colors.orange.shade700;
      case "Lead":
        return Colors.blue.shade700;
      case "Opportunity":
        return Colors.indigo.shade700;
      case "Lost Quotation":
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Converted":
        return Colors.green;
      case "Interested":
        return Colors.orange;
      case "Lead":
        return Colors.blue;
      case "Opportunity":
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final int maxLines;

  const _IconText({
    required this.icon,
    required this.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// EMPTY STATE
/// =======================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No leads available 😔',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
}
