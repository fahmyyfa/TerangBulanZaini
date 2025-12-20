import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationFragment extends StatelessWidget {
  
  final List<Map<String, String>> notifications = [
    {
      "title": "Diskon 50% Hari Ini!",
      "body": "Khusus pembelian base pandan hari ini. Gunakan kode PANDAN50 saat checkout.",
      "date": "Baru Saja",
      "type": "promo"
    },
    {
      "title": "Selamat Datang",
      "body": "Terima kasih sudah mendaftar di aplikasi Terang Bulan Pak Zaini. Nikmati kemudahan pemesanan.",
      "date": "Kemarin",
      "type": "info"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return ListTile(
            onTap: () => _showNotificationDetail(notif), 
            leading: Icon(
                notif['type'] == 'promo' ? Icons.discount : Icons.info, 
                color: notif['type'] == 'promo' ? Colors.orange : Colors.blue
            ),
            title: Text(notif['title']!),
            subtitle: Text(notif['body']!, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(notif['date']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          );
        },
      ),
    );
  }

  void _showNotificationDetail(Map<String, String> notif) {
    Get.defaultDialog(
      title: notif['title']!,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
             Icon(
                notif['type'] == 'promo' ? Icons.discount : Icons.info, 
                color: notif['type'] == 'promo' ? Colors.orange : Colors.blue,
                size: 50,
            ),
            const SizedBox(height: 15),
            Text(notif['body']!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(notif['date']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      textConfirm: "Oke",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue.shade800,
      onConfirm: () => Get.back(),
    );
  }
}