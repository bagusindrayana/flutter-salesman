class Pelanggan {
  String? sId;
  String? namaUsaha;
  String? namaPemilik;
  String? alamat;
  String? noTelp;
  String? latitude;
  String? longitude;
  String? waktuDibuat;
  int totalTagihan = 0;
  int totalBayar = 0;

  Pelanggan(
      {this.sId,
      this.namaUsaha,
      this.namaPemilik,
      this.alamat,
      this.noTelp,
      this.latitude,
      this.longitude,
      this.waktuDibuat,
      this.totalTagihan = 0,
      this.totalBayar = 0});

  Pelanggan.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    namaUsaha = json['nama_usaha'];
    namaPemilik = json['nama_pemilik'];
    alamat = json['alamat'];
    noTelp = json['no_telp'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    waktuDibuat = json['waktu_dibuat'];
    totalTagihan = json['total_tagihan'] ?? 0;
    totalBayar = json['total_bayar'] ?? 0;
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
    data['total_tagihan'] = this.totalTagihan;
    data['total_bayar'] = this.totalBayar;
    return data;
  }
}
