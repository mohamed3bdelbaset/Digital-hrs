class Holiday {
  Holiday({
    required this.id,
    required this.event,
    required this.event_date,
    required this.nepali_date,
    required this.description,
    required this.is_public_holiday,
  });

  int id;
  String event;
  String event_date;
  String nepali_date;
  String description;
  bool is_public_holiday;

  factory Holiday.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return Holiday(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      event: data['event']?.toString() ?? '',
      event_date: data['event_date']?.toString() ?? '',
      nepali_date: data['nepali_date']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      is_public_holiday: data['is_public_holiday'] == true ||
          data['is_public_holiday'] == 1 ||
          data['is_public_holiday']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'event_date': event_date,
      'nepali_date': nepali_date,
      'description': description,
      'is_public_holiday': is_public_holiday,
    };
  }
}
