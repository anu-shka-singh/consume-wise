import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(seconds: 3), // Duration of the splash screen
          () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(), // Replace with your main screen widget
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

