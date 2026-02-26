import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

import '../../../services/add_project_lead_services.dart';

class AddMarketingViewmodel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();

  final _logger = Logger();
  final _service = ProjectLeadService();
  final descriptionController = TextEditingController();
  final totalQtyController = TextEditingController(text: "0");

  MarketingMaterialIssue issue = MarketingMaterialIssue(
    items: <Items>[],
    totalQty: 0,
  );

  bool isEdit = false;
  String name = "";
  bool isSubmitted = false;

  List<String> customer = <String>[];
  List<MerchandiseItems> items = <MerchandiseItems>[];
  MerchandiseDetails details = MerchandiseDetails();

  // Optional: UI can use this to disable edits when approved
  bool get isApproved => !["Pending", null].contains(issue.workflowState);

  // --------------------------------------------------
  // INIT
  // --------------------------------------------------
  Future<void> init(String id) async {
    setBusy(true);
    try {
      details = await _service.marketingDetails() ?? MerchandiseDetails();

      customer = (details.customer ?? const []).cast<String>();
      items = details.merchandiseItems ?? <MerchandiseItems>[];

      // NEW
      if (id.isEmpty) {
        isEdit = false;
        name = "";
        issue = MarketingMaterialIssue(
          date: DateTime.now().toString().split(" ").first,
          items: <Items>[],
          totalQty: 0,
        );
        descriptionController.text = "";
        _recalcTotal(notify: false);
        notifyListeners();
        return;
      }

      // EDIT
      isEdit = true;
      name = id;

      issue = await _service.getIssue(id) ??
          MarketingMaterialIssue(items: <Items>[], totalQty: 0);

      issue.items ??= <Items>[];
      issue.totalQty ??= 0;

      descriptionController.text = issue.remarks ?? "";

      _recalcTotal(notify: false);
      notifyListeners();
    } catch (e, st) {
      _logger.e("Init Error", error: e, stackTrace: st);
    } finally {
      setBusy(false);
    }
  }

  // --------------------------------------------------
  // ITEM HELPERS
  // --------------------------------------------------

  MerchandiseItems? getMerchandiseByCode(String? code) {
    if (code == null || code.isEmpty) return null;
    try {
      return items.firstWhere((e) => e.name == code);
    } catch (_) {
      return null;
    }
  }

  bool _existsByCode(String? code) {
    if (code == null || code.isEmpty) return false;
    final list = issue.items ?? const <Items>[];
    return list.any((e) => e.itemCode == code);
  }

  void _ensureItemsList() {
    issue.items ??= <Items>[];
  }

  void _recalcTotal({bool notify = true}) {
    final list = issue.items ?? const <Items>[];
    double total = 0;
    for (final i in list) {
      total += (i.qtyGiven ?? 0);
    }
    issue.totalQty = total;
    totalQtyController.text = total.toStringAsFixed(0);
    if (notify) notifyListeners();
  }

  // --------------------------------------------------
  // ITEM CONTROLS (used by your sheet)
  // --------------------------------------------------

  void removeItem(int index) {
    _ensureItemsList();
    if (index < 0 || index >= issue.items!.length) return;

    issue.items!.removeAt(index);
    _recalcTotal(); // notifies once
  }

  void addOrUpdateItemFromSheet({
    required MerchandiseItems selectedItem,
    required double qty,
    int? editIndex,
  }) {
    if (qty <= 0) return;

    _ensureItemsList();
    final code = selectedItem.name;
    if (code == null || code.isEmpty) return;

    // ✏️ EDIT MODE
    if (editIndex != null) {
      if (editIndex < 0 || editIndex >= issue.items!.length) return;

      // Optional: prevent changing item to duplicate another one
      final isChangingToDuplicate = issue.items!
          .asMap()
          .entries
          .any((e) => e.key != editIndex && e.value.itemCode == code);
      if (isChangingToDuplicate) return;

      final row = issue.items![editIndex];
      row.itemCode = code;
      row.itemName = selectedItem.itemName;
      row.qtyGiven = qty;

      _recalcTotal(); // notifies once
      return;
    }

    // ➕ ADD MODE (prevent duplicate)
    if (_existsByCode(code)) return;

    issue.items!.add(
      Items(
        itemCode: code,
        itemName: selectedItem.itemName,
        qtyGiven: qty,
      ),
    );

    _recalcTotal(); // notifies once
  }

  // (Optional) If your UI still calls these old methods anywhere:
  void updateQty(int index, String value) {
    _ensureItemsList();
    if (index < 0 || index >= issue.items!.length) return;

    issue.items![index].qtyGiven = double.tryParse(value) ?? 0;
    _recalcTotal(); // notifies once
  }

  // --------------------------------------------------
  // CUSTOMER / REMARKS
  // --------------------------------------------------

  void setCustomer(String? value) {
    issue.customer = value;
    notifyListeners();
  }

  void setRemark(String v) {
    // No need to assign controller text here, controller already holds value
    issue.remarks = v;
    // (Optional) You can skip notify to reduce rebuilds while typing
    // notifyListeners();
  }

  // --------------------------------------------------
  // SAVE
  // --------------------------------------------------

  Future<void> onSavePressed(BuildContext context) async {
    if (isBusy || isSubmitted) return;

    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final list = issue.items ?? const <Items>[];
    if (list.isEmpty) {
      _showToast(context, "Please add at least one item", isError: true);
      return;
    }

    isSubmitted = true; // lock double taps
    setBusy(true);

    try {
      if (isEdit) {
        await _service.updateIssue(issue);
        _showToast(context, "Updated Successfully");
      } else {
        await _service.addIssue(issue);
        _showToast(context, "Created Successfully");
      }

      if (context.mounted) Navigator.pop(context, true);
    } catch (e, st) {
      _logger.e("Save Error", error: e, stackTrace: st);
      _showToast(context, "Error while saving", isError: true);
      isSubmitted = false; // allow retry
    } finally {
      setBusy(false);
    }
  }

  // --------------------------------------------------
  // TOAST
  // --------------------------------------------------
  void _showToast(
    BuildContext context,
    String msg, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    totalQtyController.dispose();
    super.dispose();
  }
}

