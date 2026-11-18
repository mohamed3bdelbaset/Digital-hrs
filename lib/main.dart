import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cnattendance/data/source/datastore/preferences.dart';
import 'package:cnattendance/live_location/services/location_background_service.dart';
import 'package:cnattendance/model/auth.dart';
import 'package:cnattendance/provider/attendancereportprovider.dart';
import 'package:cnattendance/provider/dashboardprovider.dart';
import 'package:cnattendance/provider/leaveprovider.dart';
import 'package:cnattendance/provider/morescreenprovider.dart';
import 'package:cnattendance/provider/payslipdetailprovider.dart';
import 'package:cnattendance/provider/payslipprovider.dart';
import 'package:cnattendance/provider/prefprovider.dart';
import 'package:cnattendance/provider/profileprovider.dart';
import 'package:cnattendance/provider/ssfprovider.dart';
import 'package:cnattendance/screen/auth/login_screen.dart';
import 'package:cnattendance/screen/dashboard/dashboard_screen.dart';
import 'package:cnattendance/screen/general/generalscreen.dart';
import 'package:cnattendance/screen/profile/chatscreen.dart';
import 'package:cnattendance/screen/profile/editprofilescreen.dart';
import 'package:cnattendance/screen/profile/groupchatscreen.dart';
import 'package:cnattendance/screen/profile/payslipdetailscreen.dart';
import 'package:cnattendance/screen/profile/profilescreen.dart';
import 'package:cnattendance/screen/profile/meetingdetailscreen.dart';
import 'package:cnattendance/screen/splashscreen.dart';
import 'package:cnattendance/utils/navigationservice.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:flutter_translate/flutter_translate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Localization
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en_US',
    supportedLocales: [
      'en_US',
      'ar',
      'es',
      'ne',
      'fa',
      'in',
      'pt',
      'ru',
      'de',
      'tr',
      'fr',
    ],
  );

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Local storage
  await GetStorage.init();

  // Firebase background messages
  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  // Firestore
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);

  await FirebaseFirestore.instance.clearPersistence();

  // Firebase notification permission
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('User granted permission');
  } else {
    debugPrint('User declined or has not accepted permission');
  }

  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  if (Platform.isIOS) {
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    debugPrint('APNS Token: $apnsToken');
    await Future.delayed(const Duration(seconds: 2));
  }

  // Awesome Notifications
  await AwesomeNotifications().initialize(
    'resource://drawable/app_icon',
    [
      // Existing notification channel
      NotificationChannel(
        channelGroupKey: 'digital_hr_group',
        channelKey: 'digital_hr_channel',
        channelName: 'Digital Hr notifications',
        channelDescription: 'Digital HR Alert',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),

      // Location tracking notification channel
      NotificationChannel(
        channelKey: LocationBackgroundService.notificationChannelId,
        channelName: 'Location Tracking',
        channelDescription:
            'Background location updates during employee working hours',
        importance: NotificationImportance.Low,
        playSound: false,
        enableVibration: false,
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'digital_hr_group',
        channelGroupName: 'HR group',
      ),
    ],
    debug: true,
  );

  final isAllowed = await AwesomeNotifications().isNotificationAllowed();

  if (!isAllowed) {
    debugPrint('Notification permission is not granted');
  }

  // Initialize location background service AFTER notification channel.
  final locationService = LocationBackgroundService();
  await locationService.initialize();

  // Firebase foreground messages
  FirebaseMessaging.onMessage.listen((event) {
    FlutterRingtonePlayer().play(
      fromAsset: 'assets/sound/beep.mp3',
    );

    try {
      InAppNotification.show(
        onTap: () {
          Get.to(
            GeneralScreen(),
            arguments: {
              'title': event.notification!.title!,
              'message': event.notification!.body!,
              'date': '',
            },
          );
        },
        child: Card(
          margin: const EdgeInsets.all(15),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            iconColor: Color(0xff011754),
            textColor: Color(0xff011754),
            minVerticalPadding: 10,
            minLeadingWidth: 0,
            tileColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.notifications),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.notification!.title!,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                event.notification!.body!,
                textAlign: TextAlign.justify,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
        context: NavigationService.navigatorKey.currentState!.context,
      );
    } catch (e) {
      debugPrint('Foreground notification error: $e');
    }
  });

  // Firebase notification opened
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    if (message.data.containsKey('type')) {
      debugPrint(message.data.toString());

      if (message.data['type'] == 'chat') {
        Get.to(
          ChatScreen(),
          arguments: {
            'name': message.data['sender_name'],
            'avatar': message.data['sender_image'],
            'username': message.data['sender_username'],
          },
        );
        return;
      }

      if (message.data['type'] == 'group_chat') {
        Get.to(
          GroupChatScreen(),
          arguments: {
            'projectName': '',
            'projectId': message.data['project_id'],
            'projectSlug': message.data['conversation_id'],
            'leader': [],
            'member': [],
          },
        );
        return;
      }

      Get.to(
        GeneralScreen(),
        arguments: {
          'title': message.data['title'],
          'message': message.data['message'],
          'date': '',
        },
      );
    }
  });

  // SSL certificate
  final data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');

  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  // Run application
  runApp(
    LocalizedApp(delegate, const MyApp()),
  );

  configLoading();
}

@pragma('vm:entry-point')
Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(message.data.toString());
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 50.0
    ..radius = 0.0
    ..progressColor = Colors.blue
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.blue
    ..textColor = Colors.black
    ..maskType = EasyLoadingMaskType.none
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationDelegate = LocalizedApp.of(context).delegate;

    final storage = GetStorage();

    return OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Preferences(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => LeaveProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => PrefProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => ProfileProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => AttendanceReportProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => DashboardProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => MoreScreenProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => PaySlipProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => PaySlipDetailProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => SSFProvider(),
          ),
        ],
        child: Portal(
          child: InAppNotification(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: LocalizationProvider(
                state: LocalizationProvider.of(context).state,
                child: GetMaterialApp(
                  navigatorKey: NavigationService.navigatorKey,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    localizationDelegate,
                  ],
                  supportedLocales: localizationDelegate.supportedLocales,
                  locale: Locale(
                    storage.read('language') ?? 'en',
                  ),
                  theme: ThemeData(
                    canvasColor: const Color.fromRGBO(255, 255, 255, 1),
                    fontFamily: 'GoogleSans',
                    primarySwatch: Colors.blue,
                    brightness: Brightness.dark,
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'GoogleSans',
                        ),
                      ),
                    ),
                    appBarTheme: const AppBarTheme(
                      actionsIconTheme: IconThemeData(color: Colors.white),
                      iconTheme: IconThemeData(color: Colors.white),
                      titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'GoogleSans',
                      ),
                    ),
                  ),
                  initialRoute: '/',
                  routes: {
                    '/': (_) => SplashScreen(),
                    LoginScreen.routeName: (_) => LoginScreen(),
                    DashboardScreen.routeName: (_) => DashboardScreen(),
                    ProfileScreen.routeName: (_) => ProfileScreen(),
                    EditProfileScreen.routeName: (_) => EditProfileScreen(),
                    MeetingDetailScreen.routeName: (_) => MeetingDetailScreen(),
                    PaySlipDetailScreen.routeName: (_) => PaySlipDetailScreen(),
                  },
                  builder: EasyLoading.init(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
