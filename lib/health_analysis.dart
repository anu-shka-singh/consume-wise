import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay/claim_checker.dart';
import 'package:overlay/image_upload.dart';

class HealthAnalysis extends StatefulWidget {
  const HealthAnalysis({super.key});

  @override
  State<HealthAnalysis> createState() => _HealthAnalysisState();
}

class _HealthAnalysisState extends State<HealthAnalysis> {
  final List<bool> _isExpanded = [false, false];

  List<String> keywords = [
    "Health",
    "Fitness",
    "Nutrition",
    "Wellness",
    "Diet",
    "Energy",
    "Mindfulness"
  ];
  List<Map<String, String>> ingredients = [
    {'name': 'Ingredient 1', 'description': 'Description of ingredient 1...'},
    {'name': 'Ingredient 2', 'description': 'Description of ingredient 2...'},
    {'name': 'Ingredient 3', 'description': 'Description of ingredient 3...'},
    {'name': 'Ingredient 4', 'description': 'Description of ingredient 4...'},
    {'name': 'Ingredient 4', 'description': 'Description of ingredient 4...'},
    {'name': 'Ingredient 4', 'description': 'Description of ingredient 4...'},
  ];
  late List<bool> _panelExpanded;
  List<Map<String, String>> facts = [
    {'name': 'fact 1', 'description': 'Description of fact 1...'},
    {'name': 'fact 2', 'description': 'Description of fact 2...'},
    {'name': 'fact 3', 'description': 'Description of fact 3...'},
    {'name': 'fact 4', 'description': 'Description of fact 4...'},
  ];

  Map<String, String> allergyIcons = {
    "Peanuts": "assets/images/peanuts.png",
    "Eggs": "assets/images/egg.png",
    "Wheat": "assets/images/wheat.png",
    "Soybeans": "assets/images/soy.png",
    "Milk": "assets/images/milk.png",
    "Fish": "assets/images/fish.png",
    "Tree Nuts": "assets/images/treenut.png",
    "Sesame Seeds": "assets/images/sesame.png",
  };

  List<String> allergyInfo = ["Peanuts", "Eggs", "Fish"];

  @override
  void initState() {
    super.initState();
    // _scrollController = ScrollController();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   startAutoScroll(); // Start auto-scrolling after the first frame
    // });
    // _panelExpanded = List.generate(ingredients.length, (index) => false);
  }

  // void startAutoScroll() {
  //   _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
  //     if (_scrollController != null && _scrollController!.hasClients) {
  //       double maxScrollExtent = _scrollController!.position.maxScrollExtent;
  //       double currentScroll = _scrollController!.position.pixels;
  //
  //       if (currentScroll < maxScrollExtent) {
  //         _scrollController!.animateTo(
  //           currentScroll + 2.0, // Speed of the scroll
  //           duration: Duration(milliseconds: 50),
  //           curve: Curves.linear,
  //         );
  //       } else {
  //         _scrollController!.jumpTo(0); // Restart scrolling
  //       }
  //     }
  //   });
  // }
  //
  // @override
  // void dispose() {
  //   _scrollController?.dispose();
  //   _timer?.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF055b49),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFFFF6E7),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Product Image
                    Image.asset(
                      'assets/images/kit-kat.png',
                      width: 120, // Adjust the width as needed
                      height: 100, // Adjust the height as needed
                    ),
                    const SizedBox(width: 40),

