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

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await messaging.getToken();
    print("========================================");
    print("FCM TOKEN SAYA: $token");
    print("========================================");


    await messaging.subscribeToTopic('promo');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(
          message.notification!.title ?? 'Info',
          message.notification!.body ?? 'Pesan baru',
        );
      }
    });
  }

  Future<void> showNotification(String title, String body) async {
    const String soundFileName = 'pesanan'; 
    
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_teranis_Baru', 
      'Notifications Pemesanan ', 
      channelDescription: 'Notifikasi status pesanan',
      importance: Importance.max,
      priority: Priority.high,
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