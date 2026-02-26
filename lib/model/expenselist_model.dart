class Expenselist {
  String? name;
  String? modifiedBy;
  String? owner;
  int? docstatus;
  int? idx;
  String? namingSeries;
  String? employee;
  String? employeeName;
  String? department;
  String? expenseApprover;
  String? approvalStatus;
  int? isPaid;
  double? totalSanctionedAmount;
  double? totalTaxesAndCharges;
  double? totalAdvanceAmount;
  double? grandTotal;
  double? totalClaimedAmount;
  double? totalAmountReimbursed;
  
  String? postingDate;
  String? title;
  String? payableAccount;
  String? costCenter;
  String? status;
  String? expenseType;
  String? expenseDescription;
  String? expenseDate;
  List<Attachments>? attachments;

  Expenselist(
      {this.name,
        this.modifiedBy,
        this.owner,
        this.docstatus,
        this.idx,
        this.namingSeries,
        this.employee,
        this.employeeName,
        this.department,
        this.expenseApprover,
        this.approvalStatus,
        this.isPaid,
        this.totalSanctionedAmount,
        this.totalTaxesAndCharges,
        this.totalAdvanceAmount,
        this.grandTotal,
        this.totalClaimedAmount,
        this.totalAmountReimbursed,
        this.postingDate,
        this.title,
        this.payableAccount,
        this.costCenter,
        this.status,
        this.expenseType,
        this.expenseDescription,
        this.expenseDate,
        this.attachments});

  Expenselist.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    modifiedBy = json['modified_by'];
    owner = json['owner'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    namingSeries = json['naming_series'];
    employee = json['employee'];
    employeeName = json['employee_name'];
    department = json['department'];
    expenseApprover = json['expense_approver'];
    approvalStatus = json['approval_status'];
    isPaid = json['is_paid'];
    totalSanctionedAmount = json['total_sanctioned_amount'];
    totalTaxesAndCharges = json['total_taxes_and_charges'];
    totalAdvanceAmount = json['total_advance_amount'];
    grandTotal = json['grand_total'];
    totalClaimedAmount = json['total_claimed_amount'];
    totalAmountReimbursed = json['total_amount_reimbursed'];
    postingDate = json['posting_date'];
    title = json['title'];
    payableAccount = json['payable_account'];
    costCenter = json['cost_center'];
    status = json['status'];
    expenseType = json['expense_type'];
    expenseDescription = json['expense_description'];
    expenseDate = json['expense_date'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add( Attachments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['name'] = name;
    data['modified_by'] = modifiedBy;
    data['owner'] = owner;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['naming_series'] = namingSeries;
    data['employee'] = employee;
    data['employee_name'] = employeeName;
    data['department'] = department;
    data['expense_approver'] = expenseApprover;
    data['approval_status'] = approvalStatus;
    data['is_paid'] = isPaid;
    data['total_sanctioned_amount'] = totalSanctionedAmount;
    data['total_taxes_and_charges'] = totalTaxesAndCharges;
    data['total_advance_amount'] = totalAdvanceAmount;
    data['grand_total'] = grandTotal;
    data['total_claimed_amount'] = totalClaimedAmount;
    data['total_amount_reimbursed'] = totalAmountReimbursed;
    data['posting_date'] = postingDate;
    data['title'] = title;
    data['payable_account'] = payableAccount;
    data['cost_center'] = costCenter;
    data['status'] = status;
    data['expense_type'] = expenseType;
    data['expense_description'] = expenseDescription;
    data['expense_date'] = expenseDate;
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attachments {
  String? fileUrl;

  Attachments({this.fileUrl});

  Attachments.fromJson(Map<String, dynamic> json) {
    fileUrl = json['file_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file_url'] = fileUrl;
    return data;
  }
}
