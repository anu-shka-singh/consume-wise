import 'dart:async';
import 'package:flutter/material.dart';
import 'package:overlay/signin_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(seconds: 3), // Duration of the splash screen
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const LoginPage(), // Replace with your main screen widget
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
