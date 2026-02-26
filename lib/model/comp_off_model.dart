class CompOff {
  String? name;
  String? owner;
  String? modifiedBy;
  int? docstatus;
  int? idx;

  String? leaveType;
  String? workFromDate;
  String? workEndDate;
  int? halfDay;
  String? reason;
  String? halfDayDate;

  CompOff(
      {this.name,
      this.owner,
      this.modifiedBy,
      this.docstatus,
      this.idx,
      this.leaveType,
      this.workFromDate,
      this.workEndDate,
      this.halfDay,
      this.reason,
      this.halfDayDate});

  CompOff.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];

    leaveType = json['leave_type'];
    workFromDate = json['work_from_date'];
    workEndDate = json['work_end_date'];
    halfDay = json['half_day'];
    reason = json['reason'];
    halfDayDate = json['half_day_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['owner'] = this.owner;
    data['modified_by'] = this.modifiedBy;
    data['docstatus'] = this.docstatus;
    data['idx'] = this.idx;

    data['leave_type'] = this.leaveType;
    data['work_from_date'] = this.workFromDate;
    data['work_end_date'] = this.workEndDate;
    data['half_day'] = this.halfDay;
    data['reason'] = this.reason;
    data['half_day_date'] = this.halfDayDate;
    return data;
  }
}
