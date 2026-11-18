import 'package:cnattendance/data/source/network/model/projectdashboard/AssignedMemberX.dart';

class Project {
  List<AssignedMemberX> assigned_member;
  int assigned_task_count;
  String end_date;
  int id;
  String priority;
  String project_name;
  String slug;
  int project_progress_percent;
  String start_date;
  String status;

  Project({
    required this.assigned_member,
    required this.assigned_task_count,
    required this.end_date,
    required this.id,
    required this.priority,
    required this.project_name,
    required this.slug,
    required this.project_progress_percent,
    required this.start_date,
    required this.status,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final String projectName = json['project_name']?.toString() ?? '';

    return Project(
      assigned_member: (json['assigned_member'] as List? ?? [])
          .map((i) => AssignedMemberX.fromJson(i))
          .toList(),
      assigned_task_count: json['assigned_task_count'] ?? 0,
      end_date: json['end_date']?.toString() ?? '',
      id: json['id'] ?? 0,
      priority: json['priority']?.toString() ?? '',
      project_name: projectName,
      slug: json['slug']?.toString() ?? projectName,
      project_progress_percent: json['project_progress_percent'] ?? 0,
      start_date: json['start_date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assigned_member': assigned_member.map((v) => v.toJson()).toList(),
      'assigned_task_count': assigned_task_count,
      'end_date': end_date,
      'id': id,
      'priority': priority,
      'project_name': project_name,
      'slug': slug,
      'project_progress_percent': project_progress_percent,
      'start_date': start_date,
      'status': status,
    };
  }
}
