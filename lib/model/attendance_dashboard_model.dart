class AttendanceDashboard {
  String? monthTitle;
  int? tillDays;
  int? totalDays;
  double? dayOff;
  double? present;
  double? absent;

  AttendanceDashboard(
      {this.monthTitle,
        this.tillDays,
        this.totalDays,
        this.dayOff,
        this.present,
        this.absent});

  AttendanceDashboard.fromJson(Map<String, dynamic> json) {
    monthTitle = json['month_title'];
    tillDays = json['till_days'];
    totalDays = json['total_days'];
    dayOff = json['day off'];
    present = json['present'];
    absent = json['absent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['month_title'] = monthTitle;
    data['till_days'] = tillDays;
    data['total_days'] = totalDays;
    data['day off'] = dayOff;
    data['present'] = present;
    data['absent'] = absent;
    return data;
  }

}
