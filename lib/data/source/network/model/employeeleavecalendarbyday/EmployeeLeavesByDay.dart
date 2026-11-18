class EmployeeLeavesByDay {
  EmployeeLeavesByDay({
    required this.leaveId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.department,
    required this.post,
    required this.leaveDays,
    required this.leaveFrom,
    required this.leaveTo,
    required this.leaveStatus,
  });

  String leaveId;
  String userId;
  String userName;
  String userAvatar;
  String department;
  String post;
  String leaveDays;
  String leaveFrom;
  String leaveTo;
  String leaveStatus;

  factory EmployeeLeavesByDay.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return EmployeeLeavesByDay(
      leaveId: data['leave_id']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? '',
      userName: data['user_name']?.toString() ?? '',
      userAvatar: data['user_avatar']?.toString() ?? '',
      department: data['department']?.toString() ?? '',
      post: data['post']?.toString() ?? '',
      leaveDays: data['leave_days']?.toString() ?? '',
      leaveFrom: data['leave_from']?.toString() ?? '',
      leaveTo: data['leave_to']?.toString() ?? '',
      leaveStatus: data['leave_status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leave_id': leaveId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'department': department,
      'post': post,
      'leave_days': leaveDays,
      'leave_from': leaveFrom,
      'leave_to': leaveTo,
      'leave_status': leaveStatus,
    };
  }
}
