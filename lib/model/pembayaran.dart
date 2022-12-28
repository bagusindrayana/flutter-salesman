import 'package:salesman/model/pelanggan.dart';

class Pembayaran {
  String? pelangganId;
  String? tanggalBayar;
  int? totalBayar;
  String? keterangan;
  String? sId;
  String? waktuDibuat;
  Pelanggan? pelanggan;

  Pembayaran(
      {this.pelangganId,
      this.tanggalBayar,
      this.totalBayar,
      this.keterangan,
      this.sId,
      this.waktuDibuat,
      this.pelanggan});

  Pembayaran.fromJson(Map<String, dynamic> json) {
    pelangganId = json['pelanggan_id'];
    tanggalBayar = json['tanggal_bayar'];
    totalBayar = json['total_bayar'];
    keterangan = json['keterangan'];
    sId = json['_id'];
    waktuDibuat = json['waktu_dibuat'];
    pelanggan = json['pelanggan'] != null
        ? new Pelanggan.fromJson(json['pelanggan'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pelanggan_id'] = this.pelangganId;
    data['tanggal_bayar'] = this.tanggalBayar;
    data['total_bayar'] = this.totalBayar;
    data['keterangan'] = this.keterangan;
    data['_id'] = this.sId;
    data['waktu_dibuat'] = this.waktuDibuat;
    if (this.pelanggan != null) {
      data['pelanggan'] = this.pelanggan!.toJson();
    }
    return data;
  }
}
