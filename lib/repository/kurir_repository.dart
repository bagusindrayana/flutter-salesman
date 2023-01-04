import 'package:dio/dio.dart';
import 'package:salesman/model/api_response.dart';
import 'package:salesman/model/user.dart';
import 'package:salesman/model/pembayaran.dart';
import 'package:salesman/provider/api_provider.dart';

class AllKurirResponse {
  String? message;
  int? status;
  List<User>? data;
  AllKurirResponse({this.message, this.status, this.data});
  AllKurirResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'] ?? null;
    if (json['data'] != null) {
      data = <User>[];
      json['data'].forEach((v) {
        data!.add(new User.fromJson(v));
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

class KurirResponse {
  String? message;
  int? status;
  User? data;
  KurirResponse({this.message, this.status, this.data});
  KurirResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'] ?? null;
    data = new User.fromJson(json['data']);
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

class KurirRepository {
  //get all Kurir
  Future<AllKurirResponse> getAllKurir(String token) async {
    try {
      var url = "/kurir";
      var response =
          await ApiProvider.get(url, {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        var d = AllKurirResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return AllKurirResponse(status: 500, message: "Gagal mengambil data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        return AllKurirResponse(
            status: e.response!.statusCode,
            message: "Gagal mengambil data. ${e.message}");
      } else {
        print(t);
        return AllKurirResponse(
            status: 500, message: "Gagal mengambil data. ${e}");
      }
    }
  }

  //create kurir
  Future<KurirResponse> createKurir(String token, User kurir) async {
    try {
      var url = "/kurir";
      var data = kurir.toJson();
      data['level'] = "kurir";
      print(data);
      var response =
          await ApiProvider.post(url, data, {"Authorization": "Bearer $token"});
      print(response.statusCode);
      if (response.statusCode == 200) {
        var d = KurirResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return KurirResponse(status: 500, message: "Gagal menambah data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return KurirResponse(
            status: e.response!.statusCode,
            message: "Gagal menambah data. ${e.message}");
      } else {
        print(e);
        print(t);
        return KurirResponse(status: 500, message: "Gagal menambah data. ${e}");
      }
    }
  }

  //update kurir
  Future<KurirResponse> updateKurir(String token, User kurir) async {
    try {
      var url = "/kurir/${kurir.sId}";
      var data = kurir.toJson();
      print("ubah");
      var response =
          await ApiProvider.post(url, data, {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        var d = KurirResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return KurirResponse(status: 500, message: "Gagal mengubah data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return KurirResponse(
            status: e.response!.statusCode,
            message: "Gagal mengubah data. ${e.message}");
      } else {
        print(e);
        print(t);
        return KurirResponse(status: 500, message: "Gagal mengubah data. ${e}");
      }
    }
  }

  Future<KurirResponse> detailKurir(String token, String kurir_id) async {
    try {
      var url = "/kurir/$kurir_id";

      var response =
          await ApiProvider.get(url, {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        var d = KurirResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return KurirResponse(status: 500, message: "Gagal mengambil data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return KurirResponse(
            status: e.response!.statusCode,
            message: "Gagal mengambil data. ${e.message}");
      } else {
        print(e);
        print(t);
        return KurirResponse(
            status: 500, message: "Gagal mengambil data. ${e}");
      }
    }
  }

  Future<KurirResponse> hapusKurir(String token, String kurir_id) async {
    try {
      var url = "/kurir/${kurir_id}/delete";

      var response =
          await ApiProvider.post(url, null, {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        var d = KurirResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return KurirResponse(status: 500, message: "Gagal menghapus data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return KurirResponse(
            status: e.response!.statusCode,
            message: "Gagal menghapus data. ${e.message}");
      } else {
        print(e);
        print(t);
        return KurirResponse(
            status: 500, message: "Gagal menghapus data. ${e}");
      }
    }
  }
}
