class LeaveTypeDetail {
  LeaveTypeDetail({
    required this.id,
    required this.noOfDays,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.leaveFrom,
    required this.leaveTo,
    required this.leaveRequestedDate,
    required this.status,
    required this.leaveReason,
    required this.adminRemark,
    required this.earlyExit,
    required this.statusUpdatedBy,
  });

  int id;
  String noOfDays;
  String leaveTypeId;
  String leaveTypeName;
  String leaveFrom;
  String leaveTo;
  String leaveRequestedDate;
  String status;
  String leaveReason;
  String adminRemark;
  bool earlyExit;
  String statusUpdatedBy;

  factory LeaveTypeDetail.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return LeaveTypeDetail(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      noOfDays: data['no_of_days']?.toString() ?? '',
      leaveTypeId: data['leave_type_id']?.toString() ?? '',
      leaveTypeName: data['leave_type_name']?.toString() ?? '',
      leaveFrom: data['leave_from']?.toString() ?? '',
      leaveTo: data['leave_to']?.toString() ?? '',
      leaveRequestedDate: data['leave_requested_date']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      leaveReason: data['leave_reason']?.toString() ?? '',
      adminRemark: data['admin_remark']?.toString() ?? '',
      earlyExit: data['early_exit'] == true ||
          data['early_exit'] == 1 ||
          data['early_exit']?.toString().toLowerCase() == 'true',
      statusUpdatedBy: data['status_updated_by']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no_of_days': noOfDays,
      'leave_type_id': leaveTypeId,
      'leave_type_name': leaveTypeName,
      'leave_from': leaveFrom,
      'leave_to': leaveTo,
      'leave_requested_date': leaveRequestedDate,
      'status': status,
      'leave_reason': leaveReason,
      'admin_remark': adminRemark,
      'early_exit': earlyExit,
      'status_updated_by': statusUpdatedBy,
    };
  }
}
