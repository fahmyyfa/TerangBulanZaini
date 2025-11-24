import 'package:flutter/material.dart';

class NotificationFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.discount, color: Colors.orange),
            title: Text("Diskon 50% Hari Ini!"),
            subtitle: Text("Khusus pembelian base pandan."),
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text("Selamat Datang"),
            subtitle: Text("Terima kasih sudah mendaftar."),
          ),
        ],
      ),
    );
  }
}
