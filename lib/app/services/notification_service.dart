import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // --- 1. Inisialisasi Local Notification ---
  Future<void> initLocalNotification() async {
    // Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Settings (Opsional)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Logika jika notifikasi diklik (misal: buka tab Riwayat)
        print("Notifikasi diklik: ${response.payload}");
      },
    );
  }

  // --- 2. Inisialisasi FCM (Firebase Cloud Messaging) ---
  Future<void> initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request Permission (Penting untuk Android 13+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Handler saat aplikasi dibuka (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        // Tampilkan sebagai Local Notification saat aplikasi dibuka
        showNotification(
          message.notification!.title ?? 'Info',
          message.notification!.body ?? 'Ada pesan baru',
        );
      }
    });
  }

  // --- 3. Fungsi Menampilkan Notifikasi (Local) ---
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id_terang_bulan', // ID Channel unik
      'Order Notifications', // Nama Channel
      channelDescription: 'Notifikasi status pesanan',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // ID unik berdasarkan waktu
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}