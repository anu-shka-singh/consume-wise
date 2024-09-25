import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:overlay/screens/health_analysis.dart';
import 'package:overlay/screens/loading_screen.dart';
import 'package:http/http.dart' as http;

class CategoryResult extends StatefulWidget {
  final String categories;
  const CategoryResult({super.key, required this.categories});

  @override
  State<CategoryResult> createState() => _CategoryResultState();
}

class _CategoryResultState extends State<CategoryResult> {
  bool isLoading = true;
  List products = [];
  List products2 = [];

  @override
  void initState() {
    super.initState();
    searchProductsWithCategory(widget.categories);
  }

  void searchProductsWithCategory(String categories) async {
    int currentPage = 1;
    int totalPages = 5;
    int productsPerPage = 20;
    int retryCount = 3;
    Duration timeoutDuration = const Duration(seconds: 10);

    List<dynamic> allProducts = [];

    setState(() {
      isLoading = true;
    });

    for (int page = currentPage; page <= totalPages; page++) {
      bool success = false;
      for (int retry = 0; retry < retryCount; retry++) {
        try {
          final url = Uri.parse(
              'https://world.openfoodfacts.net/api/v2/search?categories_tags_en=$categories&countries_tags_en=india&languages_tags_en=english&page=$page&page_size=$productsPerPage');

          print("Fetching page $page, attempt ${retry + 1}");

          final response = await http.get(url).timeout(timeoutDuration);

          if (response.statusCode == 200) {
            print("Page $page: status-code: ${response.statusCode}");
            final data = json.decode(response.body);

            if (data['products'] != null && data['products'].isNotEmpty) {
              setState(() {
                products2 = data['products'];

                for (int i = 0; i < products2.length; i++) {
                  allProducts.add(products2[i]); // Add to the combined list
                }
              });
              success = true;
              break;
            } else {
              print("No products found on page $page");
              break;
            }
          } else {
            print("Error fetching page $page: ${response.statusCode}");
            break;
          }
        } on TimeoutException catch (e) {
          print("Request timed out on page $page, attempt ${retry + 1}: $e");

          if (retry == retryCount - 1) {
            print("Max retries reached for page $page. Moving to next page.");
          }
        } catch (e) {
          print("An error occurred: $e");
          break;
        }
      }

      if (!success) {
        break;
      }
    }

    setState(() {
      products = allProducts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF055b49),
        title: const Text('Results'),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFFFF6E7),
      body: isLoading
          ? const LoadingScreen()
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                // Get product details
                final String productName =
                    product['product_name'] ?? 'Unknown Product';
                final String? imageUrl = product['image_url'];
                final String quantity = product['quantity'] ?? 'N/A';

                return Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HealthAnalysis(
                          product: product,
                        ),
                      ),
                    ),
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: Colors.grey,
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                            ),
                            const SizedBox(width: 16),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Name
                                  Text(
                                    productName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // Product Quantity
                                  Text(
                                    'Quantity: $quantity',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Product Brand
                                  Text(
                                    product['brands'] ?? 'Unknown Brand',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF055b49),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
