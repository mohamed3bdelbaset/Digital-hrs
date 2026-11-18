class Company {
  Company({
    required this.id,
    required this.name,
    required this.weekend,
  });

  int id;
  String name;
  List<dynamic> weekend;

  factory Company.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is Map<String, dynamic> ? json : {};

    return Company(
      id: data['id'] is num
          ? (data['id'] as num).toInt()
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      name: data['name']?.toString() ?? '',
      weekend:
          data['weekend'] is List ? List<dynamic>.from(data['weekend']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weekend': weekend,
    };
  }
}
