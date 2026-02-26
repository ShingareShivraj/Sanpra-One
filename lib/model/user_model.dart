class User {
  String? name;
  String? email;
  String? fullName;
  String? username;
  String? userImage;
  String? gender;
  String? birthDate;
  List<Roles>? roles;

  User(
      {this.name,
        this.email,
        this.fullName,
        this.username,
        this.userImage,
        this.gender,
        this.birthDate,
        this.roles});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    fullName = json['full_name'];
    username = json['username'];
    userImage = json['user_image'];
    gender = json['gender'];
    birthDate = json['birth_date'];
    if (json['roles'] != null) {
      roles = <Roles>[];
      json['roles'].forEach((v) {
        roles!.add(Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['full_name'] = fullName;
    data['username'] = username;
    data['user_image'] = userImage;
    data['gender'] = gender;
    data['birth_date'] = birthDate;
    if (roles != null) {
      data['roles'] = roles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  String? name;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? role;
  String? parent;

  Roles(
      {this.name,
        this.modifiedBy,
        this.docstatus,
        this.idx,
        this.role,
        this.parent});

  Roles.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    role = json['role'];
    parent = json['parent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['role'] = role;
    data['parent'] = parent;
    return data;
  }
}
