class OfficeTime {
  OfficeTime({
    required this.id,
    required this.startTime,
    required this.endTime,
  });

  int id;
  String startTime;
  String endTime;

  factory OfficeTime.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return OfficeTime(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      startTime: data['start_time']?.toString() ?? '',
      endTime: data['end_time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
