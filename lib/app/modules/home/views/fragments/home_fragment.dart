import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;
import '../../controllers/home_controller.dart';

class HomeFragment extends StatelessWidget {
  final controller = Get.find<HomeController>();

  HomeFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Obx(() => Text(
              controller.isAdmin.value ? "Mode Admin" : "Lokasi Pengiriman:",
              style: TextStyle(
                  fontSize: 10,
                  color: controller.isAdmin.value ? Colors.red : Colors.grey))),
          Row(children: [
            const Icon(Icons.location_on, size: 14, color: Colors.blue),
            const SizedBox(width: 4),
            Obx(() => Text(controller.address.value,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold))),
          ]),
        ]),
        actions: [
          Obx(() => !controller.isAdmin.value
              ? Padding(
                  padding: const EdgeInsets.only(right: 20, top: 10),
                  child: badges.Badge(
                    badgeContent: Text('${controller.cart.length}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10)),
                    child: IconButton(
                        icon: Icon(Icons.shopping_cart,
                            color: Colors.blue.shade800),
                        onPressed: () => controller.showPaymentDialog()),
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
                if (controller.isLoading.value)
                  return const Center(child: CircularProgressIndicator());
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
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade100, blurRadius: 5)
                          ]),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15)),
                                    child: Image.network(
                                        product.imageUrl ??
                                            "https://placehold.co/400x300/png?text=Menu",
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (c, o, s) => Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                                Icons.broken_image))))),
                            Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                NumberFormat.currency(
                                                        locale: 'id',
                                                        symbol: 'Rp ',
                                                        decimalDigits: 0)
                                                    .format(product.price),
                                                style: TextStyle(
                                                    color: Colors.blue.shade700,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            InkWell(
                                              onTap: () =>
                                                  controller.isAdmin.value
                                                      ? Get.defaultDialog(
                                                          title: "Hapus?",
                                                          textConfirm: "Ya",
                                                          onConfirm: () {
                                                            Get.back();
                                                            controller
                                                                .deleteProduct(
                                                                    product.id);
                                                          })
                                                      : controller
                                                          .addToCart(product),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                      color: controller
                                                              .isAdmin.value
                                                          ? Colors.red.shade100
                                                          : Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child: Icon(
                                                      controller.isAdmin.value
                                                          ? Icons.delete
                                                          : Icons.add,
                                                      size: 16,
                                                      color: controller
                                                              .isAdmin.value
                                                          ? Colors.red
                                                          : Colors.white)),
                                            )
                                          ])
                                    ])),
                          ]),
                    );
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
                  Text("DISKON 50%",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28)),
                ])),
        Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.fastfood,
                size: 150, color: Colors.white.withOpacity(0.15)))
      ]),
    );
  }
}
