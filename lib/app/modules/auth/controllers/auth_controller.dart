import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/views/home_view.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  var isLoading = false.obs;

  Future<void> login() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar("Error", "Email dan Password wajib diisi");
      return;
    }

    try {
      isLoading.value = true;
      await supabase.auth.signInWithPassword(
        email: emailC.text,
        password: passwordC.text,
      );

      Get.snackbar("Login Berhasil", "Selamat datang!",
          backgroundColor: Colors.green.shade100);

      // SEMUA user (Admin/Member) masuk ke HomeView
      Get.offAll(() => HomeView());
    } on AuthException catch (e) {
      Get.snackbar("Gagal Login", e.message,
          backgroundColor: Colors.red.shade100);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e",
          backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar("Error", "Email dan Password wajib diisi");
      return;
    }
    try {
      isLoading.value = true;
      await supabase.auth.signUp(email: emailC.text, password: passwordC.text);
      Get.snackbar("Registrasi Berhasil", "Silakan Login dengan akun baru.");
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/');
  }
}
