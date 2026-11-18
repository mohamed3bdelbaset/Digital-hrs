import 'dart:convert';

ResignationRepsonse resignationRepsonseFromMap(String str) =>
    ResignationRepsonse.fromMap(json.decode(str));

class ResignationRepsonse {
  final bool status;
  final String message;
  final int statusCode;
  final Data? data;

  ResignationRepsonse({
    required this.status,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory ResignationRepsonse.fromMap(Map<String, dynamic> json) {
    return ResignationRepsonse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['status_code'] ?? 0,
      data: json['data'] != null
          ? Data.fromMap(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Data {
  final int id;
  final String employeeId;
  final String resignationDate;
  final String lastWorkingDay;
  final String reason;
  final String status;
  final String remark;
  final DateTime createdAt;
  final DateTime updatedAt;

  Data({
    required this.id,
    required this.employeeId,
    required this.resignationDate,
    required this.lastWorkingDay,
    required this.reason,
    required this.status,
    required this.remark,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromMap(Map<String, dynamic> json) {
    return Data(
      id: json['id'] ?? 0,
      employeeId: json['employee_id']?.toString() ?? '',
      resignationDate: json['resignation_date']?.toString() ?? '',
      lastWorkingDay: json['last_working_day']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      remark: json['admin_remark']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime(2000),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime(2000),
    );
  }
}
