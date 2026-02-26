class Items {
  String? name;

  String? itemCode;
  String? itemName;

  String? image;

  int? rate;

  int? actualQty;

  Items({
    this.name,
    this.itemCode,
    this.itemName,
    this.image,
    this.rate,
    this.actualQty,
  });

  Items.fromJson(Map<String, dynamic> json) {
    name = json['name'];

    itemCode = json['item_code'];
    itemName = json['item_name'];

    image = json['image'];

    rate = json['rate'];

    actualQty = json['actual_qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;

    data['item_code'] = this.itemCode;
    data['item_name'] = this.itemName;

    data['image'] = this.image;

    data['rate'] = this.rate;

    data['actual_qty'] = this.actualQty;

    return data;
  }
}
