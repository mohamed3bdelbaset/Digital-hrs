import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:math' as Random;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cnattendance/data/source/datastore/preferences.dart';
import 'package:cnattendance/data/source/network/model/attendancestatus/AttendanceStatusResponse.dart';
import 'package:cnattendance/data/source/network/model/dashboard/Dashboardresponse.dart';
import 'package:cnattendance/data/source/network/model/dashboard/EmployeeTodayAttendance.dart';
import 'package:cnattendance/data/source/network/model/dashboard/Feature.dart';
import 'package:cnattendance/data/source/network/model/dashboard/Overview.dart';
import 'package:cnattendance/data/source/network/model/eventlistresponse/eventdetailresponse.dart';
import 'package:cnattendance/data/source/network/model/teamsheet/Employee.dart'
    as employees;
import 'package:cnattendance/data/source/network/model/trainingresponse/trainingresponse.dart';
import 'package:cnattendance/live_location/services/location_background_service.dart';
import 'package:cnattendance/model/award.dart';
import 'package:cnattendance/model/holiday.dart';
import 'package:cnattendance/screen/auth/login_screen.dart';
import 'package:cnattendance/utils/constant.dart';
import 'package:cnattendance/utils/locationstatus.dart';
import 'package:cnattendance/utils/wifiinfo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor_plus/http_interceptor_plus.dart';
import 'package:intl/intl.dart';

class DashboardProvider with ChangeNotifier {
  final Map<String, String> _overviewList = {
    'present': '0',
    'holiday': '0',
    'leave': '0',
    'request': '0',
    'total_project': '0',
    'total_task': '0',
    'total_awards': '0',
    'active_training': '0',
    'active_event': '0',
  };

  Map<String, String> get overviewList => _overviewList;

  late Map<String, String> features = {};

  final Map<String, double> locationStatus = {
    'latitude': 0.0,
    'longitude': 0.0,
  };

  var department = "";
  var branch = "";

  final Map<String, dynamic> _attendanceList = {
    'check-in': '-',
    'check-out': '-',
    'production_hour': '0 hr 0 min',
    'production-time': 0.0,
  };

  Map<String, dynamic> get attendanceList => _attendanceList;

  Timer? _productionTimer;

  DateTime? _productionStartedAt;

  int _productionBaseMinutes = 0;

  int get productiveTimeInMinutes {
    if (_productionStartedAt == null) {
      return _productionBaseMinutes;
    }

    final additionalMinutes =
        DateTime.now().difference(_productionStartedAt!).inMinutes;

    return _productionBaseMinutes +
        (additionalMinutes < 0 ? 0 : additionalMinutes);
  }

  String get productiveTimeText {
    return calculateHourText(productiveTimeInMinutes);
  }

  double get productiveTimeProgress {
    return calculateProdHour(productiveTimeInMinutes);
  }

  List<employees.Employee> employeeList = [];

  bool isAD = true;
  bool isNoteEnabled = false;
  bool isLocationEnabled = false;
  bool animated = true;
  bool isBirthdayWished = false;

  List<String> attendanceMethods = [];

  Holiday? holiday;
  Award? award;
  Training? training;
  EventApi? event;

  final noteController = TextEditingController();

  final List<double> _weeklyReport = [];

  List<double> get weeklyReport => _weeklyReport;

  List<BarChartGroupData> barchartValue = [];
  List<BarChartGroupData> rawBarGroups = [];
  List<BarChartGroupData> showingBarGroups = [];

  Future<void> _refreshLocationPolicy() async {
    try {
      debugPrint('========== LOCATION SERVICE ==========');

      final service = LocationBackgroundService();

      await service.refreshPolicy();

      debugPrint('ATTENDANCE: Refresh completed');
      debugPrint('======================================');
    } catch (e, stackTrace) {
      debugPrint('ATTENDANCE: Refresh error: $e');
      debugPrint('ATTENDANCE STACK TRACE: $stackTrace');
    }
  }

  void _startProductionTimer(int initialMinutes) {
    _productionTimer?.cancel();

    _productionBaseMinutes = initialMinutes < 0 ? 0 : initialMinutes;

    _productionStartedAt = DateTime.now();

    _updateProductionValues(productiveTimeInMinutes);

    _productionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_productionStartedAt == null) return;

