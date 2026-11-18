class LeaveType {
  LeaveType({
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.leaveTypeSlug,
    required this.leaveTypeStatus,
    required this.earlyExit,
    required this.totalLeaveAllocated,
    required this.leaveTaken,
  });

  String leaveTypeId;
  String leaveTypeName;
  String leaveTypeSlug;
  bool leaveTypeStatus;
  bool earlyExit;
  String totalLeaveAllocated;
  String leaveTaken;

  factory LeaveType.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return LeaveType(
      leaveTypeId: data['leave_type_id']?.toString() ?? '',
      leaveTypeName: data['leave_type_name']?.toString() ?? 'Time Leave',
      leaveTypeSlug: data['leave_type_slug']?.toString() ?? '',
      leaveTypeStatus: data['leave_type_status'] == true ||
          data['leave_type_status'] == 1 ||
          data['leave_type_status']?.toString().toLowerCase() == 'true',
      earlyExit: data['early_exit'] == true ||
          data['early_exit'] == 1 ||
          data['early_exit']?.toString().toLowerCase() == 'true',
      totalLeaveAllocated: data['total_leave_allocated']?.toString() ?? '',
      leaveTaken: data['leave_taken']?.toString() ?? '0',
    );
  }

  List<LeaveType> getList(List<dynamic> leaveList) {
    return leaveList.map((item) => LeaveType.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'leave_type_id': leaveTypeId,
      'leave_type_name': leaveTypeName,
      'leave_type_slug': leaveTypeSlug,
      'leave_type_status': leaveTypeStatus,
      'early_exit': earlyExit,
      'total_leave_allocated': totalLeaveAllocated,
      'leave_taken': leaveTaken,
    };
  }
}
