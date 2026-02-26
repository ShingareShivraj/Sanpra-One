class RetailerSale {
  String? name;
  int? docstatus;
  int? idx;
  String? series;
  String? name1;
  String? date;
  int? qtyTotal;
  double? amountTotal;
  String? doctype;
  List<Items>? items;

  RetailerSale(
      {this.name,
      this.docstatus,
      this.idx,
      this.series,
      this.name1,
      this.date,
      this.qtyTotal,
      this.amountTotal,
      this.doctype,
      this.items});

  RetailerSale.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    series = json['series'];
    name1 = json['name1'];
    date = json['date'];
    qtyTotal = json['qty_total'];
    amountTotal = json['amount_total'];
    doctype = json['doctype'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['docstatus'] = this.docstatus;
    data['idx'] = this.idx;
    data['series'] = this.series;
    data['name1'] = this.name1;
    data['date'] = this.date;
    data['qty_total'] = this.qtyTotal;
    data['amount_total'] = this.amountTotal;
    data['doctype'] = this.doctype;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String? name;
  int? docstatus;
  int? idx;
  String? itemCode;
  String? itemName;
  String? uom;
  double? quantity;
  int? rate;
  int? amount;
  String? parent;
  String? parentfield;
  String? parenttype;
  String? doctype;

  Items(
      {this.name,
      this.docstatus,
      this.idx,
      this.itemCode,
      this.itemName,
      this.uom,
      this.quantity,
      this.rate,
      this.amount,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.doctype});

  Items.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    itemCode = json['item_code'];
    itemName = json['item_name'];
    uom = json['uom'];
    quantity = json['quantity'];
    rate = json['rate'];
    amount = json['amount'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['docstatus'] = this.docstatus;
    data['idx'] = this.idx;
    data['item_code'] = this.itemCode;
    data['item_name'] = this.itemName;
    data['uom'] = this.uom;
    data['quantity'] = this.quantity;
    data['rate'] = this.rate;
    data['amount'] = this.amount;
    data['parent'] = this.parent;
    data['parentfield'] = this.parentfield;
    data['parenttype'] = this.parenttype;
    data['doctype'] = this.doctype;
    return data;
  }
}
