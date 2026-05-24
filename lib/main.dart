import 'package:floodcare_mobile/views/splash/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

int notificationId = 0;

const String floodAlertChannelId = 'flood_alert_channel';
const String floodHighChannelId = 'flood_high_channel';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== FLOODCARE MAIN JALAN ===');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('=== FIREBASE BERHASIL INIT ===');

  await initNotification();
  await initLocalNotification();
  await getFCMToken();

  print('=== SEMUA INIT SELESAI ===');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('=== NOTIF MASUK FOREGROUND ===');
    debugPrint('TITLE: ${message.notification?.title}');
    debugPrint('BODY: ${message.notification?.body}');
    debugPrint('DATA: ${message.data}');

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

  const floodAlertChannel = AndroidNotificationChannel(
    floodAlertChannelId,
    'Flood Alert',
    description: 'Notifikasi peringatan banjir',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('flood_alert'),
  );

  const floodHighChannel = AndroidNotificationChannel(
    floodHighChannelId,
    'Flood High Alert',
    description: 'Notifikasi peringatan banjir tinggi dan sangat tinggi',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('flood_high'),
  );

  final androidPlugin =
      localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(floodAlertChannel);
  await androidPlugin?.createNotificationChannel(floodHighChannel);
}

bool isHighFlood(RemoteMessage message) {
  final String title = message.notification?.title ?? '';
  final String body = message.notification?.body ?? '';
  final String dataText = message.data.values.join(' ');

  final String fullText = '$title $body $dataText'
      .toLowerCase()
      .trim()
      .replaceAll('_', ' ')
      .replaceAll('-', ' ');

  debugPrint('CEK LEVEL BANJIR: $fullText');

  return fullText.contains('sangat tinggi') || fullText.contains('tinggi');
}

Future<void> showLocalNotification(RemoteMessage message) async {
  final bool highFlood = isHighFlood(message);

  final String channelId =
      highFlood ? floodHighChannelId : floodAlertChannelId;

  final String channelName =
      highFlood ? 'Flood High Alert' : 'Flood Alert';

  final String channelDescription = highFlood
      ? 'Notifikasi peringatan banjir tinggi dan sangat tinggi'
      : 'Notifikasi peringatan banjir';

  final String soundName = highFlood ? 'flood_high' : 'flood_alert';

  final androidDetails = AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound(soundName),
  );

  final notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  notificationId++;

  await localNotifications.show(
    id: notificationId,
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