import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:overlay/database/database_service.dart';
import 'package:overlay/monitoring_service/utils/flutter_background_service_utils.dart';
import 'package:overlay/overlays/circular_overlay.dart';
import 'package:overlay/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'firebase_options.dart';

void main() async {
  await onStart();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DatabaseService dbService = await DatabaseService.instance();
  bool permissionsAvailable = (await UsageStats.checkUsagePermission())! &&
      await FlutterOverlayWindow.isPermissionGranted();
  await requestPermissions();
  runApp(MyApp(
    dbService: dbService,
    permissionsAvailable: permissionsAvailable,
  ));
}

onStart() async {
  WidgetsFlutterBinding.ensureInitialized();

  await startMonitoringService();
}

Future<void> requestPermissions() async {
  var status = await Permission.mediaLibrary.request();
  if (status.isGranted) {
    log("Media Projection Permission Granted");
  } else {
    log("Media Projection Permission Denied");
  }
}

@pragma("vm:entry-point")
void overlayMain() {
  debugPrint("Starting Alerting Window Isolate!");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LeafOverlay()),
    // const MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     home: HealthOverlay(
    //       negative: ["High Fat", "High sugar", "Low Protien", "Palm Oil"],
    //       positive: ["High Vitamins", "Improves Gut", "No Preservatives"],
    //       rating: 4,
    //     )),
  );
}

class MyApp extends StatefulWidget {
  final DatabaseService dbService;
  final bool permissionsAvailable;

  const MyApp(
      {super.key, required this.dbService, required this.permissionsAvailable});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: //HomePage(),
          SplashScreen(
        dbService: widget.dbService,
        permissionsAvailable: widget.permissionsAvailable,
      ),
    );
  }
}
