class Profile {
  Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.address,
    required this.status,
    required this.leaveAllocated,
    required this.employmentType,
    required this.userType,
    required this.officeTime,
    required this.branch,
    required this.department,
    required this.post,
    required this.role,
    required this.avatar,
    required this.joiningDate,
    required this.bankName,
    required this.bankAccountNo,
    required this.bankAccountType,
  });

  int id;
  String name;
  String email;
  String username;
  String phone;
  String dob;
  String gender;
  String address;
  String status;
  String leaveAllocated;
  String employmentType;
  String userType;
  String officeTime;
  String branch;
  String department;
  String post;
  String role;
  String avatar;
  String joiningDate;
  String bankName;
  String bankAccountNo;
  String bankAccountType;

  factory Profile.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return Profile(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      dob: data['dob']?.toString() ?? '',
      gender: data['gender']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      leaveAllocated: data['leave_allocated']?.toString() ?? '',
      employmentType: data['employment_type']?.toString() ?? '',
      userType: data['user_type']?.toString() ?? '',
      officeTime: data['office_time']?.toString() ?? '',
      branch: data['branch']?.toString() ?? '',
      department: data['department']?.toString() ?? '',
      post: data['post']?.toString() ?? '',
      role: data['role']?.toString() ?? '',
      avatar: data['avatar']?.toString() ?? '',
      joiningDate: data['joining_date']?.toString() ?? '',
      bankName: data['bank_name']?.toString() ?? '',
      bankAccountNo: data['bank_account_no']?.toString() ?? '',
      bankAccountType: data['bank_account_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'dob': dob,
      'gender': gender,
      'address': address,
      'status': status,
      'leave_allocated': leaveAllocated,
      'employment_type': employmentType,
      'user_type': userType,
      'office_time': officeTime,
      'branch': branch,
      'department': department,
      'post': post,
      'role': role,
      'avatar': avatar,
      'joining_date': joiningDate,
      'bank_name': bankName,
      'bank_account_no': bankAccountNo,
      'bank_account_type': bankAccountType,
    };
  }
}
