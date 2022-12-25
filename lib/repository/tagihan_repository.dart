import 'package:dio/dio.dart';
import 'package:salesman/model/tagihan.dart';
import 'package:salesman/provider/api_provider.dart';

class ListTagihanResponse {
  String? message;
  int? status;
  List<Tagihan>? data;
  ListTagihanResponse({this.message, this.status, this.data});
  ListTagihanResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'] ?? null;
    if (json['data'] != null) {
      data = <Tagihan>[];
      json['data'].forEach((v) {
        data!.add(new Tagihan.fromJson(v));
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

class TagihanRepository {
  //get all Tagihan
  Future<ListTagihanResponse> getAllTagihan(String token) async {
    try {
      var url = "/tagihan";
      var response =
          await ApiProvider.get(url, {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        var d = ListTagihanResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return ListTagihanResponse(
            status: 500, message: "Gagal mengambil data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        return ListTagihanResponse(
            status: e.response!.statusCode,
            message: "Gagal mengambil data. ${e.message}");
      } else {
        print(e);
        print(t);
        return ListTagihanResponse(
            status: 500, message: "Gagal mengambil data. ${e}");
      }
    }
  }

  Future<ListTagihanResponse> getTagihanByPelanggan(
      String token, String pelanggan_id) async {
    try {
      var url = "/tagihan-pelanggan/$pelanggan_id";
      var response =
          await ApiProvider.get(url, {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        print(response.data);
        var d = ListTagihanResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return ListTagihanResponse(
            status: 500, message: "Gagal mengambil data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        return ListTagihanResponse(
            status: e.response!.statusCode,
            message: "Gagal mengambil data. ${e.message}");
      } else {
        print(t);
        return ListTagihanResponse(
            status: 500, message: "Gagal mengambil data. ${e}");
      }
    }
  }
}
