class User {
  String? sId;
  String? nama;
  String? username;
  String? password;
  String? token;
  String? level;
  int totalTagihan = 0;
  int totalBayar = 0;

  User(
      {this.sId,
      this.nama,
      this.username,
      this.password,
      this.token,
      this.level,
      this.totalTagihan = 0,
      this.totalBayar = 0});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    nama = json['nama'];
    username = json['username'];
    password = json['password'];
    token = json['token'];
    level = json['level'];
    totalTagihan = json['total_tagihan'] ?? 0;
    totalBayar = json['total_bayar'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['nama'] = this.nama;
    data['username'] = this.username;
    data['password'] = this.password;
    data['token'] = this.token;
    data['level'] = this.level;
    data['total_tagihan'] = this.totalTagihan;
    data['total_bayar'] = this.totalBayar;
    return data;
  }
}
