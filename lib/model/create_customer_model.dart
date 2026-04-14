class CreateCustomer {
  String? name;
  String? customerName;
  String? customerType;
  String? customerGroup;
  String? territory;
  String? gstCategory;
  String? gstin;
  String? emailId;
  String? mobileNo;
  String? contactId;
  Billing? billing;
  Shipping? shipping;
  List<Map<String, dynamic>>? salesTeam;

  CreateCustomer(
      {this.name,
        this.customerName,
        this.customerType,
        this.customerGroup,
        this.territory,
        this.gstCategory,
        this.gstin,
        this.emailId,
        this.mobileNo,
        this.contactId,
        this.billing,
        this.shipping,
        this.salesTeam});

  CreateCustomer.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    customerName = json['customer_name'];
    customerType = json['customer_type'];
    customerGroup = json['customer_group'];
    territory = json['territory'];
    gstCategory = json['gst_category'];
    gstin = json['gstin'];
    emailId = json['email_id'];
    mobileNo = json['mobile_no'];
    contactId = json['contact_id'];
    billing =
    json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
    shipping = json['shipping'] != null
        ? new Shipping.fromJson(json['shipping'])
        : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (name != null && name!.isNotEmpty) {
      data['name'] = name;
    }
    data['customer_name'] = this.customerName;
    data['customer_type'] = this.customerType;
    data['customer_group'] = this.customerGroup;
    data['territory'] = this.territory;
    data['gst_category'] = this.gstCategory;
    data['gstin'] = this.gstin;
    data['email_id'] = this.emailId;
    data['mobile_no'] = this.mobileNo;
    if (contactId != null && contactId!.isNotEmpty) {
      data['contact_id'] = contactId;
    }
    if (billing != null && billing!.addressLine1 != null) {
      data['billing'] = billing!.toJson();
    }

    if (shipping != null && shipping!.addressLine1 != null) {
      data['shipping'] = shipping!.toJson();
    }
    if (salesTeam != null) {
      data['sales_team'] = salesTeam;
    }
    return data;
  }
}

class Billing {
  String? billingId;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? pincode;
  String? country;

  Billing(
      {this.billingId,
        this.addressLine1,
        this.addressLine2,
        this.city,
        this.state,
        this.pincode,
        this.country});

  Billing.fromJson(Map<String, dynamic> json) {
    billingId = json['billing_id'];
    addressLine1 = json['address_line1'];
    addressLine2 = json['address_line2'];
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (billingId != null) {
      data['billing_id'] = billingId;
    }

    data['address_line1'] = addressLine1;
    data['address_line2'] = addressLine2;
    data['city'] = city;
    data['state'] = state;
    data['pincode'] = pincode;
    data['country'] = country;

    return data;
  }
}

class Shipping {
  String? shippingId;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? pincode;
  String? country;

  Shipping(
      {this.shippingId,
        this.addressLine1,
        this.addressLine2,
        this.city,
        this.state,
        this.pincode,
        this.country});

  Shipping.fromJson(Map<String, dynamic> json) {
    shippingId = json['shipping_id'];
    addressLine1 = json['address_line1'];
    addressLine2 = json['address_line2'];
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (shippingId != null) {
      data['shipping_id'] = shippingId;
    }

    data['address_line1'] = addressLine1;
    data['address_line2'] = addressLine2;
    data['city'] = city;
    data['state'] = state;
    data['pincode'] = pincode;
    data['country'] = country;

    return data;
  }
}
