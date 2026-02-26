class AddLeadModel {
  String? name;
  String? owner;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? namingSeries;
  String? salutation;
  String? firstName;
  String? lastName;
  String? leadName;
  String? gender;
  String? source;
  String? leadOwner;
  String? customProject;
  String? type;
  String? requestType;
  String? emailId;
  String? mobileNo;
  String? whatsappNo;
  String? phone;
  String? companyName;
  String? noOfEmployees;
  double? annualRevenue;
  String? territory;
  String? city;
  String? address;
  int? pincode;
  String? gstIn;
  String? state;
  String? country;
  String? industry;
  String? qualificationStatus;
  String? company;
  String? language;
  String? customCallStatus;
  String? image;
  String? title;
  int? disabled;
  int? unsubscribed;
  int? blogSubscriber;
  String? doctype;
  String? customer;
  String? status;
  String? latitude;
  String? longitude;
  String? description;
  String? locationAddress;
  List<Notes>? notes;
  String? photo;

  AddLeadModel(
      {this.name,
      this.owner,
      this.modifiedBy,
      this.docstatus,
      this.status,
      this.idx,
      this.namingSeries,
      this.salutation,
      this.firstName,
      this.lastName,
      this.leadName,
      this.gender,
      this.address,
      this.pincode,
      this.gstIn,
      this.source,
      this.leadOwner,
      this.type,
      this.requestType,
      this.customProject,
      this.emailId,
      this.mobileNo,
      this.whatsappNo,
      this.phone,
      this.companyName,
      this.noOfEmployees,
      this.annualRevenue,
      this.territory,
      this.city,
      this.state,
      this.country,
      this.industry,
      this.qualificationStatus,
      this.company,
      this.language,
      this.image,
      this.title,
      this.customCallStatus,
      this.disabled,
      this.unsubscribed,
      this.blogSubscriber,
      this.latitude,
      this.longitude,
      this.customer,
      this.locationAddress,
      this.description,
      this.doctype,
      this.photo,
      this.notes});

  AddLeadModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    namingSeries = json['naming_series'];
    salutation = json['salutation'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    status = json['status'];
    leadName = json['lead_name'];
    gender = json['gender'];
    source = json['source'];
    leadOwner = json['lead_owner'];
    type = json['type'];
    requestType = json['request_type'];
    emailId = json['email_id'];
    gstIn = json['custom_gst_in'];
    address = json['custom_address'];
    pincode = json['custom_pincode'];
    customProject = json['custom_project'];
    mobileNo = json['mobile_no'];
    whatsappNo = json['whatsapp_no'];
    phone = json['phone'];
    companyName = json['company_name'];
    noOfEmployees = json['no_of_employees'];
    annualRevenue = json['annual_revenue'];
    territory = json['territory'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    industry = json['industry'];
    qualificationStatus = json['qualification_status'];
    company = json['company'];
    language = json['language'];
    customCallStatus = json['custom_call_status'];
    image = json['image'];
    title = json['title'];
    disabled = json['disabled'];
    unsubscribed = json['unsubscribed'];
    blogSubscriber = json['blog_subscriber'];
    latitude = json['custom_latitude'];
    longitude = json['custom_longitude'];
    customer = json["customer"];
    description = json["custom_description"];
    locationAddress = json['custom_location_address'];
    photo = json["image"];
    doctype = json['doctype'];
    if (json['notes'] != null) {
      notes = <Notes>[];
      json['notes'].forEach((v) {
        notes!.add(Notes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['status'] = status;
    data['naming_series'] = namingSeries;
    data['salutation'] = salutation;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['lead_name'] = leadName;
    data['gender'] = gender;
    data['source'] = source;
    data['lead_owner'] = leadOwner;
    data['type'] = type;
    data['custom_address'] = address;
    data['custom_gst_in'] = gstIn;
    data['custom_pincode'] = pincode;
    data['request_type'] = requestType;
    data['email_id'] = emailId;
    data['mobile_no'] = mobileNo;
    data['whatsapp_no'] = whatsappNo;
    data['phone'] = phone;
    data['custom_project'] = customProject;
    data['company_name'] = companyName;
    data['no_of_employees'] = noOfEmployees;
    data['annual_revenue'] = annualRevenue;
    data['territory'] = territory;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['industry'] = industry;
    data['qualification_status'] = qualificationStatus;
    data['company'] = company;
    data['language'] = language;
    data['image'] = image;
    data['title'] = title;
    data['custom_call_status'] = customCallStatus;
    data['disabled'] = disabled;
    data["customer"] = customer;
    data['unsubscribed'] = unsubscribed;
    data['blog_subscriber'] = blogSubscriber;
    data['custom_latitude'] = latitude;
    data['custom_longitude'] = longitude;
    data['custom_description'] = description;
    data['custom_location_address'] = locationAddress;
    data['image'] = photo;
    data['doctype'] = doctype;
    if (notes != null) {
      data['notes'] = notes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Notes {
  int? name;
  String? owner;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? note;
  String? addedBy;
  String? parent;
  String? parentfield;
  String? parenttype;
  String? doctype;

  Notes(
      {this.name,
      this.owner,
      this.modifiedBy,
      this.docstatus,
      this.idx,
      this.note,
      this.addedBy,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.doctype});

  Notes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    note = json['note'];
    addedBy = json['added_by'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['note'] = note;
    data['added_by'] = addedBy;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['doctype'] = doctype;
    return data;
  }
}
