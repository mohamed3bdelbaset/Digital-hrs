class EmployeeTodayAttendance {
  EmployeeTodayAttendance({
    required this.checkInAt,
    required this.checkOutAt,
    required this.productionTime,
  });

  String checkInAt;
  String checkOutAt;
  int productionTime;

  factory EmployeeTodayAttendance.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return EmployeeTodayAttendance(
      checkInAt: data['check_in_at']?.toString() ?? '',
      checkOutAt: data['check_out_at']?.toString() ?? '',
      productionTime: data['productive_time_in_min'] is num
          ? (data['productive_time_in_min'] as num).toInt()
          : int.tryParse(
                data['productive_time_in_min']?.toString() ?? '',
              ) ??
              0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'check_in_at': checkInAt,
      'check_out_at': checkOutAt,
      'productive_time_in_min': productionTime,
    };
  }
}
