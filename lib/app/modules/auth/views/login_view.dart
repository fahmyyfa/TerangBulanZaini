import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  final controller = Get.put(AuthController());

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Icon(Icons.cookie_outlined,
                    size: 70, color: Colors.blue.shade800),
              ),
              const SizedBox(height: 30),
              Text(
                "Terang Bulan\nPak Zaini",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900),
              ),
              const SizedBox(height: 10),
              Text(
                "Nikmati kelezatan di setiap gigitan",
                style:
                    GoogleFonts.poppins(fontSize: 14, color: Colors.blueGrey),
              ),
              const SizedBox(height: 40),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: controller.emailC,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined,
                            color: Colors.blue.shade700),
                        filled: true,
                        fillColor: Colors.blue.shade50.withOpacity(0.5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller.passwordC,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline,
                            color: Colors.blue.shade700),
                        filled: true,
                        fillColor: Colors.blue.shade50.withOpacity(0.5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Obx(() => controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.blue)
                        : SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => controller.login(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text("MASUK SEKARANG",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600)),
                            ),
                          )),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => controller.register(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue.shade800),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text("DAFTAR AKUN BARU",
                            style: GoogleFonts.poppins(
                                color: Colors.blue.shade800)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
