import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:overlay/claim_checker.dart';
import 'package:overlay/loading_screen.dart';
import 'package:overlay/services/gemini.dart';
import 'package:overlay/services/prompts.dart';

void main() {
  final product = {
    'name': 'Maggi',
    'company': 'Nestle',
    'ingredients': [
      "Wheat flour (atta) (85.3%)",
      "Palm oil",
      "Iodised salt",
      "Thickeners (508, 412)",
      "Humectants (451(1), 452(i))",
      "Acidity regulators (501(i), 500(i))",
      "Mixed spices (22.5%)",
      "Roasted spice mix powder (6.6%) (Coriander, Turmeric, Cumin, Aniseed, Black pepper, Fenugreek, Ginger, Green cardamom, Cinnamon, Clove, Nutmeg, Bay leaf & Black cardamom)",
      "Onion powder",
      "Garlic powder",
      "Red chilli powder",
      "Red chilli bib",
      "Coriander powder",
      "Turmeric powder",
      "Ginger powder",
      "Aniseed powder",
      "Black pepper powder",
      "Cumin powder",
      "Cumin",
      "Fenugreek powder",
      "Capsicum extract",
      "Compounded asafoetida",
      "Star anise powder",
      "Coriander extract",
      "Cumin extract",
      "Dehydrated Vegetables (16.7%)",
      "Carrot bits (8.5%)",
      "Green peas (8.2%)",
      "Toasted onion flakes (Onion (12.4%) & Corn oil)",
      "Refined wheat flour (Maida)",
      "Sugar",
      "Iodised salt",
      "Toasted onion powder (Onion (5.9%) & Corn oil)",
      "Thickener (508)",
      "Palm oil",
      "Flavour enhancer (635)",
      "Yeast extract powder",
      "Dehydrated kasuri methi leaves",
      "Starch",
      "Acidity regulator (330)",
      "Mineral",
      "Wheat gluten",
      "Contains Wheat",
      "May contain Milk, Oats, and Soy"
    ],
    'calories': '15kcal',
    'sugar': '20g',
  };
  runApp(MaterialApp(
    home: HealthAnalysis(
      product: product,
    ),
  ));
}

class HealthAnalysis extends StatefulWidget {
  final Map<String, dynamic> product;
  HealthAnalysis({super.key, required this.product});

  @override
  State<HealthAnalysis> createState() => _HealthAnalysisState();
}

class _HealthAnalysisState extends State<HealthAnalysis> {
  final List<bool> _isExpanded = [false, false];
  late List<Map<String, dynamic>> ingredients;
  late Map<String, dynamic> nutriments;
  late Map<String, dynamic> analysis;
  bool isLoading = false;
  late List<String> allergies = [];
  //late List<bool> _panelExpanded;

  Map<String, String> allergyIcons = {
    "en:peanuts": "assets/images/peanuts.png",
    "en:eggs": "assets/images/egg.png",
    "en:wheat": "assets/images/wheat.png",
    "en:soybeans": "assets/images/soy.png",
    "en:milk": "assets/images/milk.png",
    "en:fish": "assets/images/fish.png",
    "en:tree-nuts": "assets/images/treenut.png",
    "en:sesame-seeds": "assets/images/sesame.png",
    "Other": "assets/images/error.png"
  };

  @override
  void initState() {
    super.initState();
    isLoading = true;
    performHealthAnalysis();
  //   List<dynamic> jsonList = json.decode(widget.product['ingredients']);
  // List<Map<String, dynamic>> ingredients = jsonList.map((item) => item as Map<String, dynamic>).toList();
    ingredients = List<Map<String, dynamic>>.from(widget.product['ingredients']);
    nutriments = Map<String, dynamic>.from(widget.product['nutriments']);
    allergies = List<String>.from(widget.product['allergens_hierarchy']);

    // _scrollController = ScrollController();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   startAutoScroll(); // Start auto-scrolling after the first frame
    // });
    // _panelExpanded = List.generate(ingredients.length, (index) => false);
  }

