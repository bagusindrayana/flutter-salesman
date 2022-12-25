import 'package:dio/dio.dart';
import 'package:salesman/model/pelanggan.dart';
import 'package:salesman/provider/api_provider.dart';

class StatResponse {
  String? message;
  int? status;
  dynamic? data;
  StatResponse({this.message, this.status, this.data});
  StatResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'] ?? null;
    data = json['data'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['data'] = this.data;
    return data;
  }
}

class StatRepository {
  Future<StatResponse> getStat(String token) async {
    try {
      var url = "/stat";
      var response =
          await ApiProvider.get(url, {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        var d = StatResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return StatResponse(status: 500, message: "Gagal mengambil data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return StatResponse(
            status: e.response!.statusCode,
            message: "Gagal mengambil data. ${e.message}");
      } else {
        print(e);
        print(t);
        return StatResponse(status: 500, message: "Gagal mengambil data. ${e}");
      }
    }
  }
}
