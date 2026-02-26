class SalesPersonWiseTransaction {
  String? salesOrder;
  String? customer;
  String? territory;
  String? warehouse;
  String? postingDate;
  String? itemCode;
  String? itemGroup;
  String? brand;
  dynamic qty;
  double? amount;
  String? salesPerson;
  double? contribution;
  double? contributionQty;
  double? contributionAmt;
  String? currency;

  SalesPersonWiseTransaction(
      {this.salesOrder,
      this.customer,
      this.territory,
      this.warehouse,
      this.postingDate,
      this.itemCode,
      this.itemGroup,
      this.brand,
      this.qty,
      this.amount,
      this.salesPerson,
      this.contribution,
      this.contributionQty,
      this.contributionAmt,
      this.currency});

  SalesPersonWiseTransaction.fromJson(Map<String, dynamic> json) {
    salesOrder = json['sales_order'];
    customer = json['customer'];
    territory = json['territory'];
    warehouse = json['warehouse'];
    postingDate = json['posting_date'];
    itemCode = json['item_code'];
    itemGroup = json['item_group'];
    brand = json['brand'];
    qty = json['qty'];
    amount = json['amount'];
    salesPerson = json['sales_person'];
    contribution = json['contribution'];
    contributionQty = json['contribution_qty'];
    contributionAmt = json['contribution_amt'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sales_order'] = this.salesOrder;
    data['customer'] = this.customer;
    data['territory'] = this.territory;
    data['warehouse'] = this.warehouse;
    data['posting_date'] = this.postingDate;
    data['item_code'] = this.itemCode;
    data['item_group'] = this.itemGroup;
    data['brand'] = this.brand;
    data['qty'] = this.qty;
    data['amount'] = this.amount;
    data['sales_person'] = this.salesPerson;
    data['contribution'] = this.contribution;
    data['contribution_qty'] = this.contributionQty;
    data['contribution_amt'] = this.contributionAmt;
    data['currency'] = this.currency;
    return data;
  }
}
