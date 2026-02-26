class CustomerList {
  String? name;
  String? customerName;
  String? customerGroup;
  String? territory;
  String? gstCategory;
  String? owner;
  double? outstanding;
  String? salesPerson;

  CustomerList(
      {this.name,
        this.customerName,
        this.customerGroup,
        this.territory,
        this.gstCategory,
        this.owner,
        this.outstanding,
        this.salesPerson});

  CustomerList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    customerName = json['customer_name'];
    customerGroup = json['customer_group'];
    territory = json['territory'];
    gstCategory = json['gst_category'];
    owner = json['owner'];
    outstanding = json['outstanding'];
    salesPerson = json['sales_person'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['customer_name'] = this.customerName;
    data['customer_group'] = this.customerGroup;
    data['territory'] = this.territory;
    data['gst_category'] = this.gstCategory;
    data['owner'] = this.owner;
    data['outstanding'] = this.outstanding;
    data['sales_person'] = this.salesPerson;
    return data;
  }
}
