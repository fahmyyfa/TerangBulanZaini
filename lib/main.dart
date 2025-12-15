import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/services/notification_service.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/modules/auth/views/login_view.dart';

void main() async {
  // 1. Wajib ada: Memastikan mesin Flutter siap sebelum menjalankan kode lain
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load Kunci Rahasia dari file .env
  // (Pastikan file .env sudah ada di folder root project kamu)
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();
  await NotificationService().initLocalNotification();
  await NotificationService().initFCM();

  // 3. Koneksi ke Supabase (Menyalakan Listrik Ruko)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!, // Mengambil URL dari .env
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!, // Mengambil Key dari .env
  );

  // 4. Jalankan Aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cek apakah ada user yang sedang login di HP ini?
    // (Supabase otomatis menyimpan sesi login di memori HP)
    final user = Supabase.instance.client.auth.currentUser;

    return GetMaterialApp(
      title: 'Terang Bulan Pak Zaini',
      debugShowCheckedModeBanner:
          false, // Menghilangkan pita 'Debug' di pojok kanan atas

      // Tema Warna Aplikasi (Kuning Terang Bulan)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.brown, // Warna teks/ikon AppBar
          elevation: 0,
        ),
      ),

      // LOGIKA PINTU MASUK CERDAS:
      // Jika user != null (sudah login) -> Langsung masuk HomeView (Menu)
      // Jika user == null (belum login) -> Masuk LoginView
      home: user != null ? HomeView() : LoginView(),
    );
  }
}