  Future<void> performHealthAnalysis() async {
    final String response = await healthAnalysis(widget.product);
    final cleanResponse = getCleanResponse(response);
    if (cleanResponse.isNotEmpty) {
      setState(() {
        analysis = jsonDecode(cleanResponse);
        isLoading = false;
      });
    }
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
      body: isLoading
          ? LoadingScreen()
          : Container(
              color: const Color(0xFFFFF6E7),
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
                          Image.network(
                            widget.product["image_url"],
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
                                Text(
                                  widget.product['product_name'].toString(),
                                  style: const TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 30, 30, 30),
                                  ),
                                ),

                                // Subtext: By Nestle
                                Text(
                                  "By: ${widget.product['brands'].toString()}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 63, 81, 90),
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        16.0), // Spacing before health rating

                                // Health Rating Text
                                const Text(
                                  "Health Rating:",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 30, 30, 30),
                                  ),
                                ),
                                const SizedBox(
                                    height: 8.0), // Spacing before star rating

                                // Health Rating: Star Bar (out of 5 stars)
                                buildHealthRatingWidget(analysis[
                                    'rating']), // Replace 4.5 with dynamic rating value
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
                        itemCount: analysis['positive'].length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF055b49),
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.2), // Subtle shadow for depth
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2), // Offset shadow
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Center(
                                child: Text(
                                  analysis['positive'][index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Text color
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 40, // Adjust height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: analysis['negative'].length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.2), // Subtle shadow for depth
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2), // Offset shadow
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Center(
                                child: Text(
                                  analysis['negative'][index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Text color
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    //Allergy Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20.0),
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
                            children: allergies.map((allergy) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    allergyIcons.containsKey(allergy)
                                        ? allergyIcons[allergy]!
                                        : allergyIcons['Other']!,
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 8.0),
                                  // Display the allergy name
                                  Text(
                                    allergy[3].toUpperCase() + allergy.substring(4),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF555555),
                                        fontWeight: FontWeight.bold),
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
                            const Text(
                              "Nutritional Information",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // // Calories Section (Non-Collapsible)
                            // Container(
                            //   padding: const EdgeInsets.all(10),
                            //   decoration: BoxDecoration(
                            //     color: const Color.fromARGB(255, 255, 255, 255),
                            //     borderRadius: BorderRadius.circular(16),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Image.asset(
                            //         'assets/images/calories.png', // Use your image asset
                            //         width: 30, // Adjust the size as needed
                            //         height: 30,
                            //       ),
                            //       const SizedBox(width: 15),
                            //       const Text(
                            //         'Calories:',
                            //         style: TextStyle(
                            //           fontSize: 18,
                            //           fontWeight: FontWeight.bold,
                            //           color: Color(0xFF2C2C2C),
                            //         ),
                            //       ),
                            //       const SizedBox(width: 20),
                            //       Text(
                            //         widget.product['calories'],
                            //         style: const TextStyle(
                            //           fontSize: 18,
                            //           color: Color(0xFF2C2C2C),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            // const SizedBox(height: 5),

                            // Cholestrol Section (Non-Collapsible)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/better-health.png', // Use your image asset
                                    width: 30, // Adjust the size as needed
                                    height: 30,
                                  ),
                                  const SizedBox(width: 15),
                                  const Text(
                                    'cholesterol:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    nutriments['cholesterol'].toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 5),

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
                                  const SizedBox(width: 15),
                                  const Text(
                                    'Sugar:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    nutriments['sugar'].toString(),
                                    style: const TextStyle(
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
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ExpansionPanelList(
                                      elevation: 0,
                                      expandedHeaderPadding:
                                          const EdgeInsets.all(5),
                                      animationDuration:
                                          const Duration(milliseconds: 500),
                                      materialGapSize: 5,
                                      expansionCallback:
                                          (int index, bool isExpanded) {
                                        setState(() {
                                          _isExpanded[index] = !_isExpanded[
                                              index]; // Toggle expansion state
                                        });
                                      },
                                      children: [
                                        _buildMacronutrientPanel(
                                          0, // Make sure index matches the _isExpanded list index
                                          "Macronutrients",
                                          [
                                            {
                                              "Carbohydrates":
                                                  nutriments['carbohydrates'],
                                              "image": 'assets/images/bread.png'
                                            },
                                            {
                                              "Protein": nutriments['protiens'],
                                              "image": 'assets/images/salad.png'
                                            },
                                            {
                                              "Fats": nutriments['fat'],
                                              "image": 'assets/images/fats.png'
                                            }
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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ExpansionTile(
                            leading: const Icon(Icons.list,
                                color: Colors.deepPurple), // Ingredients Icon
                            title: const Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            children: ingredients.map<Widget>((ingredient) {
                              return ListTile(
                                title: Text(
                                  ingredient["text"][0].toUpperCase() +
                                      ingredient['text'].substring(1),
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF555555)),
                                ),
                                // subtitle: Text(
                                //   '${ingredient['description']}',
                                //   style: TextStyle(
                                //       fontSize: 14, color: Color(0xFF888888)),
                                // ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Diet Compliance Section
                        Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ExpansionTile(
                            leading: const Icon(Icons.check_circle,
                                color: Colors.teal), // Diet Compliance Icon
                            title: const Text(
                              'Diet Compliance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            children: analysis['diet'].map<Widget>((item) {
                              return ListTile(
                                title: Text(
                                  '${item['name']}',
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF555555)),
                                ),
                                subtitle: Text(
                                  '${item['description']}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xFF888888)),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                              builder: (context) =>
                                                  ClaimCheckerPage(
                                                product: widget.product,
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white60),
                                    softWrap:
                                        true, // Ensures text wraps if necessary
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

                    const SizedBox(
                      height: 40,
                    )
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
        return const Icon(Icons.star_border,
            color: Color(0xFF86b649), size: 30);
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
        padding: const EdgeInsets.symmetric(
            horizontal: 0.0), // Adjust padding as needed
        child: Row(
          children: [
            Image.asset(
              'assets/images/nutrient.png', // Replace with your image asset
              width: 30, // Adjust the size as needed
              height: 30,
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            style: const TextStyle(fontSize: 16),
          ),
          trailing: Text(
            '${nutrient.values.first} g', // The nutrient value
            style: const TextStyle(fontSize: 16),
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
