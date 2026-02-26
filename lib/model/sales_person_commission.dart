class SalesPersonWiseCommission {
  String? salesOrder;
  String? customer;
  String? territory;
  String? postingDate;
  double? amount;
  String? salesPerson;
  double? contributionPercentage;
  String? commissionRate;
  double? contributionAmount;
  double? incentives;

  SalesPersonWiseCommission(
      {this.salesOrder,
      this.customer,
      this.territory,
      this.postingDate,
      this.amount,
      this.salesPerson,
      this.contributionPercentage,
      this.commissionRate,
      this.contributionAmount,
      this.incentives});

  SalesPersonWiseCommission.fromJson(Map<String, dynamic> json) {
    salesOrder = json['Sales Order'];
    customer = json['customer'];
    territory = json['territory'];
    postingDate = json['posting_date'];
    amount = json['amount'];
    salesPerson = json['sales_person'];
    contributionPercentage = json['contribution_percentage'];
    commissionRate = json['commission_rate'];
    contributionAmount = json['contribution_amount'];
    incentives = json['incentives'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Sales Order'] = this.salesOrder;
    data['customer'] = this.customer;
    data['territory'] = this.territory;
    data['posting_date'] = this.postingDate;
    data['amount'] = this.amount;
    data['sales_person'] = this.salesPerson;
    data['contribution_percentage'] = this.contributionPercentage;
    data['commission_rate'] = this.commissionRate;
    data['contribution_amount'] = this.contributionAmount;
    data['incentives'] = this.incentives;
    return data;
  }
}
