class ExpenseData {
  String? name;
  int? docstatus;
  String? expenseType;
  String? expenseDescription;
  String? expenseDate;
  double? amount;
  double? rate;
  double? km;
  List<Attachments>? attachments;

  ExpenseData(
      {this.expenseType,
      this.name,
      this.docstatus,
      this.expenseDescription,
      this.expenseDate,
      this.amount,
      this.rate,
      this.km,
      this.attachments});

  ExpenseData.fromJson(Map<String, dynamic> json) {
    expenseType = json['expense_type'];
    expenseDescription = json['expense_description'];
    expenseDate = json['expense_date'];
    docstatus = json['docstatus'];
    name = json['name'];
    km = json["custom_rate"];
    rate = json["custom_rate"];
    amount = json['amount'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['expense_type'] = expenseType;
    data['expense_description'] = expenseDescription;
    data['expense_date'] = expenseDate;
    data['docstatus'] = docstatus;
    data['custom_rate'] = rate;
    data['custom_km'] = km;
    data['name'] = name;
    data['amount'] = amount;
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attachments {
  String? name;
  String? fileName;
  String? fileUrl;
  Attachments({this.name, this.fileName, this.fileUrl});

  Attachments.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fileName = json['file_name'];
    fileUrl = json["file_url"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['file_name'] = fileName;
    data['file_url'] = fileUrl;
    return data;
  }
}
