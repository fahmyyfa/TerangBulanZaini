import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/product_model.dart';
import 'fragments/profile_fragment.dart'; 

class AdminView extends StatelessWidget {
  final controller = Get.put(HomeController());

  AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        // Header menjadi Biru
        backgroundColor: Colors.blue.shade700, 
        elevation: 0,
        title: Text("Admin Dashboard", 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white), 
        actions: [
          // Tombol Profile 
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Lihat Profil & Pendapatan',
            onPressed: () => Get.to(() => ProfileFragment()),
          ),
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Keluar',
            onPressed: () => controller.logout(),
          ),
          const SizedBox(width: 10), 
        ],
      ),
      
      // Floating Action Button (Tambah Menu)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Menu", style: TextStyle(color: Colors.white)),
      ),
      
      body: Obx(() {
        if (controller.products.isEmpty) {
          return const Center(child: Text("Belum ada menu tersedia"));
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return _buildAdminProductCard(product);
          },
        );
      }),
    );
  }

  // WIDGET ITEM PRODUK 
  Widget _buildAdminProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade200, blurRadius: 5, spreadRadius: 1)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          Expanded(
            child: GestureDetector(
              onTap: () => _showDetailDialog(product),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Hero(
                  tag: 'admin_product_${product.id}',
                  child: Image.network(
                    product.imageUrl ?? "https://placehold.co/400x300",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (c, o, s) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
            ),
          ),
          
          // Info Produk & Tombol Hapus
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                            .format(product.price),
                        style: TextStyle(
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    
                    // Tombol Hapus
                    InkWell(
                      onTap: () => _confirmDelete(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.red.shade50, 
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // DIALOG HAPUS 
  void _confirmDelete(Product product) {
    Get.defaultDialog(
      title: "Hapus Menu?",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      middleText: "Apakah Anda yakin ingin menghapus '${product.name}' dari daftar menu? Tindakan ini tidak dapat dibatalkan.",
      middleTextStyle: const TextStyle(color: Colors.grey),
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.black,
      onConfirm: () {
        Get.back();
        controller.deleteProduct(product.id);
        Get.snackbar("Terhapus", "${product.name} telah dihapus", 
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
      },
    );
  }

  // POPUP DETAIL 
  void _showDetailDialog(Product product) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Hero(
                tag: 'admin_product_${product.id}',
                child: Image.network(
                  product.imageUrl ?? "https://placehold.co/400x300",
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                          .format(product.price),
                      style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(product.description, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  
                  // Tombol Tutup 
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue.shade700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      child: Text("Tutup", style: TextStyle(color: Colors.blue.shade700)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // POPUP TAMBAH MENU 
  void _showAddDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Text("Tambah Menu Baru", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Input Gambar
              Obx(() => GestureDetector(
                onTap: () => controller.pickImage(),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.shade100, width: 2, style: BorderStyle.solid),
                    image: controller.webImage.value != null 
                      ? DecorationImage(image: MemoryImage(controller.webImage.value!), fit: BoxFit.cover)
                      : (!kIsWeb && controller.mobileImage.value != null)
                        ? DecorationImage(image: FileImage(controller.mobileImage.value!), fit: BoxFit.cover)
                        : null
                  ),
                  child: (controller.webImage.value == null && controller.mobileImage.value == null)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, size: 50, color: Colors.blue.shade300),
                          const SizedBox(height: 10),
                          Text("Tap untuk upload gambar", style: TextStyle(color: Colors.blue.shade300))
                        ],
                      )
                    : null,
                ),
              )),
              
              const SizedBox(height: 20),
              
              // Input Fields
              _buildCustomTextField(controller.nameC, "Nama Menu", Icons.fastfood_outlined),
              const SizedBox(height: 15),
              _buildCustomTextField(controller.priceC, "Harga (Rp)", Icons.attach_money, isNumber: true),
              const SizedBox(height: 15),
              _buildCustomTextField(controller.descC, "Deskripsi Menu", Icons.description_outlined, maxLines: 3),
              
              const SizedBox(height: 25),
              
              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.addProduct(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2
                  ),
                  child: const Text("SIMPAN MENU", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
               // Spasi extra untuk keyboard
               Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom))
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildCustomTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400)
        ),
      ),
    );
  }
}