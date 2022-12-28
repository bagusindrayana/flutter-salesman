class User {
  String? sId;
  String? username;
  String? password;
  String? token;
  String? level;

  User({this.sId, this.username, this.password, this.token});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    password = json['password'];
    token = json['token'];
    level = json['level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['password'] = this.password;
    data['token'] = this.token;
    data['level'] = this.level;
    return data;
  }
}
