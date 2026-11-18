import 'package:cnattendance/provider/dashboardprovider.dart';
import 'package:cnattendance/widget/customalertdialog.dart';
import 'package:cnattendance/widget/radialDecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:cnattendance/widget/buttonborder.dart';

class NoteBottomSheet extends StatefulWidget {
  final String identifier;
  final String type;

  const NoteBottomSheet(this.identifier, this.type, {super.key});

  @override
  State<NoteBottomSheet> createState() => NoteBottomSheetState();
}

class NoteBottomSheetState extends State<NoteBottomSheet> {
  bool isEnabled = true;
  bool isLoading = false;

  Future<void> onAttendanceVerify(
    String type,
    String identifier,
  ) async {
    if (isLoading || !isEnabled) return;

    final provider = context.read<DashboardProvider>();

    setState(() {
      isLoading = true;
      isEnabled = false;
    });

    EasyLoading.show(
      status: translate('loader.requesting'),
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final response = await provider.verifyAttendanceApi(
        type,
        "",
        identifier: identifier,
      );

      if (!mounted) return;

      Navigator.pop(context);

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

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: CustomAlertDialog(e.toString()),
          );
        },
      );
    } finally {
      EasyLoading.dismiss(animation: true);

      if (mounted) {
        setState(() {
          isLoading = false;
          isEnabled = true;
        });
      }
    }
  }

  Future<void> submitAttendance() async {
    if (isLoading || !isEnabled) return;

    final provider = context.read<DashboardProvider>();

    setState(() {
      isLoading = true;
      isEnabled = false;
    });

    EasyLoading.show(
      status: translate('loader.requesting'),
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final status = await provider.getCheckInStatus();

      if (!status) return;

      final response = await provider.verifyAttendanceApi(
        widget.type,
        provider.noteController.text,
        identifier: widget.identifier,
      );

      if (!mounted) return;

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: CustomAlertDialog(response.message),
          );
        },
      );
    } catch (e) {
      debugPrint('Attendance Error: $e');

      if (!mounted) return;

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: CustomAlertDialog(e.toString()),
          );
        },
      );
    } finally {
      EasyLoading.dismiss(animation: true);

      if (mounted) {
        setState(() {
          isLoading = false;
          isEnabled = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DashboardProvider>();

    return PopScope(
      canPop: !isLoading,
      child: Container(
        decoration: RadialDecoration(),
        padding: EdgeInsets.only(
          top: 20,
          right: 20,
          left: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${translate('home_screen.check_in')} / ${translate('home_screen.check_out')}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: provider.isNoteEnabled,
                child: TextField(
                  controller: provider.noteController,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: 3,
                  onTapOutside: (event) {
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus &&
                        currentFocus.focusedChild != null) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                  },
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: translate('home_screen.note'),
                    hintStyle: const TextStyle(color: Colors.white),
                    labelStyle: const TextStyle(color: Colors.white),
                    fillColor: Colors.white24,
                    filled: true,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(right: 5),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xff036eb7),
                            shape: ButtonBorder(),
                          ),
                          onPressed:
                              isEnabled && !isLoading ? submitAttendance : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Text(
                              translate('create_salary_screen.submit'),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xff036eb7),
                            shape: ButtonBorder(),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Text(
                              translate('common.go_back'),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
