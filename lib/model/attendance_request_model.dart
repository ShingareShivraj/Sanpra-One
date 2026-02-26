class AttendanceRequest {
  String? name;
  String? fromDate;
  String? toDate;
  int? halfDay;
  String? halfDayDate;
  int? includeHolidays;
  String? shift;
  String? reason;
  String? explanation;

  AttendanceRequest(
      {this.name,
      this.fromDate,
      this.toDate,
      this.halfDay,
      this.halfDayDate,
      this.includeHolidays,
      this.shift,
      this.reason,
      this.explanation});

  AttendanceRequest.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    halfDay = json['half_day'];
    halfDayDate = json['half_day_date'];
    includeHolidays = json['include_holidays'];
    shift = json['shift'];
    reason = json['reason'];
    explanation = json['explanation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['from_date'] = this.fromDate;
    data['to_date'] = this.toDate;
    data['half_day'] = this.halfDay;
    data['half_day_date'] = this.halfDayDate;
    data['include_holidays'] = this.includeHolidays;
    data['shift'] = this.shift;
    data['reason'] = this.reason;
    data['explanation'] = this.explanation;
    return data;
  }
}
