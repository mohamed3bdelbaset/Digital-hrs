import 'package:cnattendance/data/source/network/model/paysliplist/Payslip.dart';

class Data {
  String currency;
  List<Payslip> payslip;

  Data({
    required this.currency,
    required this.payslip,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      currency: json['currency']?.toString() ?? '',
      payslip: (json['payslip'] as List? ?? [])
          .map((i) => Payslip.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'payslip': payslip.map((v) => v.toJson()).toList(),
    };
  }
}
