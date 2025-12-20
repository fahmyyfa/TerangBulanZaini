import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/services/notification_service.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/modules/auth/views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyABz-5HCuAi6R8HT4tyd-8gvT_gBTIHQN8', //api key dari google-service.json
      appId: '1:858215284680:android:043a236b4c15084888cafd', //mobilesdk_app_id dari google-service.json
      messagingSenderId: '858215284680', //project_number dari google-service.json
      projectId: 'praktikum-mobile-f9598', //project_id dari google-service.json
      storageBucket: 'praktikum-mobile-f9598.firebasestorage.app', //storage_bucket dari google-service.json
    ),
  );
  await NotificationService().initLocalNotification();
  await NotificationService().initFCM();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!, 
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!, 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return GetMaterialApp(
      title: "Terani's",
      debugShowCheckedModeBanner:
          false, 

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.brown, 
          elevation: 0,
        ),
      ),

      home: user != null ? HomeView() : LoginView(),
    );
  }
}
