class LocationResponseModel {
  final bool stored;
  final String? reason;
  final int nextPingAfterSeconds;
  final bool tracking;

  const LocationResponseModel({
    required this.stored,
    this.reason,
    required this.nextPingAfterSeconds,
    required this.tracking,
  });

  factory LocationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LocationResponseModel(
      stored: json['stored'] == true,
      reason: json['reason'] as String?,
      nextPingAfterSeconds:
          (json['next_ping_after_seconds'] as num?)?.toInt() ?? 300,
      tracking: json['tracking'] == true,
    );
  }
}
