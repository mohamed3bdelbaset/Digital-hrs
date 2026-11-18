class Participator {
  Participator({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.onlineStatus,
    required this.avatar,
    required this.post,
  });

  String id;
  String name;
  String email;
  String phone;
  String onlineStatus;
  String avatar;
  String post;

  factory Participator.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return Participator(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      onlineStatus: data['online_status']?.toString() ?? '',
      avatar: data['avatar']?.toString() ?? '',
      post: data['post']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'online_status': onlineStatus,
      'avatar': avatar,
      'post': post,
    };
  }
}
