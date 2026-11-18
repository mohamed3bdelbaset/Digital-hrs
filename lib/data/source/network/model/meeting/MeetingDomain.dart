import 'Participator.dart';

class MeetingDomain {
  MeetingDomain({
    required this.id,
    required this.title,
    required this.agenda,
    required this.venue,
    required this.meetingDate,
    required this.meetingStartTime,
    required this.publishDate,
    required this.image,
    required this.createdBy,
    required this.participator,
  });

  int id;
  String title;
  String agenda;
  String venue;
  String meetingDate;
  String meetingStartTime;
  String publishDate;
  String image;
  String createdBy;
  List<Participator> participator;

  factory MeetingDomain.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return MeetingDomain(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      title: data['title']?.toString() ?? '',
      agenda: data['agenda']?.toString() ?? '',
      venue: data['venue']?.toString() ?? '',
      meetingDate: data['meeting_date_nepali']?.toString() ?? '',
      meetingStartTime: data['meeting_start_time']?.toString() ?? '',
      publishDate: data['publish_date']?.toString() ?? '',
      image: data['image']?.toString() ?? '',
      createdBy: data['created_by']?.toString() ?? '',
      participator: (data['participator'] as List? ?? [])
          .map((x) => Participator.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'agenda': agenda,
      'venue': venue,
      'meeting_date_nepali': meetingDate,
      'meeting_start_time': meetingStartTime,
      'publish_date': publishDate,
      'image': image,
      'created_by': createdBy,
      'participator': participator.map((v) => v.toJson()).toList(),
    };
  }
}
