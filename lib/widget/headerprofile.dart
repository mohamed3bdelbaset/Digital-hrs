import 'package:cached_network_image/cached_network_image.dart';
import 'package:cnattendance/provider/prefprovider.dart';
import 'package:cnattendance/screen/profile/NotificationScreen.dart';
import 'package:cnattendance/screen/profile/profilescreen.dart';
import 'package:cnattendance/provider/dashboardprovider.dart';
import 'package:cnattendance/widget/customalertdialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';

import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';

import 'package:cnattendance/live_location/data/repositories/location_repository.dart';

class HeaderProfile extends StatefulWidget {
  const HeaderProfile({super.key});

  @override
  State<HeaderProfile> createState() => HeaderState();
}

class HeaderState extends State<HeaderProfile> {
  bool _isSendingLocation = false;

  final Battery _battery = Battery();

  // SEND LOCATION
  Future<void> sendLocation() async {
    if (_isSendingLocation) return;

    setState(() {
      _isSendingLocation = true;
    });

    EasyLoading.show(
      status: translate('loader.requesting'),
      maskType: EasyLoadingMaskType.black,
    );

    try {
      // Check location service.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Please enable location services.');
      }

      // Check permission.
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied. '
          'Please enable it from settings.',
        );
      }

      // Get current position.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      // Get battery percentage.
      final batteryLevel = await _battery.batteryLevel;

      // Send location using the existing repository.
      final repository = LocationRepository();

      final response = await repository.sendLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        batteryLevel: batteryLevel,
        isMock: position.isMocked,
        recordedAt: position.timestamp,
      );

      if (!mounted) return;

      EasyLoading.dismiss(animation: true);

      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            child: CustomAlertDialog(
              response.stored
                  ? 'Location sent successfully.'
                  : 'Location was not stored.',
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      EasyLoading.dismiss(animation: true);

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

      if (mounted) {
        setState(() {
          _isSendingLocation = false;
        });
      }
    }
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrefProvider>();

    final dashboardProvider = context.watch<DashboardProvider>();

    final isEnabledLocation = dashboardProvider.isLocationEnabled;

    return GestureDetector(
      onTap: () {
        pushScreen(
          context,
          screen: ProfileScreen(),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.fade,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: provider.avatar.trim().isEmpty
                  ? Image.asset(
                      'assets/images/dummy_avatar.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: provider.avatar,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (_, __) {
                        return Image.asset(
                          'assets/images/dummy_avatar.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      },
                      errorWidget: (_, __, ___) {
                        return Image.asset(
                          'assets/images/dummy_avatar.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),

            const SizedBox(width: 10),

            // User information
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translate('home_screen.hello_there'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    provider.fullname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    provider.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Send location
            if (isEnabledLocation)
              Tooltip(
                message: 'Send Location',
                child: IconButton(
                  onPressed: _isSendingLocation ? null : sendLocation,
                  icon: _isSendingLocation
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                        ),
                ),
              ),

            // Notifications
            Tooltip(
              message: 'Notifications',
              child: IconButton(
                onPressed: () {
                  pushScreen(
                    context,
                    screen: NotificationScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.fade,
                  );
                },
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
