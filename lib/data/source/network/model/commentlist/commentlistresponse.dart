import '../commentlist/Data.dart';

class CommentListResponse {
  List<Data> data;
  int code;
  bool status;

  CommentListResponse({
    required this.data,
    required this.code,
    required this.status,
  });

  factory CommentListResponse.fromJson(Map<String, dynamic> json) {
    return CommentListResponse(
      data: (json['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => Data.fromJson(item))
          .toList(),
      code: json['code'] is num
          ? (json['code'] as num).toInt()
          : int.tryParse(json['code']?.toString() ?? '') ?? 0,
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'status': status,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
