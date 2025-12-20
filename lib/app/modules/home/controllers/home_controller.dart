import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:http/http.dart' as http;
import '../../../data/models/product_model.dart';
import '../../auth/views/login_view.dart';
import '../../../services/notification_service.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;

  // DATA
  var products = <Product>[].obs;
  var cart = <Product>[].obs;
  var myOrders = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isAdmin = false.obs;

  // DATA USER (BARU)
  var userEmail = "Loading...".obs;
  var joinDate = "-".obs;

  // ANALISIS ADMIN
  var totalRevenue = 0.0.obs;
  var totalOrdersCount = 0.obs;

  // NAVIGASI
  var tabIndex = 0.obs;

  // LOKASI & MAP
  var address = "Mencari lokasi...".obs;
  var locationSource = "Mencari...".obs;
  var distanceKm = 0.0.obs;

  final double shopLat = -7.9826;
  final double shopLng = 112.6308;

  var currentLat = 0.0.obs;
  var currentLng = 0.0.obs;
  var selectedLat = 0.0.obs;
  var selectedLng = 0.0.obs;
  var isDelivery = true.obs;

  StreamSubscription<Position>? _positionStream;

  // ADMIN FORM
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final descC = TextEditingController();
  var webImage = Rx<Uint8List?>(null);
  var mobileImage = Rx<File?>(null);
  String? _imageExtension;

  var currentAccuracy = 0.0.obs;
  var currentSpeed = 0.0.obs;
  var lastUpdated = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    checkRole();
    loadUserProfile(); 
    fetchProducts();
    fetchOrders();
    _startLiveLocation();
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    super.onClose();
  }

  void changeTab(int index) {
    tabIndex.value = index;
    if (index == 1 || index == 4) fetchOrders();
  }

  // FUNGSI USER PROFILE
  void loadUserProfile() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? "Tanpa Email";
      
      if (user.createdAt.isNotEmpty) {
         try {
           final dt = DateTime.parse(user.createdAt).toLocal();
           joinDate.value = "${dt.day}/${dt.month}/${dt.year}";
         } catch (e) {
           joinDate.value = "-";
         }
      }
    }
  }

  // FUNGSI AUTH
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

  void logout() async {
    await supabase.auth.signOut();
    Get.offAll(() => LoginView());
  }

  // API PUBLIK
  Future<List<String>> fetchExternalDessertImages() async {
    try {
      final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List;
        return meals.map<String>((m) => m['strMealThumb'] as String).toList();
      }
    } catch (e) {
      print("Gagal ambil API Public: $e");
    }
    return [];
  }

  // CRUD PRODUK
  void fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await supabase.from('products').select().order('id');
      final apiImages = await fetchExternalDessertImages();
      final data = response as List<dynamic>;

      products.value = data.asMap().entries.map((entry) {
        int index = entry.key;
        var productJson = entry.value;
        if (apiImages.isNotEmpty) {
          productJson['image_url'] = apiImages[index % apiImages.length];
        }
        return Product.fromJson(productJson);
      }).toList();
    } catch (e) {
      print("Error product: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct() async {
    if (nameC.text.isEmpty || priceC.text.isEmpty) return;
    try {
      isLoading.value = true;
      String? imageUrl;
      if (webImage.value != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$_imageExtension';
        final path = 'uploads/$fileName';
        await supabase.storage.from('menu_images').uploadBinary(path, webImage.value!, fileOptions: FileOptions(contentType: 'image/$_imageExtension'));
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
    } catch (e) {}
  }

  void _resetForm() {
    nameC.clear(); priceC.clear(); descC.clear();
    webImage.value = null; mobileImage.value = null;
  }

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

  // LOGIKA KERANJANG & ORDER
  void addToCart(Product product) => cart.add(product);

  void decreaseItem(Product product) {
    final index = cart.indexWhere((item) => item.id == product.id);
    if (index != -1) cart.removeAt(index);
  }

  int getQuantity(int productId) {
    return cart.where((p) => p.id == productId).length;
  }

  void showCartDetails() {
    if (cart.isEmpty) {
      Get.snackbar("Keranjang Kosong", "Yuk pesan sesuatu dulu!");
      return;
    }
    final uniqueItems = cart.toSet().toList();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Rincian Keranjang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back())
              ],
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: uniqueItems.length,
                itemBuilder: (ctx, index) {
                  final item = uniqueItems[index];
                  return Obx(() {
                    int qty = getQuantity(item.id);
                    if (qty == 0) return const SizedBox();
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Rp ${item.price} x $qty = Rp ${item.price * qty}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => decreaseItem(item),
                          ),
                          Text("$qty", style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: () => addToCart(item),
                          ),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
                onPressed: () {
                  Get.back();
                  showPaymentDialog();
                },
                child: const Text("Lanjut Pembayaran"),
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showPaymentDialog() {
    if (cart.isEmpty) return;
    isDelivery.value = true;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Obx(() {
          int totalMenu = cart.fold(0, (sum, item) => sum + item.price);
          int ongkir = isDelivery.value ? (distanceKm.value * 2000).ceil() : 0;
          int grandTotal = totalMenu + ongkir;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Konfirmasi Pembayaran",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(child: _buildOptionBtn("Diantar", true)),
                    Expanded(child: _buildOptionBtn("Ambil Sendiri", false)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                 Text("Total Menu (${cart.length} item)"),
                 Text("Rp $totalMenu"),
              ]),
               const SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Ongkir"),
                Text(isDelivery.value ? "Rp $ongkir (${distanceKm.value.toStringAsFixed(1)} km)" : "Rp 0 (Ambil di Toko)",
                    style: TextStyle(color: isDelivery.value ? Colors.black : Colors.green)),
              ]),
              const Divider(thickness: 1, height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Total Bayar", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Rp $grandTotal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade800)),
              ]),
              const SizedBox(height: 20),
              const Text("Metode Pembayaran:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => _processOrder('transfer', grandTotal, ongkir), child: const Text("QRIS"))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white), onPressed: () => _processOrder('cash', grandTotal, ongkir), child: const Text("Tunai"))),
                ],
              )
            ],
          );
        }),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildOptionBtn(String title, bool isDeliveryType) {
    return GestureDetector(
      onTap: () => isDelivery.value = isDeliveryType,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDelivery.value == isDeliveryType ? Colors.blue.shade800 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(title, textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: isDelivery.value == isDeliveryType ? Colors.white : Colors.grey.shade600),
        ),
      ),
    );
  }

  void _processOrder(String method, int total, int ongkir) async {
    Get.back();
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    await Future.delayed(const Duration(seconds: 2));
    Get.back();

    try {
      final uniqueItems = cart.toSet().toList();
      List<Map<String, dynamic>> itemsSummary = [];
      for (var item in uniqueItems) {
        itemsSummary.add({
          'name': item.name,
          'qty': getQuantity(item.id),
          'price': item.price,
        });
      }
      
      await supabase.from('orders').insert({
        'user_id': supabase.auth.currentUser!.id,
        'total_price': total,
        'status': isDelivery.value ? 'Delivery Order' : 'Pickup Order',
        'payment_method': method,
        'payment_status': method == 'transfer' ? 'paid' : 'pending',
        'user_latitude': selectedLat.value,
        'user_longitude': selectedLng.value,
        'items': itemsSummary, 
        'shipping_cost': ongkir, 
      });

      cart.clear();
      fetchOrders();
      NotificationService().showNotification("Pesanan Diproses", "Terima kasih! Pesanan martabakmu sedang disiapkan.");
      if (isDelivery.value) {
        Future.delayed(const Duration(seconds: 10), () {
          NotificationService().showNotification("Pesanan Sedang Diantar", "Kurir sedang menuju ke lokasimu.");
        });
      }
      Get.snackbar("Sukses", "Pesanan Diterima");
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  void fetchOrders() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      if (isAdmin.value) {
        final response = await supabase.from('orders').select().order('created_at', ascending: false);
        List<dynamic> data = response as List<dynamic>;
        double revenue = 0;
        for (var item in data) revenue += (item['total_price'] as num).toDouble();
        totalRevenue.value = revenue;
        totalOrdersCount.value = data.length;
        myOrders.value = List<Map<String, dynamic>>.from(data);
      } else {
        final response = await supabase.from('orders').select().eq('user_id', user.id).order('created_at', ascending: false);
        myOrders.value = List<Map<String, dynamic>>.from(response as List<dynamic>);
      }
    } catch (e) {
      print("Error orders: $e");
    }
  }

  // --- LOKASI ---
  void _startLiveLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      address.value = "GPS Mati";
      locationSource.value = "Tidak diketahui";
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        address.value = "Izin Ditolak";
        return;
      }
    }
    const LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 0);
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      currentLat.value = position.latitude;
      currentLng.value = position.longitude;
      currentAccuracy.value = position.accuracy;
      currentSpeed.value = position.speed;
      lastUpdated.value = position.timestamp ?? DateTime.now();

      if (selectedLat.value == 0.0) {
        selectedLat.value = position.latitude;
        selectedLng.value = position.longitude;
        _calculateDistance();
      }
      locationSource.value = position.accuracy < 20 ? "GPS (Akurasi Tinggi)" : "Network/WiFi (Estimasi)";
      address.value = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
    });
  }

  void updateSelectedLocation(latLng.LatLng point) {
    selectedLat.value = point.latitude;
    selectedLng.value = point.longitude;
    _calculateDistance();
    address.value = "Pin: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
    Get.back();
    Get.snackbar("Lokasi Diupdate", "Jarak pengiriman diperbarui", backgroundColor: Colors.green.shade100, duration: const Duration(seconds: 1));
  }

  void _calculateDistance() {
    double dist = Geolocator.distanceBetween(selectedLat.value, selectedLng.value, shopLat, shopLng);
    distanceKm.value = dist / 1000;
  }
}