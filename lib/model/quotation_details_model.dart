class QuotationDetailsModel {
  double? discountAmount;
  double? grandTotal;
  double? netTotal;
  double? totalTaxesAndCharges;

  QuotationDetailsModel(
      {this.discountAmount,
        this.grandTotal,
        this.netTotal,
        this.totalTaxesAndCharges});

  QuotationDetailsModel.fromJson(Map<String, dynamic> json) {
    discountAmount = json['discount_amount'];
    grandTotal = json['grand_total'];
    netTotal = json['net_total'];
    totalTaxesAndCharges = json['total_taxes_and_charges'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['discount_amount'] = this.discountAmount;
    data['grand_total'] = this.grandTotal;
    data['net_total'] = this.netTotal;
    data['total_taxes_and_charges'] = this.totalTaxesAndCharges;
    return data;
  }
}