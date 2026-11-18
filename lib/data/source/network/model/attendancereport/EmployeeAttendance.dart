class EmployeeAttendance {
  EmployeeAttendance({
    required this.id,
    required this.attendanceDate,
    required this.weekDay,
    required this.workedhrs,
    required this.checkIn,
    required this.checkOut,
    required this.isOverTime,
    required this.isUnderTime,
    required this.overTime,
    required this.underTime,
    required this.workingHour,
    required this.workingHourMin,
    required this.workedhrsMin,
  });

  int id;
  String attendanceDate;
  String weekDay;
  String? workedhrs;
  double workedhrsMin;
  String checkIn;
  String checkOut;
  bool isOverTime;
  bool isUnderTime;
  String overTime;
  String underTime;
  String workingHour;
  double workingHourMin;

  factory EmployeeAttendance.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return EmployeeAttendance(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      attendanceDate: data['attendance_date_nepali']?.toString() ?? '',
      weekDay: data['week_day']?.toString() ?? '',
      workedhrs: data['worked_hours']?.toString() ?? '-',
      checkIn: data['check_in']?.toString() ?? '-',
      checkOut: data['check_out']?.toString() ?? '-',
      workingHour: data['working_hours']?.toString() ?? '-',
      workingHourMin: _toDouble(data['working_hours_min']),
      workedhrsMin: _toDouble(data['worked_hours_min']),
      isOverTime: _toBool(data['is_overtime']),
      isUnderTime: _toBool(data['is_undertime']),
      overTime: data['overtime']?.toString() ?? '-',
      underTime: data['undertime']?.toString() ?? '-',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static bool _toBool(dynamic value) {
    return value == true ||
        value == 1 ||
        value?.toString().toLowerCase() == 'true';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendance_date_nepali': attendanceDate,
      'week_day': weekDay,
      'worked_hours': workedhrs,
      'check_in': checkIn,
      'check_out': checkOut,
      'is_overtime': isOverTime,
      'is_undertime': isUnderTime,
      'overtime': overTime,
      'undertime': underTime,
      'working_hours': workingHour,
      'working_hours_min': workingHourMin,
      'worked_hours_min': workedhrsMin,
    };
  }
}
