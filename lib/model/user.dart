class User {
  String? sId;
  String? username;
  String? password;
  String? token;

  User({this.sId, this.username, this.password, this.token});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    password = json['password'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['password'] = this.password;
    data['token'] = this.token;
    return data;
  }
}
