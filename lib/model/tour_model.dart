class Tour {
  String? name;
  String? owner;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? area;
  int? totalCalls;
  String? date;
  String? emplyoee;
  String? description;

  String? employeeName;
  String? doctype;

  Tour(
      {this.name,
      this.owner,
      this.modifiedBy,
      this.docstatus,
      this.idx,
      this.area,
      this.totalCalls,
      this.description,
      this.date,
      this.emplyoee,
      this.employeeName,
      this.doctype});

  Tour.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    area = json['area'];
    totalCalls = json['total_calls'];
    description = json['description'];
    date = json['date'];
    emplyoee = json['emplyoee'];
    employeeName = json['employee_name'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['area'] = area;
    data['total_calls'] = totalCalls;
    data['description'] = description;
    data['date'] = date;
    data['emplyoee'] = emplyoee;
    data['employee_name'] = employeeName;
    data['doctype'] = doctype;
    return data;
  }
}
