import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Obx(() => controller.isAdmin.value
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDialog(),
              backgroundColor: Colors.blue.shade800,
              icon: const Icon(Icons.add),
              label: const Text("Admin: Tambah"),
            )
          : const SizedBox()),
      body: Obx(() => IndexedStack(
            index: controller.tabIndex.value,
            children: [
              HomeFragment(), // Beranda
              HistoryFragment(), // Riwayat
              QrisFragment(), // QRIS
              NotificationFragment(), // Notifikasi
              ProfileFragment(), // Profil
            ],
          )),
      bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
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
          )),
    );
  }

  void _showAddDialog() {
    Get.defaultDialog(
      title: "Tambah Menu Baru",
      content: Column(
        children: [
          Obx(() => GestureDetector(
                onTap: () => controller.pickImage(),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: controller.webImage.value != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(controller.webImage.value!,
                              fit: BoxFit.cover))
                      : const Icon(Icons.add_a_photo,
                          size: 40, color: Colors.blue),
                ),
              )),
          const SizedBox(height: 15),
          TextField(
              controller: controller.nameC,
              decoration: const InputDecoration(
                  labelText: "Nama Menu", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(
              controller: controller.priceC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Harga", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(
              controller: controller.descC,
              decoration: const InputDecoration(
                  labelText: "Deskripsi", border: OutlineInputBorder())),
        ],
      ),
      textConfirm: "Simpan",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue.shade800,
      onConfirm: () => controller.addProduct(),
    );
  }
}
