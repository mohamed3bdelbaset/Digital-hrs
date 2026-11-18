import 'package:cnattendance/data/source/network/model/commentlist/Mentioned.dart';
import 'package:cnattendance/data/source/network/model/commentlist/Reply.dart';

class Data {
  String avatar;
  String created_at;
  String created_by_id;
  String created_by_name;
  String description;
  int id;
  List<Mentioned> mentioned;
  List<Reply> replies;

  Data({
    required this.avatar,
    required this.created_at,
    required this.created_by_id,
    required this.created_by_name,
    required this.description,
    required this.id,
    required this.mentioned,
    required this.replies,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      avatar: json['avatar']?.toString() ?? '',
      created_at: json['created_at']?.toString() ?? '',
      created_by_id: json['created_by_id']?.toString() ?? '',
      created_by_name: json['created_by_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      mentioned: (json['mentioned'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => Mentioned.fromJson(item))
          .toList(),
      replies: (json['replies'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => Reply.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'created_at': created_at,
      'created_by_id': created_by_id,
      'created_by_name': created_by_name,
      'description': description,
      'id': id,
      'mentioned': mentioned.map((item) => item.toJson()).toList(),
      'replies': replies.map((item) => item.toJson()).toList(),
    };
  }
}
