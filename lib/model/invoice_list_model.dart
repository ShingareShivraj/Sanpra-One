class InvoiceList {
  String? name;
  String? customerName;
  String? dueDate;
  double? grandTotal;
  String? status;
  double? totalQty;

  InvoiceList(
      {this.name,
        this.customerName,
        this.dueDate,
        this.grandTotal,
        this.status,
        this.totalQty});

  InvoiceList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    customerName = json['customer_name'];
    dueDate = json['due_date'];
    grandTotal = json['grand_total'];
    status = json['status'];
    totalQty = json['total_qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['customer_name'] = customerName;
    data['due_date'] = dueDate;
    data['grand_total'] = grandTotal;
    data['status'] = status;
    data['total_qty'] = totalQty;
    return data;
  }
}
