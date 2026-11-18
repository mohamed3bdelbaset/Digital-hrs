class Event {
  int id;
  String title;
  String description;
  String location;
  String startdate;
  String endDate;
  String startTime;
  String endTime;
  String image;
  String createdBy;
  dynamic creator;
  List<dynamic> eventUsers;
  List<dynamic> eventDepartments;

  Event(
    this.id,
    this.title,
    this.description,
    this.location,
    this.startdate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.image,
    this.createdBy,
    this.creator,
    this.eventUsers,
    this.eventDepartments,
  );

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      json['id'] ?? 0,
      json['title']?.toString() ?? '',
      json['description']?.toString() ?? '',
      json['location']?.toString() ?? '',
      json['startdate']?.toString() ?? '',
      json['endDate']?.toString() ?? '',
      json['startTime']?.toString() ?? '',
      json['endTime']?.toString() ?? '',
      json['image']?.toString() ?? '',
      json['createdBy']?.toString() ?? '',
      json['creator'],
      json['eventUsers'] as List? ?? [],
      json['eventDepartments'] as List? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'startdate': startdate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'image': image,
      'createdBy': createdBy,
      'creator': creator,
      'eventUsers': eventUsers,
      'eventDepartments': eventDepartments,
    };
  }
}
