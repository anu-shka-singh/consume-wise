import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay/chatbot_page.dart';
import 'package:overlay/image_upload.dart';
import 'package:overlay/calorie_counter_page.dart';
import 'package:overlay/popular_product_result.dart';
import 'package:overlay/profile.dart';
import 'package:overlay/search.dart';
import 'package:http/http.dart' as http;
import 'package:overlay/signin_page.dart';

class MainScreen extends StatefulWidget {
  Map<String, dynamic> user;
  final int currentIndex; // To keep track of active tab
  MainScreen({super.key, required this.user, required this.currentIndex});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchSuggestions = [];
  bool isLoading = false;

  // Function to fetch search suggestions from Open Food Facts API
  Future<void> fetchSearchSuggestions(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      final url = Uri.parse(
          'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&countries_tags_en=india&languages_tags_en=english&json=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> products = data['products'] ?? [];

        setState(() {
          searchSuggestions = products
              .map<String>(
                  (product) => product['product_name'] ?? 'Unknown Product')
              .toList();

          searchSuggestions = searchSuggestions.sublist(0, 5);

          isLoading = false;
        });
      } else {
        setState(() {
          searchSuggestions = [];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        searchSuggestions = [];
        isLoading = false;
      });
    }
  }

  void onSearchChanged(String query) {
    fetchSearchSuggestions(query);
  }

  void onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductSearchPage(query: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF055b49),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF6E7),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF055b49),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: onSearchChanged,
                      onSubmitted: onSearchSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            onSearchSubmitted(_searchController.text);
                          },
                        ),
                      ),
                    ),

                    // Show search suggestions in real-time
                    if (searchSuggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchSuggestions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(searchSuggestions[index]),
                              onTap: () {
                                onSearchSubmitted(searchSuggestions[index]);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              //Barcode scanner
              Card(
                elevation: 4,
                color: const Color.fromARGB(255, 255, 255, 255),
                margin: const EdgeInsets.all(14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/barcode-scan.png',
                        width: 70, // Adjust the width as needed
                        height: 100, // Adjust the height as needed
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Scan the product",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF055b49)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ImageUpload(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            // const SizedBox(height: 10),
                            const Text(
                              "Know the nutritional value of your product",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Title for Popular Products
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Know what's inside",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            Color(0xFF055b49), // You can customize this color
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // List for Popular Products
              SizedBox(
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      HorizontalCards(
                        imageFilename: 'assets/images/dairy-products.png',
                        title: 'Dairy Items',
                        categoryTags: "dairies|milks",
                      ),
                      SizedBox(width: 16),
                      HorizontalCards(
                        imageFilename: 'assets/images/bread.png',
                        title: 'Breads',
                        categoryTags: "breads",
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      HorizontalCards(
                        imageFilename: 'assets/images/cookies.png',
                        title: 'Biscuits\n& Cakes',
                        categoryTags: "biscuits-and-cakes",
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      HorizontalCards(
                        imageFilename: 'assets/images/soda.png',
                        title: 'Beverages',
                        categoryTags: "carbonated-drinks|juice",
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      HorizontalCards(
                        imageFilename: 'assets/images/chocolate-bar.png',
                        title: 'Chocolates',
                        categoryTags: "chocolates",
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      HorizontalCards(
                        imageFilename: 'assets/images/cereal.png',
                        title: 'Breakfast Cereals',
                        categoryTags: "breakfast-cereals",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 13),
              // Tracking Caloric Intake
              Card(
                elevation: 4,
                color: const Color(0xFF055b49),
                margin: const EdgeInsets.all(14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Track Your Daily Caloric Intake',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Enter the food you’ve eaten and get the calorie count.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // Action for the button
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CalorieCounterPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(
                                    0xFF86b649), // Button background color
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 28.0), // Button padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Rounded corners
                                ),
                              ),
                              child: const Text(
                                'Let\'s Go',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right part with image
                      Expanded(
                        flex: 3,
                        child: Image.asset(
                          'assets/images/calorie-image.png',
                          height: 240,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        backgroundColor: const Color(0xFFFFF6E7),
        //backgroundColor: Color(0xFF86b649) // light green
        unselectedItemColor: Colors.grey,
        selectedItemColor: const Color(0xFF055b49),
        iconSize: 32,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatBotScreen(
                    user: widget.user,
                    currentIndex: 1,
                  ),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    user: widget.user,
                    currentIndex: 2,
                  ),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  // Widget popularProductCard({
  //   required String productName,
  //   required int barcode,
  //   required String imagePath,
  // }) {
  //   return Card(
  //     elevation: 4, // Controls the shadow of the card
  //     color: const Color.fromARGB(255, 255, 255, 255),
  //     margin: const EdgeInsets.all(10.0),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: SizedBox(
  //       width: 140,
  //       height: 280,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           // Product Image
  //           Padding(
  //             padding: const EdgeInsets.all(5.0),
  //             child: Container(
  //               height: 100,
  //               width: 90,
  //               decoration: BoxDecoration(
  //                 borderRadius:
  //                     const BorderRadius.vertical(top: Radius.circular(12)),
  //                 image: DecorationImage(
  //                     image: AssetImage(imagePath), fit: BoxFit.fitHeight),
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(5.0),
  //             child: Column(
  //               children: [
  //                 Text(
  //                   productName,
  //                   style: const TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 15,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
class HorizontalCards extends StatelessWidget {
  final String imageFilename;
  final String title;
  final String categoryTags;

  const HorizontalCards({
    Key? key,
    required this.imageFilename,
    required this.title,
    required this.categoryTags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The card with just an image
        Center(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryResult(
                  categories: categoryTags,
                ),
              ),
            ),
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(  // Padding inside the card
                padding: const EdgeInsets.all(12.0),  // You can adjust the padding here
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 100.0,
                    height: 90.0,
                    color: Colors.white,
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        imageFilename,
                        width: 80.0,
                        height: 80.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        // Text below the card
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
