import 'dart:async';
import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:cnattendance/live_location/data/repositories/location_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';

const String _serviceTitle = 'Location Tracking Active';

const String _serviceContent =
    'Your location is being tracked during your active shift.';

class LocationBackgroundService {
  static const String notificationChannelId = 'location_tracking';
  static const int notificationId = 501;

  final FlutterBackgroundService _service = FlutterBackgroundService();

  Timer? _recheckTimer;

  bool _initialized = false;
  bool _listenerRegistered = false;

  // INITIALIZE SERVICE
  Future<void> initialize() async {
    if (_initialized) return;

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: locationServiceEntryPoint,
        autoStart: false,
        autoStartOnBoot: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: _serviceTitle,
        initialNotificationContent: _serviceContent,
        foregroundServiceNotificationId: notificationId,
        foregroundServiceTypes: [
          AndroidForegroundType.location,
        ],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: locationServiceEntryPoint,
        onBackground: iosBackgroundEntryPoint,
      ),
    );

    _initialized = true;

    // Listen for restart requests from background isolate.
    if (!_listenerRegistered) {
      _listenerRegistered = true;

      _service.on('scheduleRestart').listen((event) {
        final seconds = (event?['seconds'] as num?)?.toInt() ?? 900;

        debugPrint(
          'MAIN ISOLATE: Restart requested after $seconds seconds',
        );

        scheduleRestart(seconds);
      });
    }
  }

  // START OR REFRESH SERVICE
  Future<void> refreshPolicy() async {
    await initialize();

    final running = await _service.isRunning();

    if (!running) {
      debugPrint('MAIN ISOLATE: Starting location service');

      await _service.startService();
    } else {
      debugPrint('MAIN ISOLATE: Refreshing location policy');

      _service.invoke('refreshPolicy');
    }
  }

  // SCHEDULE RESTART
  void scheduleRestart(int seconds) {
    _recheckTimer?.cancel();

    final delay = seconds.clamp(1, 86400).toInt();

    debugPrint(
      'MAIN ISOLATE: Service will restart in $delay seconds',
    );

    _recheckTimer = Timer(
      Duration(seconds: delay),
      () async {
        _recheckTimer = null;

        debugPrint('MAIN ISOLATE: Recheck timer completed');

        await refreshPolicy();
      },
    );
  }
}

