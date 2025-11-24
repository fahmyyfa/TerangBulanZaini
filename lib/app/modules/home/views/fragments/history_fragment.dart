import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/home_controller.dart';

class HistoryFragment extends StatelessWidget {
  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Riwayat Pesanan"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: Obx(() {
        if (controller.myOrders.isEmpty) {
          return const Center(child: Text("Belum ada pesanan"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myOrders.length,
          itemBuilder: (context, index) {
            final order = controller.myOrders[index];
            final date = DateTime.parse(order['created_at']).toLocal();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.receipt_long, color: Colors.blue),
                ),
                title: Text("Order #${order['id']} - ${order['status']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(date)),
                trailing: Text(
                  NumberFormat.currency(
                          locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                      .format(order['total_price']),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
