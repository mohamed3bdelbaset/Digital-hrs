class AdvanceSalary {
  int id;
  String? description;
  String requested_amount;
  String released_amount;
  String status;
  bool is_settled;
  String? verifiedBy;
  String? remark;
  String submittedDate;
  String requested_date;
  String released_date;

  AdvanceSalary(
    this.id,
    this.description,
    this.requested_amount,
    this.released_amount,
    this.status,
    this.is_settled,
    this.verifiedBy,
    this.remark,
    this.submittedDate,
    this.requested_date,
    this.released_date,
  );

  factory AdvanceSalary.fromJson(Map<String, dynamic> json) {
    return AdvanceSalary(
      json['id'] ?? 0,
      json['description']?.toString(),
      json['requested_amount']?.toString() ?? '0',
      json['released_amount']?.toString() ?? '0',
      json['status']?.toString() ?? '',
      json['is_settled'] ?? false,
      json['verifiedBy']?.toString(),
      json['remark']?.toString(),
      json['submittedDate']?.toString() ?? '',
      json['requested_date']?.toString() ?? '',
      json['released_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'requested_amount': requested_amount,
      'released_amount': released_amount,
      'status': status,
      'is_settled': is_settled,
      'verifiedBy': verifiedBy,
      'remark': remark,
      'submittedDate': submittedDate,
      'requested_date': requested_date,
      'released_date': released_date,
    };
  }
}
