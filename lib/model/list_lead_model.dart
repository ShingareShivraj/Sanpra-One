class ListLeadModel {
  String? name;
  String? customLocationAddress;
  String? leadName;
  String? status;
  String? companyName;
  String? territory;
  String? creation;
  String? leadOwner;
  String? contactMobile;

  ListLeadModel(
      {this.name,
      this.customLocationAddress,
      this.leadName,
      this.status,
      this.companyName,
      this.territory,
      this.leadOwner,
      this.creation,
      this.contactMobile});

  ListLeadModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    customLocationAddress = json['custom_location_address'];
    leadName = json['lead_name'];
    status = json['status'];
    companyName = json['company_name'];
    territory = json['territory'];
    leadOwner = json['lead_owner'];
    creation = json['creation'];
    contactMobile: json["contact_mobile"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['custom_location_address'] = this.customLocationAddress;
    data['lead_name'] = this.leadName;
    data['status'] = this.status;
    data['company_name'] = this.companyName;
    data['territory'] = this.territory;
    data['lead_owner'] = this.leadOwner;
    data['creation'] = this.creation;
    data['contact_mobile']= this.contactMobile;
    return data;
  }
}
