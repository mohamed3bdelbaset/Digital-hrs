import 'package:cnattendance/data/source/network/model/tadadetail/Attachments.dart';

class Data {
  Attachments attachments;
  String description;
  String employee;
  int id;
  String remark;
  String status;
  String submitted_date;
  String title;
  String total_expense;
  String verified_by;

  Data({
    required this.attachments,
    required this.description,
    required this.employee,
    required this.id,
    required this.remark,
    required this.status,
    required this.submitted_date,
    required this.title,
    required this.total_expense,
    required this.verified_by,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      attachments: Attachments.fromJson(
        json['attachments'] as Map<String, dynamic>? ?? {},
      ),
      description: json['description']?.toString() ?? '',
      employee: json['employee']?.toString() ?? '',
      id: json['id'] ?? 0,
      remark: json['remark']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      submitted_date: json['submitted_date']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      total_expense: json['total_expense']?.toString() ?? '0',
      verified_by: json['verified_by']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachments': attachments.toJson(),
      'description': description,
      'employee': employee,
      'id': id,
      'remark': remark,
      'status': status,
      'submitted_date': submitted_date,
      'title': title,
      'total_expense': total_expense,
      'verified_by': verified_by,
    };
  }
}
