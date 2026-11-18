class NotifiactionDomain {
  NotifiactionDomain({
    required this.id,
    required this.notificationTitle,
    required this.description,
    required this.notificationPublishedDate,
  });

  int id;
  String notificationTitle;
  String description;
  String notificationPublishedDate;

  factory NotifiactionDomain.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return NotifiactionDomain(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      notificationTitle: data['notification_title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      notificationPublishedDate:
          data['notification_published_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_title': notificationTitle,
      'description': description,
      'notification_published_date': notificationPublishedDate,
    };
  }
}
