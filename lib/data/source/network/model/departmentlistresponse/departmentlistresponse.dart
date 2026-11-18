import '../departmentlistresponse/Data.dart';

class departmentlistresponse {
  List<Data> data;
  String message;
  bool status;
  int status_code;

  departmentlistresponse({
    required this.data,
    required this.message,
    required this.status,
    required this.status_code,
  });

  factory departmentlistresponse.fromJson(Map<String, dynamic> json) {
    return departmentlistresponse(
      data: (json['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => Data.fromJson(item))
          .toList(),
      message: json['message']?.toString() ?? '',
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      status_code: json['status_code'] is num
          ? (json['status_code'] as num).toInt()
          : int.tryParse(json['status_code']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'message': message,
      'status': status,
      'status_code': status_code,
    };
  }
}
