import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/screens/lead_screen/update_screen/update_viewmodel.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:iconsax/iconsax.dart';
import 'package:stacked/stacked.dart';

import '../../../router.router.dart';

class UpdateLeadScreen extends StatefulWidget {
  final String updateId;
  const UpdateLeadScreen({super.key, required this.updateId});

  @override
  State<UpdateLeadScreen> createState() => _UpdateLeadScreenState();
}

class _UpdateLeadScreenState extends State<UpdateLeadScreen> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UpdateLeadModel>.reactive(
      viewModelBuilder: () => UpdateLeadModel(),
      onViewModelReady: (model) => model.initialise(context, widget.updateId),
      builder: (context, model, child) => Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          elevation: 0,
          title: Text(
            model.leadData.name ?? "Lead Details",
            // style: const TextStyle(color: Colors.black87, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  Routes.addLeadScreen,
                  arguments: AddLeadScreenArguments(leadId: widget.updateId),
                );
                if (context.mounted) {
                  // 👇 Refresh data when returning
                  model.initialise(context, widget.updateId);
                }
              },
              icon: const Icon(Icons.edit),
            )
          ],
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ===== PROFILE HEADER =====
                    Center(
                      child: Column(
                        children: [
                          /// PROFILE IMAGE
                          _buildLeadProfileCard(context, model.leadData.image),

                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFEFF1F7),
                              child: Icon(Icons.location_on,
                                  color: Colors.redAccent),
                            ),
                            title: const Text(
                              "Address",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              model.leadData.locationAddress ??
                                  "Address not available",
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          _buildLeadProfileRow(model),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 15,
                            children: [
                              _buildActionButton(
                                  Iconsax.call,
                                  "Phone",
                                  () => model.callService
                                      .call(model.leadData.mobileNo ?? "")),
                              _buildActionButton(
                                  Icons.message,
                                  "Message",
                                  () => model.callService
                                      .sendSms(model.leadData.mobileNo ?? "")),
                              _buildActionButton(
                                  Icons.email,
                                  "Email",
                                  () => model.callService
                                      .sendEmail(model.leadData.emailId ?? "")),
                              _buildActionButton(
                                  Iconsax.message5,
                                  "WhatsApp",
                                  () => model.openWhatsApp(
                                      model.leadData.mobileNo ?? "")),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== PERSONAL INFO =====
                    _buildSection("Personal Information", [
                      _buildInfoRow(
                          "Lead Owner", model.leadData.leadOwner ?? ""),
                      _buildInfoRow("Name", model.leadData.leadName ?? ""),
                      _buildInfoRow("Type", model.leadData.marketSegment ?? ""),
                      _buildInfoRow(
                          "Territory", model.leadData.territory ?? ""),
                    ]),

                    // ===== CONTACT DETAILS =====
                    _buildSection("Contact Details", [
                      _buildInfoRow("Email", model.leadData.emailId ?? "",
                          valueColor: Colors.blue),
                      _buildInfoRow("Mobile", model.leadData.mobileNo ?? ""),
                    ]),

                    // ===== COMPANY INFO =====
                    _buildSection("Company Information", [
                      _buildInfoRow(
                          "Organisation", model.leadData.companyName ?? ""),
                      _buildInfoRow("Category", model.leadData.industry ?? ""),
                      _buildInfoRow("GST In", model.leadData.gstIn ?? ""),
                    ]),
                    _buildSection("Address Details", [
                      _buildInfoRow("Address", model.leadData.address ?? ""),
                      _buildInfoRow("City", model.leadData.city ?? ""),
                      _buildInfoRow("State", model.leadData.state ?? ""),
                      _buildInfoRow(
                          "Pincode", model.leadData.pincode.toString() ?? ""),
                    ]),
                    _buildSection("Description", [
                      _buildInfoRow(
                          "Description", model.leadData.description ?? ""),
                    ]),
                    // 🆕 ===== SOURCE INFO =====
                    if ((model.leadData.source ?? "").isNotEmpty)
                      _buildSection("Source Information", [
                        _buildInfoRow("Source", model.leadData.source ?? "—"),
                        if ((model.leadData.source ?? "").toLowerCase() ==
                            "existing customer") ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            "Customer",
                            model.leadData.customer ?? "—",
                            valueColor: Colors.deepPurple,
                          ),
                        ],
                      ]),

                    // ===== NOTES =====
                    const SizedBox(height: 12),
                    const Text("Comments",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: model.notes.length,
                      itemBuilder: (context, index) {
                        final noteData = model.notes[index];
                        return Dismissible(
                          key: Key(index.toString()),
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerLeft,
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              bool dismiss = false;
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      "Delete Note?",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: const Text(
                                        "Are you sure you want to delete this note?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          dismiss = false;
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          dismiss = true;
                                          model.deleteNote(widget.updateId,
                                              noteData.name ?? 0);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return dismiss;
                            }
                            return false;
                          },
                          child: Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: noteData.image ?? "",
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.blueAccent)),
                                  errorWidget: (context, url, error) => Center(
                                    child: Image.asset(
                                        'assets/images/profile.png',
                                        scale: 5),
                                  ),
                                ),
                              ),
                              title: Text(noteData.note ?? ""),
                              subtitle: Text(
                                "${noteData.commented ?? ""} | ${noteData.addedOn ?? ""}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),

              // ===== ADD COMMENT INPUT =====
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: model.noteController,
                        decoration: InputDecoration(
                          hintText: "Add a comment...",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (model.noteController.text.isNotEmpty) {
                          model.addNote(
                              widget.updateId, model.noteController.text);
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadProfileRow(UpdateLeadModel model) {
    final lead = model.leadData;

    final String leadName = lead.leadName?.trim().isNotEmpty == true
        ? lead.leadName!
        : 'Unknown Lead';

    final String? companyName =
        lead.companyName?.trim().isNotEmpty == true ? lead.companyName : null;

    final String? currentStatus =
        UpdateLeadModel.statusOptions.contains(lead.status)
            ? lead.status
            : null;

    final Color statusColor = model.getStatusColor(lead.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// NAME + COMPANY
            Icon(Icons.person_3),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    leadName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (companyName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      companyName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// STATUS DROPDOWN
            _StatusDropdown(
              value: currentStatus,
              isBusy: model.isBusy,
              statusColor: statusColor,
              onChanged: (value) async {
                if (value == null || value == lead.status) return;

                final confirm = await model.confirmStatusChange(context, value);
                if (confirm) {
                  await model.changeStatus(widget.updateId, value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadProfileCard(BuildContext context, String? imageUrl) {
    return GestureDetector(
      onTap: () => _showFullLeadImage(context, imageUrl),
      child: Hero(
        tag: imageUrl ?? "lead-image",
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.3),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: CachedNetworkImage(
            imageUrl: imageUrl ?? "",
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (context, url, error) =>
                Image.asset('assets/images/profile.png', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  void _showFullLeadImage(BuildContext context, String? imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: Hero(
                  tag: imageUrl ?? "lead-image",
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl ?? "",
                      fit: BoxFit.contain,
                      errorWidget: (c, u, e) =>
                          Image.asset('assets/images/profile.png'),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==== HELPER WIDGETS ====
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color valueColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style:
                    TextStyle(fontWeight: FontWeight.w500, color: valueColor)),
          ),
        ],
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String? value;
  final bool isBusy;
  final Color statusColor;
  final ValueChanged<String?> onChanged;

  const _StatusDropdown({
    required this.value,
    required this.isBusy,
    required this.statusColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 115,
        maxWidth: 140,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        isDense: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: statusColor.withOpacity(0.15),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 18,
        ),
        items: UpdateLeadModel.statusOptions.map((status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
        onChanged: isBusy ? null : onChanged,
      ),
    );
  }
}
