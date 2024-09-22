import 'package:flutter/material.dart';

import 'data_collection.dart';

class ProductNotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF055b49),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFFFF6E7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/not_found.png", height: 170,),
            SizedBox(height: 40,),
            const Text(
              "It seems we don't have this product in our database.",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            const Text(
              "Help us improve our database! Just follow some simple steps and get real-time analysis.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                // Navigate to the data collection page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductContributionApp()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF86b649),
              ),
              child: const Text('Help Us Collect Data', style: TextStyle(color: Colors.white, fontSize: 19),),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF055b49),
              ),
              child: const Text('Go Back to Home', style: TextStyle(color: Colors.white70),),
            ),
          ],
        ),
      ),
    );
  }
}

