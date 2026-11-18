class NoticeDomain {
  NoticeDomain({
    required this.id,
    required this.noticeTitle,
    required this.description,
    required this.noticePublishedDate,
  });

  int id;
  String noticeTitle;
  String description;
  String noticePublishedDate;

  factory NoticeDomain.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return NoticeDomain(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      noticeTitle: data['notice_title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      noticePublishedDate: data['notice_published_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notice_title': noticeTitle,
      'description': description,
      'notice_published_date': noticePublishedDate,
    };
  }
}
