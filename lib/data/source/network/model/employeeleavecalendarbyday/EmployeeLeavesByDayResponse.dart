import '../employeeleavecalendarbyday/Data.dart';

class EmployeeLeavesByDayResponse {
  EmployeeLeavesByDayResponse({
    required this.status,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  bool status;
  String message;
  int statusCode;
  Data data;

  factory EmployeeLeavesByDayResponse.fromJson(dynamic json) {
    final Map<String, dynamic> dataJson =
        json is Map<String, dynamic> ? json : {};

    return EmployeeLeavesByDayResponse(
      status: dataJson['status'] == true ||
          dataJson['status'] == 1 ||
          dataJson['status']?.toString().toLowerCase() == 'true',
      message: dataJson['message']?.toString() ?? '',
      statusCode: dataJson['status_code'] is num
          ? (dataJson['status_code'] as num).toInt()
          : int.tryParse(dataJson['status_code']?.toString() ?? '') ?? 0,
      data: Data.fromJson(
        dataJson['data'] is Map<String, dynamic>
            ? dataJson['data']
            : <String, dynamic>{},
      ),
    );
  }
}
