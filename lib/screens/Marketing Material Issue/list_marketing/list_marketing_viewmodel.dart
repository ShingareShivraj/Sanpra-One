import 'package:stacked/stacked.dart';

import '../../../services/add_project_lead_services.dart';

class MarketingListViewModel extends BaseViewModel {
  final _service = ProjectLeadService();

  List<ListMarketingMaterialIssue> leads = [];

  Future<void> fetchLeads() async {
    setBusy(true);

    leads = await _service.getAllIssue();
    notifyListeners();
    setBusy(false);
  }
}

class ListMarketingMaterialIssue {
  String? name;
  String? owner;
  int? docstatus;
  String? customer;
  String? date;
  double? totalQty;
  String? workflowState;

  ListMarketingMaterialIssue(
      {this.name,
      this.owner,
      this.docstatus,
      this.customer,
      this.date,
      this.totalQty,
      this.workflowState});

  ListMarketingMaterialIssue.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    docstatus = json['docstatus'];
    customer = json['customer'];
    date = json['date'];
    workflowState = json['workflow_state'];
    totalQty = json['total_qty'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['name'] = name;
    data['owner'] = owner;
    data['docstatus'] = docstatus;
    data['customer'] = customer;
    data['date'] = date;
    data['workflow_state'] = workflowState;
    data['total_qty'] = totalQty;
    return data;
  }
}
