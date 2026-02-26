class QuotationList {

  String? validTill;
  String? name;
  String? title;
  String? quotationTo;
  String? customerName;
  String? transactionDate;
  double? grandTotal;
  String? status;
  double? totalQty;
  QuotationList({

  this.name,

  this.title,

  this.quotationTo,

  this.customerName,

  this.transactionDate,
  this.validTill,

  this.totalQty,

  this.grandTotal,

  this.status



});
  QuotationList.fromJson(Map<String, dynamic> json) {
  name = json['name'];
  title = json['title'];
  quotationTo = json['quotation_to'];
  customerName = json['customer_name'];
  transactionDate = json['transaction_date'];
  grandTotal = json['grand_total'];
  status = json['status'];
  totalQty = json['total_qty'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['title'] = title;
    data['quotation_to'] = quotationTo;
    data['customer_name'] = customerName;
    data['transaction_date'] = transactionDate;
    data['grand_total'] = grandTotal;
    data['status'] = status;
    data['total_qty'] = totalQty;
    return data;
  }

}
