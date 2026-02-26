class SalesPersonWiseTarget {
  int? totalTarget;
  double? totalAchieved;
  double? totalVariance;
  String? salesPerson;
  String? itemGroup;

  SalesPersonWiseTarget(
      {this.totalTarget,
      this.totalAchieved,
      this.totalVariance,
      this.salesPerson,
      this.itemGroup});

  SalesPersonWiseTarget.fromJson(Map<String, dynamic> json) {
    totalTarget = json['total_target'];
    totalAchieved = json['total_achieved'];
    totalVariance = json['total_variance'];
    salesPerson = json['sales_person'];
    itemGroup = json['item_group'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_target'] = this.totalTarget;
    data['total_achieved'] = this.totalAchieved;
    data['total_variance'] = this.totalVariance;
    data['sales_person'] = this.salesPerson;
    data['item_group'] = this.itemGroup;
    return data;
  }
}
