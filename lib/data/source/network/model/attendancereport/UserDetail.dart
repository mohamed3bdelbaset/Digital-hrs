class UserDetail {
  UserDetail({
    required this.userId,
    required this.name,
    required this.email,
  });

  int userId;
  String name;
  String email;

  factory UserDetail.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return UserDetail(
      userId: data['user_id'] is num
          ? (data['user_id'] as num).toInt()
          : int.tryParse(data['user_id']?.toString() ?? '') ?? 0,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
    };
  }
}
