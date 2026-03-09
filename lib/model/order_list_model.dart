class OrderList {
  String? name;
  String? customerName;
  String? transactionDate;
  String? deliveryDate;
  double? grandTotal;
  String? status;
  String? deliveryStatus;
  double? totalQty;
  String? warehouse;
  String? owner;

  OrderList(
      {this.name,
      this.customerName,
      this.transactionDate,
      this.grandTotal,
      this.deliveryDate,
      this.status,
      this.deliveryStatus,
      this.warehouse,
      this.owner,
      this.totalQty});

  OrderList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    customerName = json['customer_name'];
    transactionDate = json['transaction_date'];
    grandTotal = json['grand_total'];
    deliveryDate = json["delivery_date"];
    deliveryStatus = json['delivery_status'];
    status = json['status'];
    warehouse = json['set_warehouse'];
    owner = json["owner"];
    totalQty = json['total_qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['customer_name'] = customerName;
    data['transaction_date'] = transactionDate;
    data['grand_total'] = grandTotal;
    data['delivery_date'] = deliveryDate;
    data['delivery_status'] = deliveryStatus;
    data['status'] = status;
    data["owner"] = owner;
    data['set_warehouse'] = warehouse;
    data['total_qty'] = totalQty;
    return data;
  }
}

class DeliverNoteList {
  String? name;
  String? customerName;
  String? transactionDate;
  double? grandTotal;
  String? status;
  double? totalQty;

  DeliverNoteList(
      {this.name,
      this.customerName,
      this.transactionDate,
      this.grandTotal,
      this.status,
      this.totalQty});

  DeliverNoteList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    customerName = json['customer_name'];
    transactionDate = json['posting_date'];
    grandTotal = json['grand_total'];
    status = json['status'];
    totalQty = json['total_qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['customer_name'] = customerName;
    data['posting_date'] = transactionDate;
    data['grand_total'] = grandTotal;
    data['status'] = status;
    data['total_qty'] = totalQty;
    return data;
  }
}
