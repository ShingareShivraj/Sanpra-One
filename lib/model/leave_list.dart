class LeaveListDetails {
  List<Upcoming>? upcoming;
  List<Taken>? taken;
  List<Balance>? balance;

  LeaveListDetails({this.upcoming, this.taken, this.balance});

  LeaveListDetails.fromJson(Map<String, dynamic> json) {
    if (json['upcoming'] != null) {
      upcoming = <Upcoming>[];
      json['upcoming'].forEach((v) {
        upcoming!.add(Upcoming.fromJson(v));
      });
    }
    if (json['taken'] != null) {
      taken = <Taken>[];
      json['taken'].forEach((v) {
        taken!.add(Taken.fromJson(v));
      });
    }
    if (json['balance'] != null) {
      balance = <Balance>[];
      json['balance'].forEach((v) {
        balance!.add(Balance.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (upcoming != null) {
      data['upcoming'] = upcoming!.map((v) => v.toJson()).toList();
    }
    if (taken != null) {
      data['taken'] = taken!.map((v) => v.toJson()).toList();
    }
    if (balance != null) {
      data['balance'] = balance!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Upcoming {
  String? name;
  String? leaveType;
  String? fromDate;
  String? toDate;
  String? description;
  String? status;
  int? docstatus;
  int? halfDay;
  String? halfDayDate;
  String? postingDate;

  Upcoming(
      {this.name,
      this.leaveType,
      this.fromDate,
      this.toDate,
      this.description,
      this.status,
      this.docstatus,
      this.halfDay,
      this.halfDayDate,
      this.postingDate});

  Upcoming.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    leaveType = json['leave_type'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    description = json['description'];
    status = json['status'];
    docstatus = json['docstatus'];
    halfDay = json['half_day'];
    halfDayDate = json['half_day_date'];
    postingDate = json['posting_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['leave_type'] = leaveType;
    data['from_date'] = fromDate;
    data['to_date'] = toDate;
    data['description'] = description;
    data['status'] = status;
    data['docstatus'] = docstatus;
    data['half_day'] = halfDay;
    data['half_day_date'] = halfDayDate;
    data['posting_date'] = postingDate;
    return data;
  }
}

class Taken {
  String? name;
  String? leaveType;
  String? fromDate;
  String? toDate;
  String? description;
  String? status;
  int? docstatus;
  int? halfDay;
  String? halfDayDate;
  String? postingDate;

  Taken(
      {this.name,
      this.leaveType,
      this.fromDate,
      this.toDate,
      this.description,
      this.status,
      this.docstatus,
      this.halfDay,
      this.halfDayDate,
      this.postingDate});

  Taken.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    leaveType = json['leave_type'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    description = json['description'];
    status = json['status'];
    docstatus = json['docstatus'];
    halfDay = json['half_day'];
    halfDayDate = json['half_day_date'];
    postingDate = json['posting_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['leave_type'] = leaveType;
    data['from_date'] = fromDate;
    data['to_date'] = toDate;
    data['description'] = description;
    data['status'] = status;
    data['docstatus'] = docstatus;
    data['half_day'] = halfDay;
    data['half_day_date'] = halfDayDate;
    data['posting_date'] = postingDate;
    return data;
  }
}

class Balance {
  String? leaveType;
  String? employee;
  String? employeeName;
  double? leavesAllocated;
  double? leavesExpired;
  double? openingBalance;
  double? leavesTaken;
  double? closingBalance;
  int? indent;

  Balance(
      {this.leaveType,
      this.employee,
      this.employeeName,
      this.leavesAllocated,
      this.leavesExpired,
      this.openingBalance,
      this.leavesTaken,
      this.closingBalance,
      this.indent});

  Balance.fromJson(Map<String, dynamic> json) {
    leaveType = json['leave_type'];
    employee = json['employee'];
    employeeName = json['employee_name'];
    leavesAllocated = json['leaves_allocated'];
    leavesExpired = json['leaves_expired'];
    openingBalance = json['opening_balance'];
    leavesTaken = json['leaves_taken'];
    closingBalance = json['closing_balance'];
    indent = json['indent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['leave_type'] = leaveType;
    data['employee'] = employee;
    data['employee_name'] = employeeName;
    data['leaves_allocated'] = leavesAllocated;
    data['leaves_expired'] = leavesExpired;
    data['opening_balance'] = openingBalance;
    data['leaves_taken'] = leavesTaken;
    data['closing_balance'] = closingBalance;
    data['indent'] = indent;
    return data;
  }
}
