import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;
import '../../controllers/home_controller.dart';
import '../map_view.dart';
import '../../../../data/models/product_model.dart'; 

class HomeFragment extends StatefulWidget {
  HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> with SingleTickerProviderStateMixin {
  final controller = Get.find<HomeController>();
  
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() {
          // Jika Mode Admin
          if (controller.isAdmin.value) {
            return Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  "Mode Admin",
                  style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            );
          }

          // Jika User Biasa 
          return GestureDetector(
            onTap: () => Get.to(() => MapView()),
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50), 
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Lokasi Merah
                  Icon(Icons.location_on_rounded, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  
                  // Kolom Teks Alamat
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lokasi Pengiriman",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          controller.address.value, 
                          style: const TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.black87
                          ),
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis, 
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 18),
                ],
              ),
            ),
          );
        }),

        actions: [
          Obx(() => !controller.isAdmin.value
              ? Padding(
                  padding: const EdgeInsets.only(right: 20, top: 10),
                  child: badges.Badge(
                    badgeContent: Text('${controller.cart.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                    child: IconButton(
                        icon: Icon(Icons.shopping_cart, color: Colors.blue.shade800),
                        onPressed: () => controller.showCartDetails()),
                  ),
                )
              : const SizedBox()),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.fetchProducts(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => !controller.isAdmin.value
                  ? _buildPromoBanner()
                  : const SizedBox()),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Daftar Menu",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return _buildProductCard(product);
                  },
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade100, blurRadius: 5)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showDetailDialog(product),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Hero(
                  tag: 'product_image_${product.id}',
                  child: Image.network(
                    product.imageUrl ?? "https://placehold.co/400x300/png?text=Menu",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (c, o, s) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                            .format(product.price),
                        style: TextStyle(
                            color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                    
                    // Logika Tombol Admin vs User
                    controller.isAdmin.value
                        ? InkWell(
                            onTap: () => Get.defaultDialog(
                                title: "Hapus?",
                                textConfirm: "Ya",
                                onConfirm: () {
                                  Get.back();
                                  controller.deleteProduct(product.id);
                                }),
                            child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.delete, size: 16, color: Colors.red)),
                          )
                        : Obx(() {
                            int qty = controller.getQuantity(product.id);
                            
                            if (qty == 0) {
                                return InkWell(
                                  onTap: () => controller.addToCart(product),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.add, size: 16, color: Colors.white),
                                  ),
                                );
                            } else {
                                return Row(
                                    children: [
                                        InkWell(
                                            onTap: () => controller.decreaseItem(product),
                                            child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                                                child: const Icon(Icons.remove, size: 14, color: Colors.red),
                                            ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        InkWell(
                                            onTap: () => controller.addToCart(product),
                                            child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                                                child: const Icon(Icons.add, size: 14, color: Colors.green),
                                            ),
                                        ),
                                    ],
                                );
                            }
                          }),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 160,
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade800]),
          borderRadius: BorderRadius.circular(20)),
      child: Stack(children: [
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(5)),
                      child: const Text("PROMO SPESIAL",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),
                  
                  // ANIMASI EXPLICIT
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text("DISKON 50%",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28)),
                  ),
                ])),
        Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.fastfood,
                size: 150, color: Colors.white.withOpacity(0.15)))
      ]),
    );
  }

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
                tag: 'product_image_${product.id}', 
                child: Image.network(
                  product.imageUrl ?? "https://placehold.co/400x300",
                  height: 250,
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
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                   Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                            .format(product.price),
                        style: TextStyle(
                            color: Colors.blue.shade700, 
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(product.description, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Get.back(); 
                      controller.addToCart(product); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: const Text("Tambah ke Keranjang"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}