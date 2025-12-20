import 'dart:convert'; 
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
                onTap: () => _showOrderDetail(order), 
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

  void _showOrderDetail(Map<String, dynamic> order) {
    List<dynamic> items = [];
    int shippingCost = order['shipping_cost'] ?? 0;
    
    if (order['items'] != null) {
      try {
        if (order['items'] is String) {
           items = jsonDecode(order['items']);
        } else {
           items = order['items'];
        }
      } catch (e) {
        items = [];
      }
    }

    Get.defaultDialog(
      title: "Detail Pesanan #${order['id']}",
      content: Column(
        children: [
          // List Item
          if (items.isNotEmpty)
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${item['name']} (${item['qty']}x)"),
                  Text("Rp ${item['price'] * item['qty']}"),
                ],
              ),
            )).toList()
          else
            const Text("Detail item tidak tersedia (Data Lama)", style: TextStyle(fontStyle: FontStyle.italic)),
          
          const Divider(),
          
          // Rincian Ongkir
          if (shippingCost > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Ongkos Kirim", style: TextStyle(color: Colors.grey)),
                Text("Rp $shippingCost", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Bayar", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(order['total_price']),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
           const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)),
            child: Text("Status Pembayaran: ${order['payment_status'].toString().toUpperCase()}"),
          )
        ],
      ),
      textConfirm: "Tutup",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue.shade800,
      onConfirm: () => Get.back(),
    );
  }
}