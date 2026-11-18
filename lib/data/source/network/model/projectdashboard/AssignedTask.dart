import 'package:cnattendance/data/source/network/model/projectdashboard/AssignedMemberX.dart';

class AssignedTask {
  List<AssignedMemberX> assigned_member;
  String end_date;
  String priority;
  String project_name;
  String start_date;
  String status;
  int task_id;
  String task_name;

  AssignedTask({
    required this.assigned_member,
    required this.end_date,
    required this.priority,
    required this.project_name,
    required this.start_date,
    required this.status,
    required this.task_id,
    required this.task_name,
  });

  factory AssignedTask.fromJson(Map<String, dynamic> json) {
    return AssignedTask(
      assigned_member: (json['assigned_member'] as List? ?? [])
          .map((i) => AssignedMemberX.fromJson(i))
          .toList(),
      end_date: json['end_date']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      project_name: json['project_name']?.toString() ?? '',
      start_date: json['start_date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      task_id: json['task_id'] is num
          ? (json['task_id'] as num).toInt()
          : int.tryParse(json['task_id']?.toString() ?? '') ?? 0,
      task_name: json['task_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assigned_member': assigned_member.map((v) => v.toJson()).toList(),
      'end_date': end_date,
      'priority': priority,
      'project_name': project_name,
      'start_date': start_date,
      'status': status,
      'task_id': task_id,
      'task_name': task_name,
    };
  }
}
