class attendancedetails {
  AttendanceDetails? attendanceDetails;
  List<AttendanceList>? attendanceList;

  attendancedetails({this.attendanceDetails, this.attendanceList});

  attendancedetails.fromJson(Map<String, dynamic> json) {
    attendanceDetails = json['attendance_details'] != null
        ? AttendanceDetails.fromJson(json['attendance_details'])
        : null;
    if (json['attendance_list'] != null) {
      attendanceList = <AttendanceList>[];
      json['attendance_list'].forEach((v) {
        attendanceList!.add(AttendanceList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (attendanceDetails != null) {
      data['attendance_details'] = attendanceDetails!.toJson();
    }
    if (attendanceList != null) {
      data['attendance_list'] =
          attendanceList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AttendanceDetails {
  int? daysInMonth;
  int? present;
  int? absent;
  int? late;
  int? halfDay;
  int? onLeave;

  AttendanceDetails(
      {this.daysInMonth,
        this.present,
        this.absent,
        this.late,
        this.halfDay,
        this.onLeave});

  AttendanceDetails.fromJson(Map<String, dynamic> json) {
    daysInMonth = json['days_in_month'];
    present = json['present'];
    absent = json['absent'];
    late = json['late'];
    halfDay = json['half day'];
    onLeave = json['on leave'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['days_in_month'] = daysInMonth;
    data['present'] = present;
    data['absent'] = absent;
    data['late'] = late;
    data['half day'] = halfDay;
    data['on leave'] = onLeave;
    return data;
  }
}


class AttendanceList {
  String? attendanceDate;
  String? status;
  double? workingHours;
  String? inTime;
  String? outTime;

  AttendanceList(
      {this.attendanceDate,
        this.status,
        this.workingHours,
        this.inTime,
        this.outTime});

  AttendanceList.fromJson(Map<String, dynamic> json) {
    attendanceDate = json['attendance_date'];
    status = json['status'];
    workingHours = json['working_hours'];
    inTime = json['in_time'];
    outTime = json['out_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['attendance_date'] = attendanceDate;
    data['status'] = status;
    data['working_hours'] = workingHours;
    data['in_time'] = inTime;
    data['out_time'] = outTime;
    return data;
  }
}
