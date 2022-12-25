class Tagihan {
  String? pelangganId;
  String? tanggalTagihan;
  int? totalTagihan;
  int? totalBayar;
  String? keterangan;
  List<dynamic>? pembayaran;
  String? sId;
  String? waktuDibuat;

  Tagihan(
      {this.pelangganId,
      this.tanggalTagihan,
      this.totalTagihan,
      this.totalBayar,
      this.keterangan,
      this.pembayaran,
      this.sId,
      this.waktuDibuat});

  Tagihan.fromJson(Map<String, dynamic> json) {
    pelangganId = json['pelanggan_id'];
    tanggalTagihan = json['tanggal_tagihan'];
    totalTagihan = json['total_tagihan'];
    totalBayar = json['total_bayar'];
    keterangan = json['keterangan'];
    pembayaran = json['pembayaran'];
    sId = json['_id'];
    waktuDibuat = json['waktu_dibuat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pelanggan_id'] = this.pelangganId;
    data['tanggal_tagihan'] = this.tanggalTagihan;
    data['total_tagihan'] = this.totalTagihan;
    data['total_bayar'] = this.totalBayar;
    data['keterangan'] = this.keterangan;
    data['pembayaran'] = this.pembayaran;
    data['_id'] = this.sId;
    data['waktu_dibuat'] = this.waktuDibuat;
    return data;
  }
}
