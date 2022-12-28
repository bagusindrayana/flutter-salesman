import 'package:dio/dio.dart';
import 'package:salesman/model/api_response.dart';
import 'package:salesman/model/pelanggan.dart';
import 'package:salesman/model/pembayaran.dart';
import 'package:salesman/provider/api_provider.dart';

class AllPelangganResponse {
  String? message;
  int? status;
  List<Pelanggan>? data;
  AllPelangganResponse({this.message, this.status, this.data});
  AllPelangganResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'] ?? null;
    if (json['data'] != null) {
      data = <Pelanggan>[];
      json['data'].forEach((v) {
        data!.add(new Pelanggan.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PelangganResponse {
  String? message;
  int? status;
  Pelanggan? data;
  PelangganResponse({this.message, this.status, this.data});
  PelangganResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'] ?? null;
    data = new Pelanggan.fromJson(json['data']);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['data'] = this.data!.toJson();
    return data;
  }
}

class PembayaranResponse {
  String? message;
  int? status;
  Pembayaran? data;
  PembayaranResponse({this.message, this.status, this.data});
  PembayaranResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'] ?? null;
    data = Pembayaran.fromJson(json['data']);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['data'] = this.data!.toJson();
    return data;
  }
}

class PelangganRepository {
  //get all Pelanggan
  Future<AllPelangganResponse> getAllPelanggan(String token) async {
    try {
      var url = "/pelanggan";
      var response =
          await ApiProvider.get(url, {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        var d = AllPelangganResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return AllPelangganResponse(
            status: 500, message: "Gagal mengambil data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        return AllPelangganResponse(
            status: e.response!.statusCode,
            message: "Gagal mengambil data. ${e.message}");
      } else {
        print(t);
        return AllPelangganResponse(
            status: 500, message: "Gagal mengambil data. ${e}");
      }
    }
  }

  //create pelanggan
  Future<PelangganResponse> createPelanggan(String token, Pelanggan pelanggan,
      String tanggal_tagihan, String total_tagihan, String keterangan) async {
    try {
      var url = "/pelanggan";
      var data = pelanggan.toJson();
      data['tanggal_tagihan'] = tanggal_tagihan;
      data['total_tagihan'] = total_tagihan;
      data['keterangan'] = keterangan;
      var response =
          await ApiProvider.post(url, data, {"Authorization": "Bearer $token"});
      print("tambah");
      print(response.statusCode);
      if (response.statusCode == 200) {
        var d = PelangganResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return PelangganResponse(status: 500, message: "Gagal menambah data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return PelangganResponse(
            status: e.response!.statusCode,
            message: "Gagal menambah data. ${e.message}");
      } else {
        print(e);
        print(t);
        return PelangganResponse(
            status: 500, message: "Gagal menambah data. ${e}");
      }
    }
  }

  //update pelanggan
  Future<PelangganResponse> updatePelanggan(
      String token, Pelanggan pelanggan) async {
    try {
      var url = "/pelanggan/${pelanggan.sId}";
      var data = pelanggan.toJson();
      print("ubah");
      var response =
          await ApiProvider.post(url, data, {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        var d = PelangganResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return PelangganResponse(status: 500, message: "Gagal mengubah data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return PelangganResponse(
            status: e.response!.statusCode,
            message: "Gagal mengubah data. ${e.message}");
      } else {
        print(e);
        print(t);
        return PelangganResponse(
            status: 500, message: "Gagal mengubah data. ${e}");
      }
    }
  }

  Future<PelangganResponse> detailPelanggan(
      String token, String pelanggan_id) async {
    try {
      var url = "/pelanggan/$pelanggan_id";

      var response =
          await ApiProvider.get(url, {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        var d = PelangganResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return PelangganResponse(status: 500, message: "Gagal mengambil data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return PelangganResponse(
            status: e.response!.statusCode,
            message: "Gagal mengambil data. ${e.message}");
      } else {
        print(e);
        print(t);
        return PelangganResponse(
            status: 500, message: "Gagal mengambil data. ${e}");
      }
    }
  }

  Future<ApiResponse> tagihanPelangganMingguIni(String token) async {
    try {
      var url = "/tagihan-minggu-ini";
      var response =
          await ApiProvider.get(url, {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        var d = ApiResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return ApiResponse(status: 500, message: "Gagal mengambil data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        return ApiResponse(
            status: e.response!.statusCode,
            message: "Gagal mengambil data. ${e.message}");
      } else {
        print(e);
        print(t);
        return ApiResponse(status: 500, message: "Gagal mengambil data. ${e}");
      }
    }
  }

  Future<PembayaranResponse> bayarTagihan(String token, String pelanggan_id,
      String total_bayar, String tanggal_bayar, String keterangan) async {
    try {
      var url = "/tambah-pembayaran/${pelanggan_id}";
      var response = await ApiProvider.post(url, {
        'total_bayar': total_bayar,
        'tanggal_bayar': tanggal_bayar,
        'keterangan': keterangan
      }, {
        "Authorization": "Bearer $token"
      });
      if (response.statusCode == 200) {
        var d = PembayaranResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return PembayaranResponse(status: 500, message: "Gagal menambah data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        return PembayaranResponse(
            status: e.response!.statusCode,
            message: "Gagal menambah data. ${e.message}");
      } else {
        print(e);
        print(t);
        return PembayaranResponse(
            status: 500, message: "Gagal menambah data. ${e}");
      }
    }
  }

  Future<ApiResponse> riwayatPembayaran(
      String token, String pelanggan_id) async {
    try {
      var url = "/riwayat-pembayaran/${pelanggan_id}";
      var response =
          await ApiProvider.get(url, {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        var d = ApiResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return ApiResponse(status: 500, message: "Gagal menambah data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        return ApiResponse(
            status: e.response!.statusCode,
            message: "Gagal menambah data. ${e.message}");
      } else {
        print(e);
        print(t);
        return ApiResponse(status: 500, message: "Gagal menambah data. ${e}");
      }
    }
  }
}
