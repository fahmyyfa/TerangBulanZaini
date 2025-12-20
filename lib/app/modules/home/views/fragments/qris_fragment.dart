import 'package:flutter/material.dart';

class QrisFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QRIS"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(blurRadius: 10, color: Colors.black12)
                  ]),
              child: const Icon(Icons.qr_code_2, size: 250),
            ),
            const SizedBox(height: 20),
            const Text("Bayar Melalui QR Berikut",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Saldo Point: 0", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
