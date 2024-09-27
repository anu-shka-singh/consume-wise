import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlay/screens/chatbot_page.dart';
import 'package:overlay/database/database_service.dart';
import 'package:overlay/screens/image_upload.dart';
import 'package:overlay/screens/calorie_counter_page.dart';
import 'package:overlay/overlay_permissions/permissions_granted.dart';
import 'package:overlay/overlay_permissions/permissions_screen.dart';
import 'package:overlay/overlays/popular_product_result.dart';
import 'package:overlay/screens/profile_page.dart';
import 'package:overlay/screens/search_bar.dart';
import 'package:http/http.dart' as http;
import 'package:overlay/screens/signin_page.dart';

class MainScreen extends StatefulWidget {
  Map<String, dynamic> user;
  final int currentIndex; // To keep track of active tab
  DatabaseService? dbService;
  bool? permissionsAvailable;
  MainScreen(
      {super.key,
      required this.user,
      required this.currentIndex,
      this.dbService,
      this.permissionsAvailable});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String searchType = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> searchSuggestions = [];
  bool isLoading = false;

  String convertToHyphenatedLowercase(String input) {
    String lowercased = input.toLowerCase();
    String hyphenated = lowercased.replaceAll(RegExp(r'\s+'), '-');
    return hyphenated;
  }

  Future<http.Response> fetchApiData(String convertedQuery, String URL) async {
    final url = Uri.parse(URL);
    final response = await http.get(url);
    return response;
  }

  // Function to fetch search suggestions from Open Food Facts API
  Future<void> fetchSearchSuggestions(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      String convertedQuery = convertToHyphenatedLowercase(query);

      String url =
          'https://world.openfoodfacts.net/api/v2/search?categories_tags_en=$convertedQuery&countries_tags_en=india&languages_tags_en=english';
      final response = await fetchApiData(convertedQuery, url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> products = data['products'] ?? [];

        setState(() {
          searchSuggestions = products
              .map<String>(
                  (product) => product['product_name'] ?? 'Unknown Product')
              .toList();

          if (searchSuggestions.length > 5) {
            searchSuggestions = searchSuggestions.sublist(0, 5);
          }
        });
        searchType = 'category';
      } else {
        setState(() {
          searchSuggestions = [];
        });
      }
      // no product received in response
      if (searchSuggestions.isEmpty) {
        url =
            'https://world.openfoodfacts.net/api/v2/search?brands_tags=$convertedQuery&countries_tags_en=india&languages_tags_en=english';
        final response2 = await fetchApiData(convertedQuery, url);
        if (response2.statusCode == 200) {
          final data = json.decode(response2.body);
          List<dynamic> products = data['products'] ?? [];

          setState(() {
            searchSuggestions = products
                .map<String>(
                    (product) => product['product_name'] ?? 'Unknown Product')
                .toList();

            if (searchSuggestions.length > 5) {
              searchSuggestions = searchSuggestions.sublist(0, 5);
            }
          });
        } else {
          setState(() {
            searchSuggestions = [];
          });
        }
        searchType = 'brand';
      }
    } else {
      setState(() {
        searchSuggestions = [];
      });
    }
    isLoading = false;
  }

  void onSearchChanged(String query) {
    fetchSearchSuggestions(query);
  }

  void onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductSearchPage(
            query: query,
            searchType: searchType,
          ),
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
            icon: const Icon(Icons.settings), // Your desired icon
            onPressed: () async {
              if (widget.permissionsAvailable!) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PermissionsGranted(widget.dbService!),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PermissionsScreen(widget.dbService!),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    dbService: widget.dbService!,
                    permissionsAvailable: widget.permissionsAvailable!,
                  ),
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
                        hintText: 'Search products by category or brands...',
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
                        width: 70,
                        height: 100,
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
}

class HorizontalCards extends StatelessWidget {
  final String imageFilename;
  final String title;
  final String categoryTags;

  const HorizontalCards({
    super.key,
    required this.imageFilename,
    required this.title,
    required this.categoryTags,
  });

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
              child: Padding(
                // Padding inside the card
                padding: const EdgeInsets.all(
                    12.0), // You can adjust the padding here
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
