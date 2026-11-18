class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.avatar,
    required this.workspace_type,
  });

  final int id;
  final String name;
  final String email;
  final String username;
  final String avatar;
  final String workspace_type;

  factory User.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return User(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      avatar: data['avatar']?.toString() ?? '',
      workspace_type: data['workspace_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'avatar': avatar,
      'workspace_type': workspace_type,
    };
  }
}
