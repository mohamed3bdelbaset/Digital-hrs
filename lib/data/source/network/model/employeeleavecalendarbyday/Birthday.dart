class Birthday {
  Birthday({
    required this.id,
    required this.name,
    required this.dob,
    required this.role,
    required this.avatar,
  });

  int id;
  String name;
  String dob;
  String role;
  String avatar;

  factory Birthday.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return Birthday(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      name: data['name']?.toString() ?? '',
      dob: data['dob']?.toString() ?? '',
      role: data['post']?.toString() ?? '',
      avatar: data['avatar']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dob': dob,
      'post': role,
      'avatar': avatar,
    };
  }
}
