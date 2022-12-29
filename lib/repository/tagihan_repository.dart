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

class TagihanResponse {
  String? message;
  int? status;
  Tagihan? data;
  TagihanResponse({this.message, this.status, this.data});
  TagihanResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'] ?? null;
    data = new Tagihan.fromJson(json['data']);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['data'] = this.data!.toJson();
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

  Future<ListTagihanResponse> tagihanMingguIni(String token) async {
    try {
      var url = "/tagihan-minggu-ini";
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

  //create tagihan
  Future<TagihanResponse> createTagihan(String token, Tagihan tagihan) async {
    try {
      var url = "/tagihan";
      var data = tagihan.toJson();

      var response =
          await ApiProvider.post(url, data, {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        var d = TagihanResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return TagihanResponse(status: 500, message: "Gagal menambah data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return TagihanResponse(
            status: e.response!.statusCode,
            message: "Gagal menambah data. ${e.message}");
      } else {
        print(e);
        print(t);
        return TagihanResponse(
            status: 500, message: "Gagal menambah data. ${e}");
      }
    }
  }

  //update tagihan
  Future<TagihanResponse> updateTagihan(
      String token, String tagihan_id, Tagihan tagihan) async {
    try {
      var url = "/tagihan/${tagihan_id}";
      var data = tagihan.toJson();

      var response =
          await ApiProvider.post(url, data, {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        var d = TagihanResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return TagihanResponse(status: 500, message: "Gagal mngubah data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return TagihanResponse(
            status: e.response!.statusCode,
            message: "Gagal mngubah data. ${e.message}");
      } else {
        print(e);
        print(t);
        return TagihanResponse(
            status: 500, message: "Gagal menambah data. ${e}");
      }
    }
  }

  Future<TagihanResponse> bayarTagihan(String token, String tagihan_id,
      String total_bayar, String tanggal_bayar, String keterangan) async {
    try {
      var url = "/bayar-tagihan/${tagihan_id}";
      var data = {
        "total_bayar": total_bayar,
        "tanggal_bayar": tanggal_bayar,
        "keterangan": keterangan
      };

      var response =
          await ApiProvider.post(url, data, {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        var d = TagihanResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return TagihanResponse(status: 500, message: "Gagal menambah data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return TagihanResponse(
            status: e.response!.statusCode,
            message: "Gagal menambah data. ${e.message}");
      } else {
        print(e);
        print(t);
        return TagihanResponse(
            status: 500, message: "Gagal menambah data. ${e}");
      }
    }
  }

  Future<TagihanResponse> hapusTagihan(String token, String tagihan_id) async {
    try {
      var url = "/tagihan/${tagihan_id}/delete";

      var response =
          await ApiProvider.post(url, null, {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        var d = TagihanResponse.fromJson(response.data);
        d.status = response.statusCode;
        return d;
      } else {
        return TagihanResponse(status: 500, message: "Gagal menghapus data");
      }
    } catch (e, t) {
      if (e is DioError && e.response != null) {
        print(e.response!.data);
        return TagihanResponse(
            status: e.response!.statusCode,
            message: "Gagal menghapus data. ${e.message}");
      } else {
        print(e);
        print(t);
        return TagihanResponse(
            status: 500, message: "Gagal menghapus data. ${e}");
      }
    }
  }
}
