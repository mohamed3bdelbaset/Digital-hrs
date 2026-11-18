import '../tadalist/Data.dart';

class TadaListResponse {
  List<Data> data;
  String message;
  bool status;
  int status_code;

  TadaListResponse({
    required this.data,
    required this.message,
    required this.status,
    required this.status_code,
  });

  factory TadaListResponse.fromJson(Map<String, dynamic> json) {
    return TadaListResponse(
      data: (json['data'] as List? ?? []).map((i) => Data.fromJson(i)).toList(),
      message: json['message']?.toString() ?? '',
      status: json['status'] ?? false,
      status_code: json['status_code'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((v) => v.toJson()).toList(),
      'message': message,
      'status': status,
      'status_code': status_code,
    };
  }
}
