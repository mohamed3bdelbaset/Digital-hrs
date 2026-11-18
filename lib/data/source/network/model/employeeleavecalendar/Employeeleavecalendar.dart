class Employeeleavecalendar {
  Employeeleavecalendar({
    required this.date,
    required this.leaveCount,
  });

  String date;
  String leaveCount;

  factory Employeeleavecalendar.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return Employeeleavecalendar(
      date: data['date']?.toString() ?? '',
      leaveCount: data['leave_count']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'leave_count': leaveCount,
    };
  }
}
