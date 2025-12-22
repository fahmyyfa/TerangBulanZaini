import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'admin_view.dart'; 
import 'fragments/home_fragment.dart';
import 'fragments/history_fragment.dart';
import 'fragments/qris_fragment.dart';
import 'fragments/notification_fragment.dart';
import 'fragments/profile_fragment.dart';

class HomeView extends StatelessWidget {
  final controller = Get.put(HomeController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isAdmin.value) {
        return AdminView(); 
      }

      return Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: controller.tabIndex.value,
          children: [
            HomeFragment(),        // Beranda Pelanggan
            HistoryFragment(),     // Riwayat
            QrisFragment(),        // QRIS
            NotificationFragment(),// Notifikasi
            ProfileFragment(),     // Profil
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
          ),
          child: BottomNavigationBar(
            currentIndex: controller.tabIndex.value,
            onTap: controller.changeTab,
            selectedItemColor: Colors.blue.shade700,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: 'Riwayat'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner), label: 'QRIS'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: 'Notif'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ),
      );
    });
  }
}