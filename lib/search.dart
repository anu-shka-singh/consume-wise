import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:overlay/health_analysis.dart';

class ProductSearchPage extends StatefulWidget {
  final String query;

  const ProductSearchPage({super.key, required this.query});

  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  List products = [];
  List products2 = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[
    //   OpenFoodFactsLanguage.ENGLISH
    // ];
    // OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.INDIA;
    //searchProducts(widget.query);
    // OpenFoodAPIConfiguration.globalUser = const User(
    //   userId: 'overlay', // Set your app name or identifier
    //   password: '', // Leave blank unless you're using authentication
    //   comment: 'App with Firebase authentication',
    // );
    searchProducts(widget.query);
  }

  void searchProducts(String query) async {
    int currentPage = 1;
    int totalPages = 5;
    int productsPerPage = 20;
    int retryCount = 3; // Maximum number of retries in case of timeout
    Duration timeoutDuration = Duration(seconds: 10); // Timeout duration

    List<dynamic> allProducts = [];

    setState(() {
      isLoading = true;
    });

    for (int page = currentPage; page <= totalPages; page++) {
      bool success = false; // Flag to check if request was successful
      for (int retry = 0; retry < retryCount; retry++) {
        try {
          final url = Uri.parse(
              'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&countries_tags_en=india&languages_tags_en=english&json=true&page=$page&page_size=$productsPerPage');

          print("Fetching page $page, attempt ${retry + 1}");

          final response = await http.get(url).timeout(timeoutDuration);

          if (response.statusCode == 200) {
            print("Page $page: status-code: ${response.statusCode}");
            final data = json.decode(response.body);

            if (data['products'] != null && data['products'].isNotEmpty) {
              setState(() {
                products2 = data['products'];

                for (int i = 0; i < products2.length; i++) {
                  String temp = "";

                  if (products2[i]['product_name'] != null) {
                    temp = products2[i]['product_name'];
                  }

                  // Compare the lowercase product name with the query
                  if (temp.toLowerCase().contains(query.toLowerCase())) {
                    allProducts.add(products2[i]); // Add to the combined list
                  }
                }
              });
              success = true; // Mark request as successful
              break; // Exit retry loop if successful
            } else {
              print("No products found on page $page");
              break;
            }
          } else {
            print("Error fetching page $page: ${response.statusCode}");
            break; // Stop further requests in case of non-200 status code
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

  // Future<void> searchProd(String prodname) async {
  //   ProductSearchQueryConfiguration configuration =
  //       ProductSearchQueryConfiguration(
  //     fields: [ProductField.ALL], // You can specify the fields you need
  //     parametersList: [
  //       SearchTerms(terms: [prodname]),
  //     ],
  //     version: ProductQueryVersion.v3,
  //   );

  //   // final User myUser = User(
  //   //   userId: 'overlay', // Your app's name or identifier
  //   //   password: '', // Leave blank if you're not using authentication
  //   //   comment: 'Internal test app', // Optional: Description or comment
  //   // );

  //   SearchResult result = await OpenFoodAPIClient.searchProducts(
  //     OpenFoodAPIConfiguration.globalUser,
  //     configuration,
  //   );

  //   setState(() {
  //     products2 = result.products ?? [];
  //     // if (products.isNotEmpty){

  //     // }
  //     print("products-size : ${products2}");
  //     isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF055b49),
        title: const Text('Search Results'),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Color(0xFF055b49),
            ))
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
                                    )
                                  : Container(
                                      height: 80,
                                      width: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
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
