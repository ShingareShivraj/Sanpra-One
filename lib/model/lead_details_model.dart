class LeadDetails {
  List<String>? territories;
  List<String>? leadSource;
  List<String>? industryType;
  List<String>? customer;
  List<String>? projects;

  LeadDetails(
      {this.territories,
      this.leadSource,
      this.industryType,
      this.customer,
      this.projects});

  LeadDetails.fromJson(Map<String, dynamic> json) {
    territories = (json['territory'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    leadSource = (json['lead_source'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    industryType = (json['industry_type'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    customer = (json['customer'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    projects = (json['project'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['territory'] = this.territories;
    data['lead_source'] = this.leadSource;
    data['industry_type'] = this.industryType;
    data['customer'] = this.customer;
    data['project'] = this.projects;
    return data;
  }
}
