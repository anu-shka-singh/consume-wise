import 'package:flutter/material.dart';

class HealthAnalysis2 extends StatelessWidget {
  final Map<String, dynamic> product;

  const HealthAnalysis2({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from product map
    String productName = product['productName'];
    String productBarcode = product['productBarcode'];
    String productCategory = product['productCategory'];
    List<dynamic> ingredients = product['ingredients'];
    List<dynamic> nutritionalValue = product['nutritionalValue'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Analysis'),
        backgroundColor: const Color(0xFF055b49), // Custom color for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Display Product Name
            Text(
              'Product Name: $productName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Display Product Barcode
            Text(
              'Barcode: $productBarcode',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Display Product Category
            Text(
              'Category: $productCategory',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Display Ingredients
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                '- $ingredient',
                style: const TextStyle(fontSize: 16),
              ),
            )),
            const SizedBox(height: 20),

            // Display Nutritional Values
            const Text(
              'Nutritional Values (per 100g):',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...nutritionalValue.map((nutrient) {
              String nutrientName = nutrient['name'];
              double valuePer100g = nutrient['valuesPer100g'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  '$nutrientName: $valuePer100g g',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
