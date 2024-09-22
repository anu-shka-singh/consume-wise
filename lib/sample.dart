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
    Map<String, dynamic> nutritionalValue = product['nutritionalValue'][0]; // Adjusting to access the first element

    return Scaffold(
        appBar: AppBar(
          title: const Text('Health Analysis'),
          backgroundColor: const Color(0xFF055b49),
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
    // Display each nutritional value
    Text('Energy (kcal): ${nutritionalValue['energy-kcal']} kcal', style: const TextStyle(fontSize: 16)),
    Text('Protein: ${nutritionalValue['proteins']} g', style: const TextStyle(fontSize: 16)),
    ],
    ),
    ),
    );
  }
}
