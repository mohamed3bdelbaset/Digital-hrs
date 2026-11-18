import 'dart:convert';
import 'dart:io';

import 'package:cnattendance/provider/dashboardprovider.dart';
import 'package:cnattendance/provider/prefprovider.dart';
import 'package:cnattendance/utils/constant.dart';
import 'package:cnattendance/widget/attendance_bottom_sheet.dart';
import 'package:cnattendance/widget/customalertdialog.dart';
import 'package:cnattendance/widget/customnfcdialog.dart';
import 'package:cnattendance/widget/profile/note_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:one_clock/one_clock.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ripple_wave/ripple_wave.dart';

import '../customqrscanner.dart';

// ignore: must_be_immutable
class CheckAttendance extends StatefulWidget {
  CheckAttendance({super.key});

  String formattedDate =
      DateFormat('EEEE , MMMM d , yyyy').format(DateTime.now());

  @override
  State<CheckAttendance> createState() => CheckAttendanceState();
}

class CheckAttendanceState extends State<CheckAttendance> {
  // UPDATE DATE
  void _updateDate() {
    widget.formattedDate =
        DateFormat('EEEE , MMMM d , yyyy').format(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDate();
  }

  // NFC SCANNER
  void showNFCScanner() {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            child: CustomNfcDialog(NFCMODE.scan),
          );
        },
      );
    } else if (Platform.isIOS) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          onAttendanceVerify(
            "nfc",
            base64.encode(
              utf8.encode(findKey(tag.data)),
            ),
          );

          NfcManager.instance.stopSession();
        },
      );
    }
  }

  // QR SCANNER
  Future<void> scanQr() async {
    final result = await showCustomQrScanner(context);

    if (!mounted || result == null || result.trim().isEmpty) {
      return;
    }

    final provider = context.read<DashboardProvider>();

    if (provider.isNoteEnabled) {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) {
          return NoteBottomSheet(result, "qr");
        },
      );
    } else {
      onAttendanceVerify("qr", result);
    }
  }

  // ATTENDANCE VERIFY
  Future<void> onAttendanceVerify(
    String type,
    String identifier,
  ) async {
    final provider = context.read<DashboardProvider>();

    try {
      EasyLoading.show(
        status: translate('loader.requesting'),
        maskType: EasyLoadingMaskType.black,
      );

      final response = await provider.verifyAttendanceApi(
        type,
        "",
        identifier: identifier,
      );

      if (!mounted) return;

      EasyLoading.dismiss(animation: true);

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: CustomAlertDialog(response.message),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      EasyLoading.dismiss(animation: true);

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: CustomAlertDialog(e.toString()),
          );
        },
      );
    }
  }

  // ATTENDANCE BUTTON ACTION
  Future<void> _handleAttendanceTap() async {
    final attendanceType = context.read<PrefProvider>().attendanceType;

    if (attendanceType == "QR") {
      await scanQr();
      return;
    }

    if (attendanceType == "NFC") {
      final isAvailable = await NfcManager.instance.isAvailable();

      if (!mounted) return;

      if (!isAvailable) {
        showSnackbar(
          "NFC is not present. Please enable NFC or try different method",
        );
        return;
      }

      showNFCScanner();
      return;
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) {
        return AttedanceBottomSheet();
      },
    );
  }

  // ATTENDANCE BUTTON
  Widget _buildAttendanceButton({
    required bool animated,
    required String attendanceType,
    required bool isCheckedIn,
  }) {
    final buttonColor = isCheckedIn ? Color(0xff762150) : Color(0xff225788);

    final animationAsset = attendanceType == "QR"
        ? 'assets/raw/qr.json'
        : attendanceType == "NFC"
            ? 'assets/raw/nfc.json'
            : 'assets/raw/fingerprint.json';

    final button = SizedBox(
      height: 180,
      width: 180,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(90),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: buttonColor,
            child: IconButton(
              iconSize: 70,
              onPressed: _handleAttendanceTap,
              icon: Lottie.asset(
                animationAsset,
                width: 60,
                height: 60,
                repeat: animated,
              ),
            ),
          ),
        ),
      ),
    );

    if (!animated) {
      return Center(child: button);
    }

    return Center(
      child: SizedBox(
        width: 280,
        child: RippleWave(
          color: buttonColor,
          repeat: true,
          waveCount: 5,
          child: button,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();

    final attendanceList = dashboardProvider.attendanceList;

    final attendanceType = context.watch<PrefProvider>().attendanceType;

    final attendanceMethod = dashboardProvider.attendanceMethods;

    final animated = dashboardProvider.animated;

    // Preserve existing attendance type behavior.
    context.read<PrefProvider>().getAttendanceType(attendanceMethod);

    final isCheckedIn =
        attendanceList['check-in'] != "-" && attendanceList['check-out'] == "-";

    final productionTime = attendanceList['production-time'] ?? 0.0;

    final safeProductionTime =
        productionTime is num ? productionTime.toDouble().clamp(0.0, 1.0) : 0.0;

    final productionHour =
        attendanceList['production_hour']?.toString() ?? "0 hr 0 min";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CLOCK
          Center(
            child: Stack(
              children: [
                Positioned(
                  top: 5,
                  left: 0,
                  child: DigitalClock(
                    showSeconds: true,
                    isLive: false,
                    textScaleFactor: .9,
                    format: "a",
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    digitalClockTextColor: Colors.white,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    datetime: DateTime.now(),
                  ),
                ),
                DigitalClock(
                  showSeconds: true,
                  isLive: false,
                  textScaleFactor: 2.2,
                  format: "hh:mm",
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  digitalClockTextColor: Colors.white,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  datetime: DateTime.now(),
                ),
                Positioned(
                  top: 15,
                  right: 0,
                  child: DigitalClock(
                    showSeconds: true,
                    isLive: false,
                    textScaleFactor: .9,
                    format: "ss",
                    padding: EdgeInsets.zero,
                    digitalClockTextColor: Colors.white,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    datetime: DateTime.now(),
                  ),
                ),
              ],
            ),
          ),

          // DATE
          Center(
            child: Text(
              widget.formattedDate,
              style: const TextStyle(color: Colors.white),
            ),
          ),

          // ATTENDANCE BUTTON
          if (attendanceMethod.isNotEmpty)
            _buildAttendanceButton(
              animated: animated,
              attendanceType: attendanceType,
              isCheckedIn: isCheckedIn,
            ),

          // ATTENDANCE LABEL
          if (attendanceMethod.isNotEmpty)
            Center(
              child: Text(
                "${translate('home_screen.check_in')} | ${translate('home_screen.check_out')}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),

          const SizedBox(height: 15),

          // PRODUCTION TIME PROGRESS
          SizedBox(
            width: double.infinity,
            child: LinearPercentIndicator(
              animation: true,
              animationDuration: 1000,
              lineHeight: 30,
              padding: EdgeInsets.zero,
              percent: safeProductionTime,
              center: Text(
                productionHour,
                style: const TextStyle(color: Colors.white),
              ),
              barRadius: const Radius.circular(20),
              backgroundColor: Color(0xff3dFFFFFF),
              progressColor:
                  isCheckedIn ? Color(0xffe82e5f) : Color(0xff3b98cc),
            ),
          ),

          // CHECK IN / CHECK OUT TIMES
          Container(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  attendanceList['check-in']?.toString() ?? "-",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  attendanceList['check-out']?.toString() ?? "-",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