// =======================================================
// MODELS
// =======================================================

class MarketingMaterialIssue {
  String? name;
  String? owner;
  int? docstatus;
  String? customer;
  String? workflowState;
  String? date;
  double? totalQty;
  String? remarks;
  List<Items>? items;

  MarketingMaterialIssue({
    this.name,
    this.owner,
    this.docstatus,
    this.customer,
    this.date,
    this.workflowState,
    this.totalQty,
    this.remarks,
    this.items,
  });

  MarketingMaterialIssue.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    docstatus = json['docstatus'];
    customer = json['customer'];
    date = json['date'];
    workflowState = json['workflow_state'];
    totalQty = json['total_qty'] ?? 0;
    remarks = json['remarks'];
    items = (json['items'] as List<dynamic>?)
            ?.map((e) => Items.fromJson(e))
            .toList() ??
        [];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'owner': owner,
      'docstatus': docstatus,
      'customer': customer,
      'date': date,
      'workflow_state': workflowState,
      'remarks': remarks,
      'total_qty': totalQty,
      'items': items?.map((e) => e.toJson()).toList() ?? [],
    };
  }
}

class Items {
  String? name;
  String? itemCode;
  String? itemName;
  double? qtyGiven;

  Items({
    this.name,
    this.itemCode,
    this.itemName,
    this.qtyGiven,
  });

  Items.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    itemCode = json['item_code'];
    itemName = json['item_name'];
    qtyGiven = json['qty_given'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'item_code': itemCode,
      'item_name': itemName,
      'qty_given': qtyGiven,
    };
  }
}
