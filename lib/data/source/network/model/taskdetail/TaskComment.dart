import 'package:cnattendance/data/source/network/model/taskdetail/Mentioned.dart';

class TaskComment {
  String avatar;
  String created_at;
  String created_by_id;
  String created_by_name;
  String description;
  int id;
  List<Mentioned> mentioned;

  TaskComment({
    required this.avatar,
    required this.created_at,
    required this.created_by_id,
    required this.created_by_name,
    required this.description,
    required this.id,
    required this.mentioned,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      avatar: json['avatar']?.toString() ?? '',
      created_at: json['created_at']?.toString() ?? '',
      created_by_id: json['created_by_id']?.toString() ?? '',
      created_by_name: json['created_by_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      id: json['id'] ?? 0,
      mentioned: (json['mentioned'] as List? ?? [])
          .map((i) => Mentioned.fromJson(i))
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
      'mentioned': mentioned.map((v) => v.toJson()).toList(),
    };
  }
}