                    // Right: Heading, subtext, and health rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Heading: KIT-KAT
                          const Text(
                            "Kit-Kat",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 30, 30, 30),
                            ),
                          ),

                          // Subtext: By Nestle
                          const Text(
                            "By: Nestle",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 63, 81, 90),
                            ),
                          ),
                          const SizedBox(height: 16.0), // Spacing before health rating

                          // Health Rating Text
                          const Text(
                            "Health Rating:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 30, 30, 30),
                            ),
                          ),
                          const SizedBox(height: 8.0), // Spacing before star rating

                          // Health Rating: Star Bar (out of 5 stars)
                          buildHealthRatingWidget(4.5), // Replace 4.5 with dynamic rating value
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // horizontally scrolling keywords
              Container(
                height: 40, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: keywords.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF055b49),
                          borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.2), // Subtle shadow for depth
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, 2), // Offset shadow
                            ),
                          ],
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Center(
                          child: Text(
                            keywords[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                              Colors.white, // Text color
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 10,),
              Container(
                height: 40, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: keywords.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.2), // Subtle shadow for depth
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, 2), // Offset shadow
                            ),
                          ],
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Center(
                          child: Text(
                            keywords[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                              Colors.white, // Text color
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20,),

              //Allergy Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                    child: Text(
                      'Allergy Warnings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Wrap(
                      spacing: 20.0,
                      runSpacing: 16.0,
                      children: allergyInfo.map((allergy) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              allergyIcons[allergy]!,
                              width: 50,
                              height: 50,
                            ),
                            const SizedBox(height: 8.0),
                            // Display the allergy name
                            Text(
                              allergy,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF555555), fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              //SizedBox(height: 20,),

              Divider(
                thickness: 1,
                color: Colors.grey[300],
                height: 40,
                indent: 16,
                endIndent: 16,
              ),

              //nutritional information
              Card(
                elevation: 3,
                color: const Color.fromARGB(255, 255, 255, 255),
                margin: const EdgeInsets.all(14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // Nutritional Information Header
                      Text(
                        "Nutritional Information",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Calories Section (Non-Collapsible)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/calories.png', // Use your image asset
                              width: 30, // Adjust the size as needed
                              height: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'Calories:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              '10 kcal',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 5),

                      // Sugar Section (Non-Collapsible)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/sugar.png', // Use your image asset
                              width: 30, // Adjust the size as needed
                              height: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'Sugar:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              '10g',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ExpansionPanel for Macronutrients
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Card(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ExpansionPanelList(
                                elevation: 0,
                                expandedHeaderPadding: EdgeInsets.all(5),
                                animationDuration: Duration(milliseconds: 500),
                                materialGapSize: 5,
                                expansionCallback: (int index, bool isExpanded) {
                                  setState(() {
                                    _isExpanded[index] = !_isExpanded[index]; // Toggle expansion state
                                  });
                                },
                                children: [
                                  _buildMacronutrientPanel(
                                    0, // Make sure index matches the _isExpanded list index
                                    "Macronutrients",
                                    [
                                      {"Carbohydrates": 7.23, "image": 'assets/images/bread.png'},
                                      {"Protein": 0.0, "image": 'assets/images/salad.png'},
                                      {"Fats": 9.77, "image": 'assets/images/fats.png'}
                                    ],
                                    _isExpanded,
                                    setState,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredients Section
                  Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ExpansionTile(
                      leading: Icon(Icons.list, color: Colors.deepPurple), // Ingredients Icon
                      title: Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      children: ingredients.map((ingredient) {
                        return ListTile(
                          title: Text(
                            '${ingredient['name']}',
                            style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
                          ),
                          subtitle: Text(
                            '${ingredient['description']}',
                            style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Diet Compliance Section
                  Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ExpansionTile(
                      leading: Icon(Icons.check_circle, color: Colors.teal), // Diet Compliance Icon
                      title: Text(
                        'Diet Compliance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      children: ingredients.map((ingredient) {
                        return ListTile(
                          title: Text(
                            '${ingredient['name']}',
                            style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
                          ),
                          subtitle: Text(
                            '${ingredient['description']}',
                            style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              Divider(
                thickness: 1,
                color: Colors.grey[300],
                height: 40,
                indent: 16,
                endIndent: 16,
              ),
              // claim analysis
              Card(
                elevation: 4,
                color: const Color(0xFF86b649),
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
                        'assets/images/claim.png',
                        width: 60, // Adjust the width as needed
                        height: 80, // Adjust the height as needed
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
                                  "Verify Product Claims",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                IconButton(
                                  color: Colors.white,
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClaimCheckerPage(
                                          product: {},
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Text(
                              "Know the truth of product claims",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white60),
                              softWrap: true, // Ensures text wraps if necessary
                              overflow: TextOverflow
                                  .visible, // Makes sure text doesn't get cut off
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 20),
                child: Text(
                  "Better Options",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              // List for Popular Products
              SizedBox(
                height: 170,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      popularProductCard(
                        productName: 'Maggi Noodles',
                        barcode: 120,
                        imagePath: 'assets/images/maggi.png',
                      ),
                      const SizedBox(width: 10),
                      popularProductCard(
                        productName: 'Harvest Bread',
                        barcode: 120,
                        imagePath: 'assets/images/bread.jpeg',
                      ),
                      const SizedBox(width: 10),
                      popularProductCard(
                        productName: 'Kissan Jam',
                        barcode: 120,
                        imagePath: 'assets/images/jam.jpeg',
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40,)
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildHealthRatingWidget(double rating) {
  int fullStars = rating.floor();
  bool hasHalfStar = rating - fullStars >= 0.5;

  return Row(
    children: List.generate(5, (index) {
      if (index < fullStars) {
        return const Icon(Icons.star, color: Color(0xFF86b649), size: 30);
      } else if (index == fullStars && hasHalfStar) {
        return const Icon(Icons.star_half, color: Color(0xFF86b649), size: 30);
      } else {
        return const Icon(Icons.star_border, color: Color(0xFF86b649), size: 30);
      }
    }),
  );
}

ExpansionPanel _buildMacronutrientPanel(
    int index,
    String title,
    List<Map<String, dynamic>> nutrients,
    List<bool> isExpanded,
    void Function(void Function()) setState,
    ) {
  return ExpansionPanel(
    backgroundColor: Colors.white,
    headerBuilder: (BuildContext context, bool isExpanded) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0), // Adjust padding as needed
        child: Row(
          children: [
            Image.asset(
              'assets/images/nutrient.png',  // Replace with your image asset
              width: 30,  // Adjust the size as needed
              height: 30,
            ),
            SizedBox(width: 15,),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

          ],
        ),
      );

    },
    body: Column(
      children: nutrients.map((nutrient) {
        return ListTile(
          leading: Image.asset(
            nutrient['image'], // The image for the nutrient
            width: 30,
            height: 30,
          ),
          title: Text(
            nutrient.keys.first,
            style: TextStyle(fontSize: 16),
          ),
          trailing: Text(
            '${nutrient.values.first} g', // The nutrient value
            style: TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    ),
    isExpanded: isExpanded[index],
  );
}

Widget popularProductCard({
  required String productName,
  required int barcode,
  required String imagePath,
}) {
  return Card(
    elevation: 4, // Controls the shadow of the card
    color: const Color.fromARGB(255, 255, 255, 255),
    margin: const EdgeInsets.all(10.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: SizedBox(
      width: 140,
      height: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: 100,
              width: 90,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                    image: AssetImage(imagePath), fit: BoxFit.fitHeight),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
