import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../add_project_lead/add_project_lead_screen.dart';
import 'list_project_lead_viewmodel.dart';

class ProjectLeadListScreen extends StatelessWidget {
  const ProjectLeadListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProjectLeadListViewModel>.reactive(
      viewModelBuilder: () => ProjectLeadListViewModel(),
      onViewModelReady: (vm) => vm.fetchLeads(),
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Project Leads"),
            centerTitle: true,
            elevation: 1,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              final result = Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProjectLeadFormScreen(
                          Id: '',
                        )),
              );
              if (result == true) vm.fetchLeads();
            },
            label: const Text("Add Lead"),
            icon: const Icon(Icons.add),
          ),
          body: vm.isBusy
              ? const Center(child: CircularProgressIndicator())
              : vm.leads.isEmpty
                  ? const Center(
                      child: Text(
                        "No Project Leads Found",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: vm.fetchLeads,
                      child: ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: vm.leads.length,
                          itemBuilder: (context, index) {
                            final lead = vm.leads[index];

                            return InkWell(
                              onTap: () {
                                final result = Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectLeadFormScreen(
                                      Id: lead.name.toString(),
                                    ),
                                  ),
                                );
                                if (result == true) vm.fetchLeads();
                              },
                              splashColor: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // LEFT COLOR STRIP
                                    Container(
                                      width: 6,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(14),
                                          bottomLeft: Radius.circular(14),
                                        ),
                                      ),
                                    ),

                                    // CONTENT
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // NAME
                                            Text(
                                              lead.contactPerson ?? "No Name",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            // STATUS ROW
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 18,
                                                    color: Colors.blueAccent),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    lead.siteStatus ?? "-",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 6),

                                            // TERRITORY ROW
                                            Row(
                                              children: [
                                                const Icon(Icons.map_outlined,
                                                    size: 18,
                                                    color: Colors.green),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    lead.territory ?? "-",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 8),

                                            const Divider(
                                                height: 1,
                                                color: Colors.black12),

                                            const SizedBox(height: 10),

                                            // FOOTER: Last Updated / View Detail Arrow
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Tap to view details",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                const Icon(
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                    size: 16),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
        );
      },
    );
  }

  /// Small helper widget for clean subtitle layout
  Widget _subText(String title, String value) {
    return Text(
      "$title: $value",
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade700,
      ),
    );
  }
}
