class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.avatar,
    required this.onlineStatus,
    required this.department,
    required this.branch,
    required this.dob,
    required this.gender,
    required this.workspace_type,
  });

  int id;
  String name;
  String email;
  String username;
  String avatar;
  bool onlineStatus;
  String workspace_type;
  String department;
  String branch;
  String dob;
  String gender;

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
      onlineStatus: data['online_status'] == true ||
          data['online_status'] == 1 ||
          data['online_status']?.toString().toLowerCase() == 'true',
      department: data['department']?.toString() ?? '',
      branch: data['branch']?.toString() ?? '',
      dob: data['dob']?.toString() ?? '',
      gender: data['gender']?.toString() ?? '',
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
      'online_status': onlineStatus,
      'department': department,
      'branch': branch,
      'dob': dob,
      'gender': gender,
      'workspace_type': workspace_type,
    };
  }
}
