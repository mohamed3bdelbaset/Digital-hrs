import '../commentsaveresponse/Data.dart';

class commentsaveresponse {
  Data data;
  String message;
  bool status;
  int status_code;

  commentsaveresponse({
    required this.data,
    required this.message,
    required this.status,
    required this.status_code,
  });

  factory commentsaveresponse.fromJson(Map<String, dynamic> json) {
    return commentsaveresponse(
      data: Data.fromJson(
        json['data'] is Map<String, dynamic>
            ? json['data']
            : <String, dynamic>{},
      ),
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
      'data': data.toJson(),
      'message': message,
      'status': status,
      'status_code': status_code,
    };
  }
}
