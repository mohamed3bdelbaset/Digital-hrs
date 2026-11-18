import '../tadadetail/Data.dart';

class TadaDetailResponse {
  Data data;
  String message;
  bool status;
  int status_code;

  TadaDetailResponse({
    required this.data,
    required this.message,
    required this.status,
    required this.status_code,
  });

  factory TadaDetailResponse.fromJson(Map<String, dynamic> json) {
    return TadaDetailResponse(
      data: Data.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
      message: json['message']?.toString() ?? '',
      status: json['status'] ?? false,
      status_code: json['status_code'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'message': message,
      'status': status,
      'status_code': status_code,
    };
  }
}
