import 'package:cnattendance/provider/dashboardprovider.dart';
import 'package:cnattendance/widget/customalertdialog.dart';
import 'package:cnattendance/widget/radialDecoration.dart';
import 'package:cnattendance/widget/buttonborder.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';

class AttedanceBottomSheet extends StatefulWidget {
  const AttedanceBottomSheet({super.key});

  @override
  State<AttedanceBottomSheet> createState() => AttendanceBottomSheetState();
}

class AttendanceBottomSheetState extends State<AttedanceBottomSheet> {
  bool isLoading = false;

  // ATTENDANCE ACTIONS
  Future<void> onCheckIn(String note) async {
    await _submitAttendance(note, 'checkIn');
  }

  Future<void> onCheckOut(String note) async {
    await _submitAttendance(note, 'checkOut');
  }

  // SUBMIT ATTENDANCE
  Future<void> _submitAttendance(
    String note,
    String attendanceStatus,
  ) async {
    if (isLoading) return;

    final provider = context.read<DashboardProvider>();

    setState(() {
      isLoading = true;
    });

    EasyLoading.show(
      status: translate('loader.requesting'),
      maskType: EasyLoadingMaskType.black,
    );

    bool closeSheet = false;

    try {
      // Check attendance permission/status.
      final status = await provider.getCheckInStatus();

      if (!status) return;

      // Submit attendance.
      final response = await provider.verifyAttendanceApi(
        'wifi',
        note,
        attendanceStatus: attendanceStatus,
      );

      if (!mounted) return;

      closeSheet = true;

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            child: CustomAlertDialog(response.message),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      if (e.toString() == 'Unauthenticated') {
        closeSheet = true;
        Navigator.of(context).pop();
        return;
      }

      closeSheet = true;

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            child: CustomAlertDialog(e.toString()),
          );
        },
      );
    } finally {
      EasyLoading.dismiss(animation: true);

      if (mounted && !closeSheet) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ATTENDANCE BUTTON
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback? onPressed,
    Color color = const Color(0xff036eb7),
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white24,
          disabledForegroundColor: Colors.white54,
          shape: ButtonBorder(),
          elevation: 0,
        ),
      ),
    );
  }

  // COMPLETED VIEW
  Widget _buildCompletedView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 45,
          ),
          SizedBox(height: 10),
          Text(
            'Attendance Completed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'You have already checked out today.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DashboardProvider>();

    final attendanceList = provider.attendanceList;

    final checkIn = attendanceList['check-in']?.toString() ?? '-';

    final checkOut = attendanceList['check-out']?.toString() ?? '-';

    // Attendance states.
    final hasCheckedIn = checkIn.isNotEmpty && checkIn != '-';

    final hasCheckedOut = checkOut.isNotEmpty && checkOut != '-';

    final canCheckIn = !hasCheckedIn;

    final canCheckOut = hasCheckedIn && !hasCheckedOut;

    final attendanceCompleted = hasCheckedIn && hasCheckedOut;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !isLoading,
      child: Container(
        decoration: RadialDecoration(),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          bottomInset + 20,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 18),

              // Header
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${translate('home_screen.check_in')} / '
                      '${translate('home_screen.check_out')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Attendance status
              if (hasCheckedIn) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Check In: $checkIn',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              if (hasCheckedOut) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Check Out: $checkOut',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Note
              if (provider.isNoteEnabled && !attendanceCompleted) ...[
                TextField(
                  controller: provider.noteController,
                  enabled: !isLoading,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: translate('home_screen.note'),
                    hintStyle: const TextStyle(
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.12),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Check In button
              if (canCheckIn)
                _buildActionButton(
                  title: translate('home_screen.check_in'),
                  icon: Icons.login_rounded,
                  onPressed: isLoading
                      ? null
                      : () => onCheckIn(
                            provider.noteController.text,
                          ),
                ),

              // Check Out button
              if (canCheckOut)
                _buildActionButton(
                  title: translate('home_screen.check_out'),
                  icon: Icons.logout_rounded,
                  color: const Color(0xff762150),
                  onPressed: isLoading
                      ? null
                      : () => onCheckOut(
                            provider.noteController.text,
                          ),
                ),

              // Completed
              if (attendanceCompleted) _buildCompletedView(),

              // Loading
              if (isLoading) ...[
                const SizedBox(height: 18),
                const LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
