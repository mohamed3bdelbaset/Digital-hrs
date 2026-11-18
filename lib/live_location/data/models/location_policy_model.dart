class LocationPolicyModel {
  final bool tracking;
  final String? reason;
  final int intervalSeconds;
  final int recheckAfterSeconds;
  final int? attendanceId;

  const LocationPolicyModel({
    required this.tracking,
    this.reason,
    required this.intervalSeconds,
    required this.recheckAfterSeconds,
    this.attendanceId,
  });

  factory LocationPolicyModel.fromJson(Map<String, dynamic> json) {
    return LocationPolicyModel(
      tracking: json['tracking'] == true,
      reason: json['reason'] as String?,
      intervalSeconds: (json['interval_seconds'] as num?)?.toInt() ?? 300,
      recheckAfterSeconds:
          (json['recheck_after_seconds'] as num?)?.toInt() ?? 900,
      attendanceId: (json['attendance_id'] as num?)?.toInt(),
    );
  }
}
