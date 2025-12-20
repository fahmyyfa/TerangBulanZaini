import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../modules/home/controllers/home_controller.dart';

class NotificationService {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotification() async {
    // Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (Get.isRegistered<HomeController>()) {
          final payload = response.payload ?? "Info|Ada notifikasi baru";
          final parts = payload.split('|');
          final title = parts.isNotEmpty ? parts[0] : "Info";
          
          final body = parts.length > 1 ? parts.sublist(1).join('|') : "";
          
          Get.find<HomeController>().handleNotificationTap(title, body);
        }
      },
    );
  }

  Future<void> initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    String? token = await messaging.getToken();
    print("========================================");
    print("FCM TOKEN SAYA: $token");
    print("========================================");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        showNotification(
          message.notification!.title ?? 'Info',
          message.notification!.body ?? 'Ada pesan baru',
        );
      }
    });
  }

  Future<void> showNotification(String title, String body) async {
    const String soundFileName = 'chuaksss'; 
    
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id_terang_bulan_v2',
      'Pesanan & Promo', 
      channelDescription: 'Notifikasi status pesanan suara custom',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      sound: RawResourceAndroidNotificationSound(soundFileName),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, 
      title,
      body,
      platformChannelSpecifics,
      payload: "$title|$body", 
    );
  }
}