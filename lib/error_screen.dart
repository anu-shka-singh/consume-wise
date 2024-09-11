import 'package:flutter/material.dart';
import 'dart:async';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRedirect;

  ErrorScreen({required this.errorMessage, required this.onRedirect});

  @override
  Widget build(BuildContext context) {
    // Automatically navigate after 3 seconds
    Future.delayed(const Duration(seconds: 1), () {
      onRedirect(); // Trigger the navigation to the CalorieCounterPage
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF055b49),
      ),
      body: Container(
        color: const Color(0xFFFFF6E7),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/error.png', height: 150, width: 150), // Adjust size as needed
                    const SizedBox(height: 20),
                    const Text(
                      "Oops!",
                      style: TextStyle(
                        fontSize: 26.0,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
