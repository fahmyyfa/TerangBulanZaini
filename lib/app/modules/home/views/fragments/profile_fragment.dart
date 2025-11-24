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
              const SizedBox(height: 10),
              Obx(() => Text(
                  controller.isAdmin.value ? "ADMINISTRATOR" : "MEMBER SETIA",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18))),
            ]),
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
        ]),
      ),
    );
  }
}
