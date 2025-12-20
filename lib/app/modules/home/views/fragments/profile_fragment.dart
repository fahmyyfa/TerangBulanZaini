import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/home_controller.dart';

class ProfileFragment extends StatelessWidget {
  final controller = Get.find<HomeController>();

  ProfileFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.blue.shade800,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(30))),
            child: Column(children: [
              const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.blue)),
              const SizedBox(height: 15),
              
              // TAMPILKAN EMAIL & NAMA DARI REGISTER 
              Obx(() {
                 String displayName = "User";
                 if (controller.userEmail.value.contains("@")) {
                   displayName = controller.userEmail.value.split("@")[0];
                   displayName = displayName[0].toUpperCase() + displayName.substring(1);
                 }

                 return Column(
                   children: [
                     Text(displayName, // Nama
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22)),
                     const SizedBox(height: 5),
                     Text(controller.userEmail.value, // Email Asli
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14)),
                   ],
                 );
              }),
              
              const SizedBox(height: 10),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: controller.isAdmin.value ? Colors.red : Colors.amber,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Text(
                  controller.isAdmin.value ? "ADMINISTRATOR" : "MEMBER SETIA",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              )),
            ]),
          ),
          
          const SizedBox(height: 20),
          
          // INFORMASI AKUN 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.calendar_today, "Bergabung Sejak", controller.joinDate),
                    const Divider(),
                    _buildInfoRow(Icons.verified_user, "Status Akun", "Terverifikasi".obs),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Obx(() {
            if (controller.isAdmin.value) {
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(children: [
                    const Text("Analisis Penjualan",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(children: [
                                Text(
                                    NumberFormat.compactCurrency(
                                            locale: 'id', symbol: 'Rp')
                                        .format(controller.totalRevenue.value),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                                const Text("Pendapatan")
                              ])))
                    ]),
                  ]));
            } else {
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(children: [
                        const Text("Level Member: GOLD",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 16)),
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(
                            value: 0.7, color: Colors.blue),
                        const SizedBox(height: 10),
                        const Text("Sedikit lagi jadi Platinum!",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ])));
            }
          }),
          const SizedBox(height: 30),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: () => controller.logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text("Keluar"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15))))),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, RxString value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade300, size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Obx(() => Text(value.value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
        ],
      ),
    );
  }
}