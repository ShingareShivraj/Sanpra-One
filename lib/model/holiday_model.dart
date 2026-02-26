class HolidayList {
  String? year;
  String? date;
  String? day;
  String? description;

  HolidayList({this.year, this.date, this.day, this.description});

  HolidayList.fromJson(Map<String, dynamic> json) {
    year = json['year'];
    date = json['date'];
    day = json['day'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['year'] = this.year;
    data['date'] = this.date;
    data['day'] = this.day;
    data['description'] = this.description;
    return data;
  }
}
