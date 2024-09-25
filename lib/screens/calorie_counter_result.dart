import 'package:flutter/material.dart';
import 'dart:convert';

import 'calorie_counter_page.dart';
import 'error_screen.dart';
import '../services/gemini.dart';

class ResultScreen extends StatelessWidget {
  final String? response;

  const ResultScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    late Map<String, dynamic> jsonResponse;
    try {
      final cleanResponse = getCleanResponse(response!);
      print("Cleaned response: $cleanResponse");
      jsonResponse = jsonDecode(cleanResponse);
    } catch (e) {
      return ErrorScreen(
        errorMessage: 'No data received',
        onRedirect: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CalorieCounterPage()),
          );
        },
      );
    }

    final userMeal = jsonResponse['user_meal'] ?? 'N/A';
    final totalCalories = jsonResponse['total_calories'] ?? 0;
    final totalFat = jsonResponse['total_fat'] ?? 0;
    final totalProtein = jsonResponse['total_protein'] ?? 0;
    final comment = jsonResponse['comment'] ?? 'No comment provided';
    final timeJog = jsonResponse['time_jog'] ?? 'N/A';
    final timeWalk = jsonResponse['time_walk'] ?? 'N/A';

    if (comment == 'No comment provided') {
      return ErrorScreen(
        errorMessage: 'Please provide a valid input.',
        onRedirect: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CalorieCounterPage()),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF055b49),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFFFF6E7),
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              userMeal,
              style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            // Comment below the heading
            Text(
              comment,
              style: const TextStyle(
                fontSize: 19.0,
                color: Colors.black54,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            // Nutrient Value Card
            Card(
              elevation: 5,
              color: const Color.fromARGB(255, 255, 255, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nutrient Value',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _buildNutrientRow("assets/images/calories.png", 'Calories',
                        '$totalCalories cal'),
                    _buildNutrientRow("assets/images/salad.png", 'Protein',
                        '$totalProtein g'),
                    _buildNutrientRow(
                        "assets/images/fats.png", 'Fat', '$totalFat g'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Time required to burn these calories',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            // Time to Burn Section (Infographic Style)
            _buildInfographicRow(Icons.directions_run, 'Jogging Time', timeJog),
            _buildInfographicRow(
                Icons.directions_walk, 'Walking Time', timeWalk),
          ],
        ),
      ),
    );
  }

  // Helper method to build each nutrient row in the card
  Widget _buildNutrientRow(String image, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(image, height: 30, width: 30),
          const SizedBox(width: 10),
          Text(
            '$label: $value',
            style: const TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  // Helper method to build each infographic row for time
  Widget _buildInfographicRow(IconData icon, String label, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 40.0, color: Colors.blue),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label: $time',
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
