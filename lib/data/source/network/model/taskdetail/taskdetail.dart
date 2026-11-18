import '../taskdetail/Data.dart';

class TaskDetailResponse {
  Data data;
  String message;
  bool status;
  int status_code;

  TaskDetailResponse({
    required this.data,
    required this.message,
    required this.status,
    required this.status_code,
  });

  factory TaskDetailResponse.fromJson(Map<String, dynamic> json) {
    return TaskDetailResponse(
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
