class AttendanceSummary {
  AttendanceSummary({
    required this.totalPresent,
    required this.totalWorkedHours,
  });

  String totalPresent;
  String totalWorkedHours;

  factory AttendanceSummary.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return AttendanceSummary(
      totalPresent: data['totalPresent']?.toString() ?? '-',
      totalWorkedHours: data['totalWorkedHours']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPresent': totalPresent,
      'totalWorkedHours': totalWorkedHours,
    };
  }
}
