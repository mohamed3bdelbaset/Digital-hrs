import 'package:cnattendance/provider/prefprovider.dart';
import 'package:cnattendance/screen/dashboard/homescreen.dart';
import 'package:cnattendance/screen/dashboard/leavescreen.dart';
import 'package:cnattendance/screen/dashboard/attendancescreen.dart';
import 'package:cnattendance/screen/dashboard/morescreen.dart';
import 'package:cnattendance/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late final PersistentTabController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PersistentTabController(initialIndex: 0);

    // Load user only once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<PrefProvider>().getUser();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ItemConfig getItemConfig(Icon icon, String title) {
    return ItemConfig(
      icon: icon,
      activeColorSecondary: Colors.white,
      activeForegroundColor: Colors.white,
      inactiveBackgroundColor: Colors.white30,
      inactiveForegroundColor: Colors.white30,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(
      getAppTheme() ? radialBoxTheme : 0xff000000,
    );

    return Scaffold(
      body: PersistentTabView(
        controller: _controller,
        backgroundColor: backgroundColor,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        tabs: [
          PersistentTabConfig(
            screen: HomeScreen(_controller),
            item: getItemConfig(
              const Icon(Icons.home_filled),
              translate('dashboard_screen.home'),
            ),
          ),
          PersistentTabConfig(
            screen: LeaveScreen(),
            item: getItemConfig(
              const Icon(Icons.sick),
              translate('dashboard_screen.leave'),
            ),
          ),
          PersistentTabConfig(
            screen: AttendanceScreen(),
            item: getItemConfig(
              const Icon(Icons.co_present_outlined),
              translate('dashboard_screen.attendance'),
            ),
          ),
          PersistentTabConfig(
            screen: MoreScreen(),
            item: getItemConfig(
              const Icon(Icons.more),
              translate('dashboard_screen.more'),
            ),
          ),
        ],
        navBarBuilder: (navBarConfig) {
          return Style9BottomNavBar(
            navBarConfig: navBarConfig,
            navBarDecoration: NavBarDecoration(
              color: backgroundColor,
            ),
          );
        },
      ),
    );
  }
}
