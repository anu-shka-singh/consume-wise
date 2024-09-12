import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay/overlays/true_caller_overlay.dart';
import 'package:overlay/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyD2IGeXqXW6eNEkdqRDUJIOCzvjhp73by8",
            authDomain: "consumewise.firebaseapp.com",
            databaseURL:
                "https://consumewise-default-rtdb.asia-southeast1.firebasedatabase.app",
            projectId: "consumewise",
            storageBucket: "consumewise.appspot.com",
            messagingSenderId: "420047878605",
            appId: "1:420047878605:web:bef7a6778e4ab84c7d6c84"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallerOverlay(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
