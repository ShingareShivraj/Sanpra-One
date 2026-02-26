class ChangePassword {
  String? currentpassword;
  String? newpassword;

  ChangePassword(
      {this.currentpassword,
        this.newpassword,
       });

  ChangePassword.fromJson(Map<String, dynamic> json) {
    currentpassword = json['current_password'];
    newpassword = json['new_password'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['current_password'] = currentpassword;
    data['new_password'] = newpassword;
    return data;
  }
}
