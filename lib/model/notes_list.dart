class NotesList {
  int? name;
  String? note;
  String? commented;
  String? addedOn;
  String? image;

  NotesList({this.name, this.note, this.commented, this.addedOn, this.image});

  NotesList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    note = json['note'];
    commented = json['commented'];
    addedOn = json['added_on'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['note'] = note;
    data['commented'] = commented;
    data['added_on'] = addedOn;
    data['image'] = image;
    return data;
  }
}
