import 'package:cnattendance/data/source/network/model/commentlist/Mentioned.dart';

class Reply {
  String avatar;
  String comment_id;
  String created_at;
  String created_by_id;
  String created_by_name;
  String description;
  List<Mentioned> mentioned;
  int reply_id;

  Reply({
    required this.avatar,
    required this.comment_id,
    required this.created_at,
    required this.created_by_id,
    required this.created_by_name,
    required this.description,
    required this.mentioned,
    required this.reply_id,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      avatar: json['avatar']?.toString() ?? '',
      comment_id: json['comment_id']?.toString() ?? '',
      created_at: json['created_at']?.toString() ?? '',
      created_by_id: json['created_by_id']?.toString() ?? '',
      created_by_name: json['created_by_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mentioned: (json['mentioned'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => Mentioned.fromJson(item))
          .toList(),
      reply_id: json['reply_id'] is num
          ? (json['reply_id'] as num).toInt()
          : int.tryParse(json['reply_id']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'comment_id': comment_id,
      'created_at': created_at,
      'created_by_id': created_by_id,
      'created_by_name': created_by_name,
      'description': description,
      'reply_id': reply_id,
      'mentioned': mentioned.map((item) => item.toJson()).toList(),
    };
  }
}
