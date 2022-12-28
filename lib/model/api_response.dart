class ApiResponse {
  String? message;
  int? status;
  List<dynamic>? data;
  ApiResponse({this.message, this.status, this.data});
  ApiResponse.fromJson(Map<String, dynamic> json) {
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
