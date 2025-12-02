import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // PENTING: Untuk format jam (Timestamp)
import '../controllers/home_controller.dart';

class MapView extends StatelessWidget {
  final controller = Get.find<HomeController>();
  
  // Controller untuk mengontrol Zoom secara manual
  final MapController mapController = MapController();

  MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi Pengiriman"),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. PETA (FLUTTER MAP)
          Obx(() {
            final userPos = LatLng(controller.currentLat.value, controller.currentLng.value);
            final shopPos = LatLng(controller.shopLat, controller.shopLng);
            
            // Logika Marker Pin
            final pinPos = controller.selectedLat.value == 0
                ? userPos
                : LatLng(controller.selectedLat.value, controller.selectedLng.value);

            return FlutterMap(
              // Sambungkan mapController disini
              mapController: mapController,
              options: MapOptions(
                initialCenter: userPos.latitude == 0 ? shopPos : userPos,
                initialZoom: 15.0,
                onTap: (tapPosition, point) {
                  controller.updateSelectedLocation(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.terangbulan.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: shopPos,
                      width: 50, height: 50,
                      child: const Icon(Icons.store, color: Colors.orange, size: 40),
                    ),
                    Marker(
                      point: userPos,
                      width: 50, height: 50,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 30), // Ikon user
                    ),
                    Marker(
                      point: pinPos,
                      width: 50, height: 50,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                    ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [shopPos, pinPos],
                      strokeWidth: 4.0,
                      color: Colors.blue.withOpacity(0.5),
                    ),
                  ],
                ),
              ],
            );
          }),
          
          // 2. KONTROL TOMBOL (ZOOM & INFO LAPORAN)
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                // Tombol Zoom In (+)
                FloatingActionButton.small(
                  heroTag: "zoom_in", // Wajib beda tag
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.black87),
                  onPressed: () {
                    final currentZoom = mapController.camera.zoom;
                    mapController.move(mapController.camera.center, currentZoom + 1);
                  },
                ),
                const SizedBox(height: 10),
                
                // Tombol Zoom Out (-)
                FloatingActionButton.small(
                  heroTag: "zoom_out", // Wajib beda tag
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.black87),
                  onPressed: () {
                    final currentZoom = mapController.camera.zoom;
                    mapController.move(mapController.camera.center, currentZoom - 1);
                  },
                ),
                const SizedBox(height: 10),

                // --- TOMBOL INFO DATA LAPORAN (?) ---
                FloatingActionButton.small(
                  heroTag: "info_debug", // Wajib beda tag
                  backgroundColor: Colors.blue.shade800, 
                  child: const Icon(Icons.question_mark, color: Colors.white),
                  onPressed: () => _showDebugInfo(),
                ),
              ],
            ),
          ),
          
          // 3. INFO CARD JARAK (DI BAWAH)
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
              ),
              child: Column(
                children: [
                  Obx(() => Text("Sumber: ${controller.locationSource.value}", 
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
                  const SizedBox(height: 5),
                  Obx(() => Text("Jarak: ${controller.distanceKm.value.toStringAsFixed(2)} KM",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),
                  const Text("Tap peta untuk ubah titik antar", style: TextStyle(fontSize: 12, color: Colors.blue)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- FUNGSI POPUP INFO LAPORAN ---
  void _showDebugInfo() {
    Get.defaultDialog(
      title: "Data Laporan (Modul 5)",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      radius: 10,
      content: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("Provider", controller.locationSource.value.contains("GPS") ? "GPS" : "Network"),
          const Divider(),
          _buildInfoRow("Latitude", controller.currentLat.value.toStringAsFixed(6)),
          _buildInfoRow("Longitude", controller.currentLng.value.toStringAsFixed(6)),
          const Divider(),
          // Data Penting untuk Tabel Laporan:
          _buildInfoRow("Accuracy", "${controller.currentAccuracy.value.toStringAsFixed(1)} m"),
          _buildInfoRow("Speed", "${controller.currentSpeed.value.toStringAsFixed(1)} m/s"),
          const Divider(),
          _buildInfoRow("Timestamp", DateFormat('HH:mm:ss').format(controller.lastUpdated.value)),
        ],
      )),
      textConfirm: "Tutup",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue.shade800,
      onConfirm: () => Get.back(),
    );
  }

  // Widget Helper untuk Baris Info
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}