import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // PENTING: Untuk kIsWeb
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/product_model.dart';
import '../../auth/views/login_view.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;

  // Data
  var products = <Product>[].obs;
  var cart = <Product>[].obs;
  var myOrders = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isAdmin = false.obs;

  // Analisis Admin
  var totalRevenue = 0.0.obs;
  var totalOrdersCount = 0.obs;

  // Navigasi & Lokasi
  var tabIndex = 0.obs;
  var distanceKm = 0.0.obs;
  var address = "Mencari lokasi...".obs;
  Position? _currentPosition;
  final double shopLat = -7.9826;
  final double shopLng = 112.6308;

  // Admin Upload Form
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final descC = TextEditingController();

  // Image Variables (Support Web & Mobile)
  var webImage = Rx<Uint8List?>(null);
  var mobileImage = Rx<File?>(null);
  String? _imageExtension;

  @override
  void onInit() {
    super.onInit();
    checkRole();
    fetchProducts();
    _determinePosition();
    fetchOrders();
  }

  void changeTab(int index) {
    tabIndex.value = index;
    if (index == 1 || index == 4) fetchOrders();
  }

  void checkRole() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final data = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      if (data != null && data['role'] == 'admin') isAdmin.value = true;
    }
  }

  void fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await supabase.from('products').select().order('id');
      final data = response as List<dynamic>;
      products.value = data.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      print("Error product: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchOrders() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      if (isAdmin.value) {
        final response = await supabase
            .from('orders')
            .select()
            .order('created_at', ascending: false);
        List<dynamic> data = response as List<dynamic>;
        double revenue = 0;
        for (var item in data)
          revenue += (item['total_price'] as num).toDouble();
        totalRevenue.value = revenue;
        totalOrdersCount.value = data.length;
        myOrders.value = List<Map<String, dynamic>>.from(data);
      } else {
        final response = await supabase
            .from('orders')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        myOrders.value =
            List<Map<String, dynamic>>.from(response as List<dynamic>);
      }
    } catch (e) {
      print("Error orders: $e");
    }
  }

  // --- UPLOAD IMAGE ---
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _imageExtension = image.name.split('.').last;
      final bytes = await image.readAsBytes();
      webImage.value = bytes;
      if (!kIsWeb) mobileImage.value = File(image.path);
    }
  }

  Future<void> addProduct() async {
    if (nameC.text.isEmpty || priceC.text.isEmpty) return;
    try {
      isLoading.value = true;
      String? imageUrl;
      if (webImage.value != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.$_imageExtension';
        final path = 'uploads/$fileName';
        await supabase.storage.from('menu_images').uploadBinary(
            path, webImage.value!,
            fileOptions: FileOptions(contentType: 'image/$_imageExtension'));
        imageUrl = supabase.storage.from('menu_images').getPublicUrl(path);
      }
      await supabase.from('products').insert({
        'name': nameC.text,
        'price': int.parse(priceC.text),
        'description': descC.text,
        'image_url': imageUrl,
        'category': 'base',
      });
      fetchProducts();
      Get.back();
      _resetForm();
      Get.snackbar("Sukses", "Menu berhasil ditambah!");
    } catch (e) {
      Get.snackbar("Error", "Gagal: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await supabase.from('products').delete().eq('id', id);
      fetchProducts();
      Get.snackbar("Dihapus", "Menu dihapus",
          backgroundColor: Colors.red.shade100);
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  void _resetForm() {
    nameC.clear();
    priceC.clear();
    descC.clear();
    webImage.value = null;
    mobileImage.value = null;
  }

  // --- LOKASI & CART ---
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      address.value = "GPS Mati";
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = position;
    double dist = Geolocator.distanceBetween(
        position.latitude, position.longitude, shopLat, shopLng);
    distanceKm.value = dist / 1000;
    address.value = "${distanceKm.value.toStringAsFixed(1)} km dari toko";
  }

  void addToCart(Product product) => cart.add(product);

  void showPaymentDialog() {
    if (cart.isEmpty) return;
    int total = cart.fold(0, (sum, item) => sum + item.price);
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("Metode Pembayaran",
            style: TextStyle(fontWeight: FontWeight.bold)),
        ListTile(
            title: const Text("QRIS"),
            onTap: () => _processOrder('transfer', total)),
        ListTile(
            title: const Text("Tunai"),
            onTap: () => _processOrder('cash', total)),
      ]),
    ));
  }

  void _processOrder(String method, int total) async {
    Get.back();
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    await Future.delayed(const Duration(seconds: 2));
    Get.back();
    try {
      await supabase.from('orders').insert({
        'user_id': supabase.auth.currentUser!.id,
        'total_price': total,
        'status': 'Order Placed',
        'payment_method': method,
        'payment_status': method == 'transfer' ? 'paid' : 'pending',
        'user_latitude': _currentPosition?.latitude,
        'user_longitude': _currentPosition?.longitude,
      });
      cart.clear();
      fetchOrders();
      Get.snackbar("Sukses", "Pesanan Diterima");
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  void logout() async {
    await supabase.auth.signOut();
    Get.offAll(() => LoginView());
  }
}
