import '../supportlistresponse/Data.dart';

class supportlistresponse {
  Data data;
  String message;
  bool status;
  int status_code;

  supportlistresponse({
    required this.data,
    required this.message,
    required this.status,
    required this.status_code,
  });

  factory supportlistresponse.fromJson(Map<String, dynamic> json) {
    return supportlistresponse(
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
