class Holidays {
  Holidays({
    required this.id,
    required this.event,
    required this.eventDate,
    required this.description,
    required this.isPublicHoliday,
  });

  int id;
  String event;
  String eventDate;
  String description;
  bool isPublicHoliday;

  factory Holidays.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return Holidays(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      event: data['event']?.toString() ?? '',
      eventDate: data['event_date']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      isPublicHoliday: data['is_public_holiday'] == true ||
          data['is_public_holiday'] == 1 ||
          data['is_public_holiday']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'event_date': eventDate,
      'description': description,
      'is_public_holiday': isPublicHoliday,
    };
  }
}