        _updateProductionValues(productiveTimeInMinutes);

        notifyListeners();
      },
    );

    debugPrint(
      'PRODUCTION TIMER STARTED: $_productionBaseMinutes minutes',
    );
  }

  void _stopProductionTimer() {
    _productionTimer?.cancel();

    _productionTimer = null;
    _productionStartedAt = null;

    debugPrint('PRODUCTION TIMER STOPPED');
  }

  void _updateProductionValues(int totalMinutes) {
    _attendanceList['production-time'] = calculateProdHour(totalMinutes);

    _attendanceList['production_hour'] = calculateHourText(totalMinutes);
  }

  void _syncProductionTimerFromDashboard(
    EmployeeTodayAttendance attendance,
  ) {
    final checkIn = attendance.checkInAt;
    final checkOut = attendance.checkOutAt;

    final isCheckedIn = checkIn != '-' && checkOut == '-';

    if (isCheckedIn) {
      // Dashboard refresh: do not restart an already-running timer
      // if the check-in value has not changed.
      if (_productionStartedAt != null) {
        return;
      }

      _startProductionTimer(attendance.productionTime);
    } else {
      _stopProductionTimer();

      _productionBaseMinutes =
          attendance.productionTime < 0 ? 0 : attendance.productionTime;

      _updateProductionValues(_productionBaseMinutes);
    }
  }

  void buildgraph() {
    const int daysInWeek = 7;

    barchartValue.clear();
    rawBarGroups.clear();
    showingBarGroups.clear();

    for (int i = 0; i < daysInWeek; i++) {
      barchartValue.add(makeGroupData(i, 0));
    }

    rawBarGroups.addAll(barchartValue);
    showingBarGroups.addAll(rawBarGroups);
  }

  Future<void> checkAD() async {
    Preferences preferences = Preferences();
    isAD = await preferences.getEnglishDate();
    notifyListeners();
  }

  Future<void> getFeatures() async {
    Preferences preferences = Preferences();
    features = await preferences.getFeatures();
    notifyListeners();
  }

  Future<Dashboardresponse> getDashboard() async {
    Preferences preferences = Preferences();

    animated = getAnimation();

    var uri = Uri.parse(
      await preferences.getAppUrl() + Constant.DASHBOARD_URL,
    );

    String token = await preferences.getToken();

    var fcm = await FirebaseMessaging.instance.getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
      'fcm_token': fcm ?? "",
    };

    final response = await http.get(uri, headers: headers);

    log(response.body.toString());

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final dashboardResponse = Dashboardresponse.fromJson(responseData);

      department = dashboardResponse.data.user.department;
      branch = dashboardResponse.data.user.branch;

      if (dashboardResponse.data.user.dob != "") {
        final dob = DateFormat("yyyy-MM-dd").parse(
          dashboardResponse.data.user.dob,
        );

        final currentDate = DateTime.now();

        final isBirthday =
            dob.month == currentDate.month && currentDate.day == dob.day;

        if (isBirthday) {
          if (!await preferences.getBirthdayWished()) {
            isBirthdayWished = false;
            preferences.saveBirthdayWished(true);
          } else {
            isBirthdayWished = true;
          }
        } else {
          preferences.saveBirthdayWished(false);
          isBirthdayWished = true;
        }
      }

      updateAttendanceStatus(
        dashboardResponse.data.employeeTodayAttendance,
      );

      final attendance = dashboardResponse.data.employeeTodayAttendance;

      final isCheckedIn =
          attendance.checkInAt != '-' && attendance.checkOutAt == '-';

      if (isCheckedIn) {
        debugPrint('ATTENDANCE: Active shift found after app restart');

        await _refreshLocationPolicy();
      } else {
        debugPrint('ATTENDANCE: No active shift');
      }

      updateOverView(dashboardResponse.data.overview);

      makeWeeklyReport(
        dashboardResponse.data.employeeWeeklyReport,
      );

      controlFeatures(dashboardResponse.data.features);

      await preferences.saveUserDashboard(
        dashboardResponse.data.user,
      );

      employeeList = dashboardResponse.data.employee;

      preferences.saveShowNfc(
        dashboardResponse.data.addNfc,
      );

      preferences.saveNote(
        dashboardResponse.data.attendance_note,
      );

      preferences.saveEmployeeLocation(
        dashboardResponse.data.employee_location,
      );

      isNoteEnabled = await preferences.getNote();
      isLocationEnabled = await preferences.getEnableLocation();

      final holidayResponse = dashboardResponse.data.holiday;
      final recentAwardResponse = dashboardResponse.data.recentAward;

      event = dashboardResponse.data.recentEvent;
      training = dashboardResponse.data.recentTraining;

      if (holidayResponse != null) {
        DateTime tempDate = DateFormat("yyyy-MM-dd").parse(
          holidayResponse.eventDate,
        );

        holiday = Holiday(
          id: holidayResponse.id,
          day: DateFormat('dd').format(tempDate),
          month: DateFormat('MMM').format(tempDate),
          title: holidayResponse.event,
          description: holidayResponse.description,
          dateTime: tempDate,
          isPublicHoliday: holidayResponse.isPublicHoliday,
        );
      } else {
        holiday = null;
      }

      if (recentAwardResponse != null) {
        award = Award(
          award_description: recentAwardResponse.award_description,
          award_name: recentAwardResponse.award_name,
          awarded_by: recentAwardResponse.awarded_by,
          awarded_date: recentAwardResponse.awarded_date,
          employee_name: recentAwardResponse.employee_name,
          gift_description: recentAwardResponse.gift_description,
          gift_item: recentAwardResponse.gift_item,
          id: recentAwardResponse.id,
          image: recentAwardResponse.image,
          awardImage: recentAwardResponse.awardImage,
          reward_code: recentAwardResponse.reward_code,
        );
      } else {
        award = null;
      }

      attendanceMethods = dashboardResponse.data.attedanceMethod;

      DateTime startTime = DateFormat("hh:mm a").parse(
        dashboardResponse.data.officeTime.startTime,
      );

      DateTime endTime = DateFormat("hh:mm a").parse(
        dashboardResponse.data.officeTime.endTime,
      );

      await AwesomeNotifications().cancelAllSchedules();

      for (var shift in dashboardResponse.data.shift_dates) {
        scheduleNewNotification(
          shift,
          "Please check in on time ⏱️⌛️",
          startTime.hour,
          startTime.minute,
          "Almost done with your shift 😄⌛️ Remember to checkout ⏱️",
          endTime.hour,
          endTime.minute,
        );
      }

      checkAD();
      await getFeatures();

      return dashboardResponse;
    } else {
      if (response.statusCode == 401) {
        preferences.clearPrefs();
        Get.offAll(LoginScreen());
      }

      var errorMessage = responseData['message'];

      print(errorMessage.toString());

      throw errorMessage;
    }
  }

  void makeWeeklyReport(List<dynamic> employeeWeeklyReport) {
    _weeklyReport.clear();

    for (var item in employeeWeeklyReport) {
      if (item != null) {
        double hr = item['productive_time_in_min'] / 60;
        _weeklyReport.add(hr);
      } else {
        _weeklyReport.add(0);
      }
    }

    barchartValue.clear();
    rawBarGroups.clear();
    showingBarGroups.clear();

    for (int i = 0; i < _weeklyReport.length; i++) {
      barchartValue.add(
        makeGroupData(i, _weeklyReport[i].toDouble()),
      );
    }

    rawBarGroups.addAll(barchartValue);
    showingBarGroups.addAll(rawBarGroups);

    notifyListeners();
  }

  void updateAttendanceStatus(
    EmployeeTodayAttendance employeeTodayAttendance,
  ) {
    _attendanceList['check-out'] = employeeTodayAttendance.checkOutAt;

    _attendanceList['check-in'] = employeeTodayAttendance.checkInAt;

    _syncProductionTimerFromDashboard(
      employeeTodayAttendance,
    );

    notifyListeners();
  }

  void updateOverView(Overview overview) {
    _overviewList.update(
      'present',
      (value) => overview.presentDays.toString(),
    );

    _overviewList.update(
      'holiday',
      (value) => overview.totalHolidays.toString(),
    );

    _overviewList.update(
      'leave',
      (value) => overview.totalLeaveTaken.toString(),
    );

    _overviewList.update(
      'request',
      (value) => overview.totalPendingLeaves.toString(),
    );

    _overviewList.update(
      'total_project',
      (value) => overview.total_assigned_projects.toString(),
    );

    _overviewList.update(
      'total_task',
      (value) => overview.total_pending_tasks.toString(),
    );

    _overviewList.update(
      'total_awards',
      (value) => overview.total_awards.toString(),
    );

    _overviewList.update(
      'active_training',
      (value) => overview.active_training.toString(),
    );

    _overviewList.update(
      'active_event',
      (value) => overview.active_event.toString(),
    );

    notifyListeners();
  }

  double calculateProdHour(int value) {
    double hour = value / 60;
    double hr = hour / Constant.TOTAL_WORKING_HOUR;

    return hr > 1 ? 1 : hr;
  }

  String calculateHourText(int value) {
    final minGone = value % 60;
    final hour = value ~/ 60;

    return "$hour hr $minGone min";
  }

  void controlFeatures(List<Feature> features) {
    Preferences preferences = Preferences();

    Map<String, String> featureList = <String, String>{};

    for (var feature in features) {
      featureList[feature.key] = feature.status;
    }

    preferences.setFeatures(featureList);
  }

  Future<bool> getCheckInStatus() async {
    try {
      Preferences preferences = Preferences();

      final position = await LocationStatus().determinePosition(
        await preferences.getWorkSpace(),
      );

      locationStatus.update(
        'latitude',
        (value) => position.latitude,
      );

      locationStatus.update(
        'longitude',
        (value) => position.longitude,
      );

      if (locationStatus['latitude'] != 0.0 &&
          locationStatus['longitude'] != 0.0) {
        return true;
      } else {
        Future.error(
          'Location is not detected. Please check if location is enabled and try again.',
        );

        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AttendanceStatusResponse> checkInAttendance() async {
    Preferences preferences = Preferences();

    var uri = Uri.parse(
      await preferences.getAppUrl() + Constant.CHECK_IN_URL,
    );

    String token = await preferences.getToken();

    Map<String, String> headers = {
      'Accept': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: {
        'router_bssid': await WifiInfo().info.getWifiBSSID() ?? "",
        'check_in_latitude': locationStatus['latitude'].toString(),
        'check_in_longitude': locationStatus['longitude'].toString(),
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData is Map && responseData['status'] == false) {
        throw responseData['message'] ?? 'Check-in failed';
      }

      final attendanceResponse =
          AttendanceStatusResponse.fromJson(responseData);

      updateAttendanceStatus(
        EmployeeTodayAttendance(
          checkInAt: attendanceResponse.data.checkInAt,
          checkOutAt: attendanceResponse.data.checkOutAt,
          productionTime: attendanceResponse.data.productiveTimeInMin,
        ),
      );

      debugPrint('ATTENDANCE: Check-in API succeeded');

      await _refreshLocationPolicy();

      return attendanceResponse;
    } else {
      if (response.statusCode == 401) {
        preferences.clearPrefs();
        Get.offAll(LoginScreen());
      }

      var errorMessage = responseData['message'];
      throw errorMessage;
    }
  }

  Future<void> scheduleNewNotification(
    String date,
    String startMessage,
    int startHr,
    int startMin,
    String endMessage,
    int endHr,
    int endMin,
  ) async {
    final convertedDate = DateFormat('yyyy-MM-dd').parse(date);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random.Random().nextInt(1000000),
        channelKey: 'digital_hr_channel',
        title: "Hello There",
        body: startMessage,
        notificationLayout: NotificationLayout.Default,
        payload: {'notificationId': '1234567890'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'REDIRECT',
          label: 'Open',
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
          isDangerousOption: true,
        ),
      ],
      schedule: NotificationCalendar.fromDate(
        date: DateTime(
          convertedDate.year,
          convertedDate.month,
          convertedDate.day,
          startHr,
          startMin - 15,
        ),
      ),
    );

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random.Random().nextInt(1000000),
        channelKey: 'digital_hr_channel',
        title: "Hello There",
        body: endMessage,
        notificationLayout: NotificationLayout.Default,
        payload: {'notificationId': '1234567890'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'REDIRECT',
          label: 'Open',
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
        ),
      ],
      schedule: NotificationCalendar.fromDate(
        date: DateTime(
          convertedDate.year,
          convertedDate.month,
          convertedDate.day,
          endHr,
          endMin - 15,
        ),
      ),
    );
  }

  Future<AttendanceStatusResponse> checkOutAttendance() async {
    Preferences preferences = Preferences();

    var uri = Uri.parse(
      await preferences.getAppUrl() + Constant.CHECK_OUT_URL,
    );

    String token = await preferences.getToken();

    Map<String, String> headers = {
      'Accept': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: {
        'router_bssid': await WifiInfo().wifiBSSID() ?? "",
        'check_out_latitude': locationStatus['latitude'].toString(),
        'check_out_longitude': locationStatus['longitude'].toString(),
      },
    );

    debugPrint(response.body.toString());

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData is Map && responseData['status'] == false) {
        throw responseData['message'] ?? 'Check-out failed';
      }

      final attendanceResponse =
          AttendanceStatusResponse.fromJson(responseData);

      updateAttendanceStatus(
        EmployeeTodayAttendance(
          checkInAt: attendanceResponse.data.checkInAt,
          checkOutAt: attendanceResponse.data.checkOutAt,
          productionTime: attendanceResponse.data.productiveTimeInMin,
        ),
      );

      debugPrint('ATTENDANCE: Check-out API succeeded');

      await _refreshLocationPolicy();

      return attendanceResponse;
    } else {
      if (response.statusCode == 401) {
        preferences.clearPrefs();
        Get.offAll(LoginScreen());
      }

      var errorMessage = responseData['message'];
      throw errorMessage;
    }
  }

  Future<AttendanceStatusResponse> verifyAttendanceApi(
    String type,
    String note, {
    String attendanceStatus = "",
    String identifier = "",
  }) async {
    Preferences preferences = Preferences();

    var uri = Uri.parse(
      await preferences.getAppUrl() + Constant.ATTENDANCE_URL,
    );

    print(identifier);

    String token = await preferences.getToken();

    Map<String, String> headers = {
      'Accept': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final http.Client client = LoggingMiddleware(http.Client());

    final response = await client.post(
      uri,
      headers: headers,
      body: {
        'attendance_type': type,
        'latitude': type == "wifi" ? locationStatus['latitude'].toString() : "",
        'longitude':
            type == "wifi" ? locationStatus['longitude'].toString() : "",
        'router_bssid':
            type == "wifi" ? await WifiInfo().wifiBSSID() ?? "" : "",
        'identifier': type != "wifi" ? identifier : "",
        'attendance_status_type': type == "wifi" ? attendanceStatus : "",
        'note': note,
      },
    );

    log(response.body.toString());

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData is Map && responseData['status'] == false) {
        throw responseData['message'] ?? 'Attendance failed';
      }

      final attendanceResponse =
          AttendanceStatusResponse.fromJson(responseData);

      updateAttendanceStatus(
        EmployeeTodayAttendance(
          checkInAt: attendanceResponse.data.checkInAt,
          checkOutAt: attendanceResponse.data.checkOutAt,
          productionTime: attendanceResponse.data.productiveTimeInMin,
        ),
      );

      noteController.clear();

      if (responseData is Map && responseData['status'] == true) {
        debugPrint('ATTENDANCE: Verify attendance succeeded');
        await _refreshLocationPolicy();
      }

      return attendanceResponse;
    } else {
      if (response.statusCode == 401) {
        preferences.clearPrefs();
        Get.offAll(LoginScreen());
      }

      var errorMessage = responseData['message'];
      throw errorMessage;
    }
  }

  final Color leftBarColor = Color(0xffFFFFFF);

  final double width = 15;

  BarChartGroupData makeGroupData(int x, double y1) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: leftBarColor,
          width: width,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _productionTimer?.cancel();
    noteController.dispose();
    super.dispose();
  }
}
