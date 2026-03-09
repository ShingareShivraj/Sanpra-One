import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';

import 'update_customer_model.dart';

class UpdateCustomer extends StatefulWidget {
  final String id;
  const UpdateCustomer({super.key, required this.id});

  @override
  State<UpdateCustomer> createState() => _UpdateCustomerState();
}

class _UpdateCustomerState extends State<UpdateCustomer> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UpdateCustomerViewModel>.reactive(
      viewModelBuilder: () => UpdateCustomerViewModel(),
      onViewModelReady: (model) => model.initialise(context, widget.id),
      builder: (context, model, child) => Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: const BackButton(color: Colors.black),
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _profileHeader(model),
                const SizedBox(height: 20),
                _statsRow(model),
                const SizedBox(height: 20),
                _segmentedTabs(),
                const SizedBox(height: 20),
                _buildTabContent(model),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _profileHeader(UpdateCustomerViewModel model) {
    final d = model.customerData;

    return Column(
      children: [
        Text(
          d.name ?? "Customer",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          "Customer ID : ${d.name ?? "--"}",
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        _actionButtons(model),
      ],
    );
  }

  Widget _actionButtons(UpdateCustomerViewModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionIcon(
          Icons.call,
          "Call",
          () {
            model.service.call(model.customerData.phone ?? "");
          },
        ),
        _actionIcon(
          Icons.email,
          "Email",
          () {
            model.service.sendEmail(model.customerData.email ?? "");
          },
        ),
        _actionIcon(
          Icons.message,
          "Message",
          () {
            model.service.sendSms(model.customerData.phone ?? "");
          },
        ),
      ],
    );
  }

  Widget _actionIcon(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  // ================= STATS =================

  Widget _statsRow(UpdateCustomerViewModel model) {
    final d = model.customerData;

    return Row(
      children: [
        _statCard("VISITS", d.totalVisits.toString(), Icons.location_on,
            Colors.orange),
        const SizedBox(width: 12),
        _statCard("ORDERS", d.totalOrders.toString(), Icons.shopping_bag,
            Colors.blue),
        const SizedBox(width: 12),
        _statCard("SPENT", "₹${d.totalOrderAmount ?? 0}", Icons.attach_money,
            Colors.green),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ================= SEGMENTED TABS =================

  Widget _segmentedTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabChip("Details", 0),
          _tabChip("Orders", 1),
          _tabChip("Visits", 2),
          _tabChip("Notes", 3),
        ],
      ),
    );
  }

  Widget _tabChip(String text, int index) {
    final selected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(text,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.black : Colors.grey)),
          ),
        ),
      ),
    );
  }

  // ================= TAB CONTENT =================

  Widget _buildTabContent(UpdateCustomerViewModel model) {
    switch (selectedTab) {
      case 0:
        return _detailsTab(model);
      case 1:
        return _ordersTab(model);
      case 2:
        return _visitTab(model);
      case 3:
        return _commentsTab(model);
      default:
        return const SizedBox();
    }
  }

  // ================= DETAILS =================

  Widget _detailsTab(UpdateCustomerViewModel model) {
    final d = model.customerData;

    return _sectionCard(
      "Contact Info",
      child: Column(
        children: [
          _infoRow(Icons.phone, "Mobile Number", d.phone ?? "N/A"),
          const Divider(),
          _infoRow(Icons.email, "Email Address", d.email ?? "N/A"),
          const Divider(),
          _infoRow(Icons.location_on, "Address", d.address ?? "N/A",
              multiline: true),
        ],
      ),
    );
  }

  // ================= ORDERS =================

  Widget _ordersTab(UpdateCustomerViewModel model) {
    if (model.filterOrders.isEmpty) {
      return _emptyState("No orders found");
    }

    return _sectionCard(
      "Orders History",
      child: Column(
        children: model.filterOrders.map((o) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.orderId ?? "",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(o.date ?? "",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12))
                      ]),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("₹${o.amount}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Chip(
                      label: Text(o.status ?? "Closed"),
                      backgroundColor: Colors.green.withOpacity(.15),
                    )
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _visitTab(UpdateCustomerViewModel model) {
    if (model.visit.isEmpty) {
      return _emptyState("No visits found");
    }

    return _sectionCard(
      "Visit Timeline",
      child: Column(
        children: List.generate(model.visit.length, (index) {
          final v = model.visit[index];
          final isLast = index == model.visit.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 Timeline Indicator
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // 📦 Visit Card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.visitId ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${v.visitInTime ?? "--"} → ${v.visitOutTime ?? "--"}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // 📍 Address
                        if ((v.visitInAddress ?? "").isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  v.visitInAddress ?? "",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // 📝 Description
                        if ((v.description ?? "").isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              v.description ?? "",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
  // ================= COMMENTS =================

  Widget _commentsTab(UpdateCustomerViewModel model) {
    return _sectionCard(
      "Notes",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- ADD COMMENT ----------
          _addCommentBox(model),

          const Divider(),

          /// ---------- COMMENTS LIST ----------
          if (model.comments.isEmpty)
            _emptyState("No comments yet")
          else
            Column(
              children: model.comments.map((c) {
                return Padding(
                  padding: const EdgeInsets.all(3),
                  child: _commentItem(c),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _commentItem(dynamic c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Html(data: c.comment),
          const SizedBox(height: 6),
          Text(
            "${c.commentBy} • ${c.commented}",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _addCommentBox(UpdateCustomerViewModel model) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            /// INPUT FIELD (CHAT STYLE)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: model.comment,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendComment(model),
                  decoration: const InputDecoration(
                    hintText: "Type a message…",
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            /// SEND BUTTON (CIRCLE)
            GestureDetector(
              onTap: model.isBusy ? null : () => _sendComment(model),
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: model.comment.text.trim().isEmpty
                      ? Colors.grey.shade400
                      : Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: model.isBusy
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to avoid duplicate logic
  void _sendComment(UpdateCustomerViewModel model) {
    final text = model.comment.text.trim();
    if (text.isEmpty) return;

    model.addComment(
      model.customerData.name,
      text,
    );
  }

  // ================= COMMON =================

  Widget _sectionCard(String title, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool multiline = false}) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFEFF1F7),
          child: Icon(icon, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, height: 1.4)),
          ]),
        )
      ],
    );
  }

  Widget _emptyState(String text) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child:
          Center(child: Text(text, style: const TextStyle(color: Colors.grey))),
    );
  }
}
