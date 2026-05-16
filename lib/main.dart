import 'package:floodcare_mobile/views/splash/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initNotification();
  await initLocalNotification();
  await getFCMToken();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('NOTIF MASUK FOREGROUND');
    debugPrint('TITLE: ${message.notification?.title}');
    debugPrint('BODY: ${message.notification?.body}');

    showLocalNotification(message);
  });

  runApp(const MyApp());
}

Future<void> initNotification() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint('Permission: ${settings.authorizationStatus}');
}

Future<void> initLocalNotification() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(
    android: androidSettings,
  );

  await localNotifications.initialize(
  settings: initSettings,
);

  const androidChannel = AndroidNotificationChannel(
    'flood_alert_channel',
    'Flood Alert',
    description: 'Notifikasi peringatan banjir',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('flood_alert'),
  );

  await localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
}

Future<void> showLocalNotification(RemoteMessage message) async {
  const androidDetails = AndroidNotificationDetails(
    'flood_alert_channel',
    'Flood Alert',
    channelDescription: 'Notifikasi peringatan banjir',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('flood_alert'),
  );

  const notificationDetails = NotificationDetails(
    android: androidDetails,
  );
  await localNotifications.show(
    id: 0,
    title: message.notification?.title ?? 'Peringatan Banjir',
    body: message.notification?.body ?? 'Ada laporan banjir terbaru',
    notificationDetails: notificationDetails,
  );
}

Future<void> getFCMToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint('FCM TOKEN: $token');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Floodcare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
      ),
      home: const SplashView(),
    );
  }
}