// BACKGROUND SERVICE ENTRY POINT
@pragma('vm:entry-point')
Future<void> locationServiceEntryPoint(
  ServiceInstance service,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await GetStorage.init();

  final repository = LocationRepository();
  final battery = Battery();

  bool shouldStop = false;
  bool refreshRequested = false;

  Completer<void>? wakeUpCompleter;

  // UPDATE STATUS
  void updateStatus({
    required bool tracking,
    String? reason,
  }) {
    service.invoke('locationStatus', {
      'tracking': tracking,
      'reason': reason,
    });
  }

  // MANUAL STOP
  void stopService() {
    if (shouldStop) return;

    debugPrint('BACKGROUND SERVICE: Manual stop requested');

    shouldStop = true;

    updateStatus(
      tracking: false,
      reason: 'Service stopped manually',
    );

    final completer = wakeUpCompleter;

    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }

    service.stopSelf();
  }

  // STOP SERVICE AND REQUEST RESTART
  Future<void> stopAndScheduleRecheck({
    required int seconds,
    required String reason,
  }) async {
    if (shouldStop) return;

    final delay = seconds.clamp(1, 86400).toInt();

    debugPrint('BACKGROUND SERVICE: Tracking disabled');
    debugPrint('REASON: $reason');
    debugPrint('RECHECK AFTER: $delay seconds');

    shouldStop = true;

    updateStatus(
      tracking: false,
      reason: reason,
    );

    // Send restart request to Main Isolate.
    service.invoke('scheduleRestart', {
      'seconds': delay,
    });

    // Give the Main Isolate time to receive the event.
    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );

    debugPrint('BACKGROUND SERVICE: Stopping completely');

    service.stopSelf();
  }

  // WAIT WITH EARLY WAKE-UP SUPPORT
  Future<void> waitForNextCycle(Duration duration) async {
    if (shouldStop) return;

    if (refreshRequested) {
      refreshRequested = false;
      return;
    }

    final completer = Completer<void>();

    wakeUpCompleter = completer;

    await Future.any<void>([
      Future<void>.delayed(duration),
      completer.future,
    ]);

    if (identical(wakeUpCompleter, completer)) {
      wakeUpCompleter = null;
    }

    refreshRequested = false;
  }

  // STOP LISTENER
  service.on('stopService').listen((event) {
    stopService();
  });

  // REFRESH POLICY LISTENER
  service.on('refreshPolicy').listen((event) {
    if (shouldStop) return;

    debugPrint('POLICY: Refresh requested');

    refreshRequested = true;

    final completer = wakeUpCompleter;

    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  });

  // UPDATE NOTIFICATION LISTENER
  service.on('updateNotification').listen((event) async {
    if (service is AndroidServiceInstance) {
      final content = event?['content'] as String?;

      await service.setForegroundNotificationInfo(
        title: _serviceTitle,
        content: content ?? _serviceContent,
      );
    }
  });

  // ANDROID FOREGROUND NOTIFICATION
  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: _serviceTitle,
      content: _serviceContent,
    );
  }

  debugPrint('BACKGROUND SERVICE: Started');

  updateStatus(
    tracking: false,
    reason: 'Checking server policy',
  );

  // MAIN TRACKING LOOP
  while (!shouldStop) {
    try {
      // 1. GET SERVER POLICY
      debugPrint('POLICY: Requesting location policy...');

      final policy = await repository.getPolicy();

      debugPrint('========== LOCATION POLICY ==========');
      debugPrint('Tracking: ${policy.tracking}');
      debugPrint('Reason: ${policy.reason}');
      debugPrint('Interval: ${policy.intervalSeconds}');
      debugPrint('Recheck: ${policy.recheckAfterSeconds}');
      debugPrint('Attendance ID: ${policy.attendanceId}');
      debugPrint('=====================================');

      if (shouldStop) break;

      // 2. TRACKING DISABLED
      if (!policy.tracking) {
        final seconds = policy.recheckAfterSeconds.clamp(1, 86400).toInt();

        await stopAndScheduleRecheck(
          seconds: seconds,
          reason: policy.reason ?? '',
        );

        break;
      }

      updateStatus(
        tracking: true,
        reason: 'Location tracking active',
      );

      // 3. CHECK GPS
      debugPrint('LOCATION: Checking GPS...');

      final gpsEnabled = await Geolocator.isLocationServiceEnabled();

      final permission = await Geolocator.checkPermission();

      if (shouldStop) break;

      if (!gpsEnabled ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint(
          'LOCATION UNAVAILABLE: GPS=$gpsEnabled, permission=$permission',
        );

        final seconds = policy.intervalSeconds.clamp(1, 86400).toInt();

        await waitForNextCycle(
          Duration(seconds: seconds),
        );

        continue;
      }

      if (permission == LocationPermission.whileInUse) {
        debugPrint(
          'WARNING: Only while-in-use location permission is granted',
        );
      }

      // 4. GET CURRENT POSITION
      if (shouldStop) break;

      debugPrint('LOCATION: Getting current position...');

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (shouldStop) break;

      // 5. VALIDATE POSITION
      final latitude = position.latitude;
      final longitude = position.longitude;

      if (!latitude.isFinite ||
          !longitude.isFinite ||
          latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180 ||
          (latitude == 0 && longitude == 0)) {
        debugPrint('LOCATION: Invalid coordinates');

        final seconds = policy.intervalSeconds.clamp(1, 86400).toInt();

        await waitForNextCycle(
          Duration(seconds: seconds),
        );

        continue;
      }

      debugPrint('========== LOCATION RESULT ==========');
      debugPrint('Latitude: $latitude');
      debugPrint('Longitude: $longitude');
      debugPrint('Accuracy: ${position.accuracy}');
      debugPrint('Timestamp: ${position.timestamp}');
      debugPrint('Is Mock: ${position.isMocked}');
      debugPrint('======================================');

      // 6. GET BATTERY LEVEL
      final batteryLevel = await battery.batteryLevel;

      if (shouldStop) break;

      // 7. SEND LOCATION
      debugPrint('LOCATION: Sending to server...');

      final response = await repository.sendLocation(
        latitude: latitude,
        longitude: longitude,
        accuracy: position.accuracy,
        isMock: position.isMocked,
        recordedAt: position.timestamp,
        batteryLevel: batteryLevel,
      );

      debugPrint('========== SEND LOCATION RESULT ==========');
      debugPrint('Stored: ${response.stored}');
      debugPrint('Reason: ${response.reason}');
      debugPrint('Tracking: ${response.tracking}');
      debugPrint('Next Ping: ${response.nextPingAfterSeconds}');
      debugPrint('==========================================');

      if (shouldStop) break;

      // 8. SERVER DISABLED TRACKING
      if (!response.tracking) {
        final seconds = response.nextPingAfterSeconds.clamp(1, 86400).toInt();

        await stopAndScheduleRecheck(
          seconds: seconds,
          reason: response.reason ?? '',
        );

        break;
      }

      // 9. LOCATION NOT STORED
      if (!response.stored) {
        debugPrint('LOCATION NOT STORED: ${response.reason}');

        final seconds = policy.recheckAfterSeconds.clamp(1, 86400).toInt();

        await waitForNextCycle(
          Duration(seconds: seconds),
        );

        continue;
      }

      // 10. WAIT FOR NEXT SERVER PING
      final nextSeconds = response.nextPingAfterSeconds.clamp(1, 86400).toInt();

      debugPrint('LOCATION STORED SUCCESSFULLY');
      debugPrint('NEXT LOCATION IN: $nextSeconds seconds');

      await waitForNextCycle(
        Duration(seconds: nextSeconds),
      );
    } catch (e, stackTrace) {
      debugPrint('BACKGROUND TRACKING ERROR: $e');
      debugPrint('BACKGROUND TRACKING STACK: $stackTrace');

      if (shouldStop) break;

      await waitForNextCycle(
        const Duration(seconds: 60),
      );
    }
  }

  debugPrint('BACKGROUND SERVICE: Stopped');
}

// IOS BACKGROUND ENTRY POINT
@pragma('vm:entry-point')
Future<bool> iosBackgroundEntryPoint(
  ServiceInstance service,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await GetStorage.init();

  return true;
}
