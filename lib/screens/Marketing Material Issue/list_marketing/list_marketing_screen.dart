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
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text("Merchandise"),
            centerTitle: true,
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
            label: const Text("Add Merchandise"),
            icon: const Icon(Icons.add),
          ),
          body: vm.isBusy
              ? const Center(child: CircularProgressIndicator())
              : vm.leads.isEmpty
                  ? const Center(
                      child: Text("No Marketing Issue Found"),
                    )
                  : RefreshIndicator(
                      onRefresh: vm.fetchLeads,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: vm.leads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final lead = vm.leads[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MarketingFormScreen(
                                    Id: lead.name ?? "",
                                  ),
                                ),
                              );
                              if (result == true) vm.fetchLeads();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Leading Icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.blueAccent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.campaign_outlined,
                                      size: 20,
                                      color: Colors.blueAccent,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  /// Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                lead.customer ??
                                                    "Unknown Customer",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),

                                            /// Workflow State Badge
                                            _workflowChip(lead.workflowState),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            _miniInfo(
                                              Icons.calendar_today_outlined,
                                              lead.date ?? "-",
                                            ),
                                            const SizedBox(width: 12),
                                            _miniInfo(
                                              Icons.inventory_2_outlined,
                                              lead.totalQty?.toString() ?? "0",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// Actions
                                  Column(
                                    children: [
                                      _miniAction(
                                        icon: Icons.visibility_outlined,
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MarketingFormScreen(
                                                Id: lead.name ?? "",
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 6),
                                      _miniAction(
                                        icon: Icons.edit_outlined,
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MarketingFormScreen(
                                                Id: lead.name ?? "",
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            vm.fetchLeads();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }

  /// ================= HELPERS =================

  Widget _miniInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _miniAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  /// Workflow state chip
  Widget _workflowChip(String? state) {
    final label = state ?? "Draft";

    Color bgColor;
    Color textColor;

    switch (label) {
      case "Approved":
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case "Rejected":
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case "Pending":
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
