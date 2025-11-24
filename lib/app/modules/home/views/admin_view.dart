import 'dart:io'; // Tetap butuh ini untuk kIsWeb check
import 'package:flutter/foundation.dart'; // PENTING: Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class AdminView extends StatelessWidget {
  final controller = Get.put(HomeController());

  AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Admin Dashboard"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => controller.logout())
          ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text("Tambah Menu"),
      ),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final p = controller.products[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      p.imageUrl ?? 'https://placehold.co/100',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) =>
                          Container(width: 50, color: Colors.grey),
                    ),
                  ),
                  title: Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Rp ${p.price}"),
                  trailing:
                      const Icon(Icons.edit, size: 18, color: Colors.grey),
                ),
              );
            },
          )),
    );
  }

  void _showAddDialog() {
    Get.defaultDialog(
      title: "Tambah Menu Baru",
      content: Column(
        children: [
          // --- LOGIKA CERDAS PREVIEW GAMBAR ---
          Obx(() {
            return GestureDetector(
              onTap: () => controller.pickImage(),
              child: Container(
                height: 150, width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300)),
                child: _buildImagePreview(), // Panggil fungsi helper di bawah
              ),
            );
          }),
          // ------------------------------------

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
      textConfirm: "Upload & Simpan",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () => controller.addProduct(),
    );
  }

  // Helper untuk menampilkan gambar sesuai Platform (Web/HP)
  Widget _buildImagePreview() {
    // 1. Jika ada gambar Web (Bytes) -> Tampilkan Memory
    if (kIsWeb && controller.webImage.value != null) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(controller.webImage.value!, fit: BoxFit.cover));
    }
    // 2. Jika ada gambar HP (File) & BUKAN Web -> Tampilkan File
    else if (!kIsWeb && controller.mobileImage.value != null) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(controller.mobileImage.value!, fit: BoxFit.cover));
    }
    // 3. Jika belum ada gambar -> Tampilkan Icon
    else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_a_photo, color: Colors.blue, size: 40),
          Text("Pilih Gambar", style: TextStyle(color: Colors.blue))
        ],
      );
    }
  }
}
