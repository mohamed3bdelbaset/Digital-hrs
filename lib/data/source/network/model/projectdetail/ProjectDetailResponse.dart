import 'package:cnattendance/data/source/network/model/projectdetail/Data.dart';

class ProjectDetailResponse {
  Data data;
  String message;
  bool status;
  int status_code;

  ProjectDetailResponse({
    required this.data,
    required this.message,
    required this.status,
    required this.status_code,
  });

  factory ProjectDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProjectDetailResponse(
      data: Data.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
      message: json['message'] ?? '',
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
