class Retailer {
  String? name;
  String? name1;
  String? mobile;
  String? email;
  String? addressLine1;
  String? city;
  String? state;
  int? pincode;
  String? doctype;

  Retailer(
      {this.name,
      this.name1,
      this.mobile,
      this.email,
      this.addressLine1,
      this.city,
      this.state,
      this.pincode,
      this.doctype});

  Retailer.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    name1 = json['name1'];
    mobile = json['mobile'];
    email = json['email'];
    addressLine1 = json['address_line_1'];
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['name1'] = this.name1;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['address_line_1'] = this.addressLine1;
    data['city'] = this.city;
    data['state'] = this.state;
    data['pincode'] = this.pincode;
    data['doctype'] = this.doctype;
    return data;
  }
}
