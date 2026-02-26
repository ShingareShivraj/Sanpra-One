class OrderDetailsModel {
  double? discountAmount;
  double? grandTotal;
  double? netTotal;
  double? totalTaxesAndCharges;

  OrderDetailsModel(
      {this.discountAmount,
      this.grandTotal,
      this.netTotal,
      this.totalTaxesAndCharges});

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    discountAmount = json['discount_amount'];
    grandTotal = json['grand_total'];
    netTotal = json['net_total'];
    totalTaxesAndCharges = json['total_taxes_and_charges'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['discount_amount'] = discountAmount;
    data['grand_total'] = grandTotal;
    data['net_total'] = netTotal;
    data['total_taxes_and_charges'] = totalTaxesAndCharges;
    return data;
  }
}
