import 'dart:async';
import 'package:flutter/material.dart';
import 'package:overlay/database/database_service.dart';
import 'package:overlay/screens/signin_page.dart';

class SplashScreen extends StatelessWidget {
  final DatabaseService dbService;
  final bool permissionsAvailable;
  const SplashScreen(
      {super.key, required this.dbService, required this.permissionsAvailable});

  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(seconds: 3), // Duration of the splash screen
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(
              dbService: dbService,
              permissionsAvailable: permissionsAvailable,
            ), // Replace with your main screen widget
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E7),
      body: Center(
        child: Image.asset('assets/images/logo2.png'),
      ),
    );
  }
}
