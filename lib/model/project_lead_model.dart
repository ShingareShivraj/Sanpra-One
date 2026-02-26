class ProjectLead {
  String? name;
  String? owner;
  String? projectIs;
  String? projectType;
  String? postingDatetime;
  String? plan;
  String? siteStatus;
  String? contactPerson;
  String? mobileNumber;
  String? territory;
  String? address;
  String? city;
  String? state;
  String? pincode;
  String? description;
  String? doctype;

  ProjectLead(
      {this.name,
      this.owner,
      this.projectIs,
      this.projectType,
      this.postingDatetime,
      this.plan,
      this.siteStatus,
      this.contactPerson,
      this.mobileNumber,
      this.territory,
      this.address,
      this.city,
      this.state,
      this.pincode,
      this.description,
      this.doctype});

  ProjectLead.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    projectIs = json['project_is'];
    projectType = json['project_type'];
    postingDatetime = json['posting_datetime'];
    plan = json['plan'];
    siteStatus = json['site_status'];
    contactPerson = json['contact_person'];
    mobileNumber = json['mobile_number'];
    territory = json['territory'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
    description = json['description'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['owner'] = this.owner;
    data['project_is'] = this.projectIs;
    data['project_type'] = this.projectType;
    data['posting_datetime'] = this.postingDatetime;
    data['plan'] = this.plan;
    data['site_status'] = this.siteStatus;
    data['contact_person'] = this.contactPerson;
    data['mobile_number'] = this.mobileNumber;
    data['territory'] = this.territory;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['pincode'] = this.pincode;
    data['description'] = this.description;
    data['doctype'] = this.doctype;
    return data;
  }
}
