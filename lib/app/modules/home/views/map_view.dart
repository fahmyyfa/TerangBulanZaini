import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
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
          
          // --- REVISI 1: ZOOM CONTROLS ---
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoom_in",
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.black87),
                  onPressed: () {
                    final currentZoom = mapController.camera.zoom;
                    mapController.move(mapController.camera.center, currentZoom + 1);
                  },
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "zoom_out",
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.black87),
                  onPressed: () {
                    final currentZoom = mapController.camera.zoom;
                    mapController.move(mapController.camera.center, currentZoom - 1);
                  },
                ),
              ],
            ),
          ),
          
          // Info Card di Bawah
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
}