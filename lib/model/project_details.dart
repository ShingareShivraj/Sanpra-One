class ProjectLeadDetails {
  List<String>? territory;
  List<String>? projectLeadType;
  List<String>? projectPlan;
  List<String>? siteStatus;

  ProjectLeadDetails(
      {this.territory,
      this.projectLeadType,
      this.projectPlan,
      this.siteStatus});

  ProjectLeadDetails.fromJson(Map<String, dynamic> json) {
    territory = json['territory'].cast<String>();
    projectLeadType = json['project_lead_type'].cast<String>();
    projectPlan = json['project_plan'].cast<String>();
    siteStatus = json['site_status'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['territory'] = this.territory;
    data['project_lead_type'] = this.projectLeadType;
    data['project_plan'] = this.projectPlan;
    data['site_status'] = this.siteStatus;
    return data;
  }
}
