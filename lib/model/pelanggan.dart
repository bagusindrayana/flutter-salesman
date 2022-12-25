class Pelanggan {
  String? sId;
  String? namaUsaha;
  String? namaPemilik;
  String? alamat;
  String? noTelp;
  String? latitude;
  String? longitude;
  String? waktuDibuat;

  Pelanggan(
      {this.sId,
      this.namaUsaha,
      this.namaPemilik,
      this.alamat,
      this.noTelp,
      this.latitude,
      this.longitude,
      this.waktuDibuat});

  Pelanggan.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    namaUsaha = json['nama_usaha'];
    namaPemilik = json['nama_pemilik'];
    alamat = json['alamat'];
    noTelp = json['no_telp'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    waktuDibuat = json['waktu_dibuat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['nama_usaha'] = this.namaUsaha;
    data['nama_pemilik'] = this.namaPemilik;
    data['alamat'] = this.alamat;
    data['no_telp'] = this.noTelp;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['waktu_dibuat'] = this.waktuDibuat;
    return data;
  }
}
