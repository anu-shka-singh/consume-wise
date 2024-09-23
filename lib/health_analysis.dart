import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:overlay/claim_checker.dart';
import 'package:overlay/loading_screen.dart';
import 'package:overlay/services/gemini.dart';
import 'package:overlay/services/prompts.dart';

//
// void main() {
//   final product = {
//     'name': 'Maggi',
//     'company': 'Nestle',
//     'ingredients': [
//       "Wheat flour (atta) (85.3%)",
//       "Palm oil",
//       "Iodised salt",
//       "Thickeners (508, 412)",
//       "Humectants (451(1), 452(i))",
//       "Acidity regulators (501(i), 500(i))",
//       "Mixed spices (22.5%)",
//       "Roasted spice mix powder (6.6%) (Coriander, Turmeric, Cumin, Aniseed, Black pepper, Fenugreek, Ginger, Green cardamom, Cinnamon, Clove, Nutmeg, Bay leaf & Black cardamom)",
//       "Onion powder",
//       "Garlic powder",
//       "Red chilli powder",
//       "Red chilli bib",
//       "Coriander powder",
//       "Turmeric powder",
//       "Ginger powder",
//       "Aniseed powder",
//       "Black pepper powder",
//       "Cumin powder",
//       "Cumin",
//       "Fenugreek powder",
//       "Capsicum extract",
//       "Compounded asafoetida",
//       "Star anise powder",
//       "Coriander extract",
//       "Cumin extract",
//       "Dehydrated Vegetables (16.7%)",
//       "Carrot bits (8.5%)",
//       "Green peas (8.2%)",
//       "Toasted onion flakes (Onion (12.4%) & Corn oil)",
//       "Refined wheat flour (Maida)",
//       "Sugar",
//       "Iodised salt",
//       "Toasted onion powder (Onion (5.9%) & Corn oil)",
//       "Thickener (508)",
//       "Palm oil",
//       "Flavour enhancer (635)",
//       "Yeast extract powder",
//       "Dehydrated kasuri methi leaves",
//       "Starch",
//       "Acidity regulator (330)",
//       "Mineral",
//       "Wheat gluten",
//       "Contains Wheat",
//       "May contain Milk, Oats, and Soy"
//     ],
//     'calories': '15kcal',
//     'sugar': '20g',
//   };
//   runApp(MaterialApp(
//     home: HealthAnalysis(
//       product: product,
//     ),
//   ));
// }

class HealthAnalysis extends StatefulWidget {
  final Map<String, dynamic> product;
  const HealthAnalysis({super.key, required this.product});

  @override
  State<HealthAnalysis> createState() => _HealthAnalysisState();
}

class _HealthAnalysisState extends State<HealthAnalysis> {
  final List<bool> _isExpanded = [false, false];
  late List<Map<String, dynamic>> ingredients = [];
  Map<String, dynamic> nutriments = {};
  late Map<String, dynamic> analysis;
  late double servingSize;
  bool isLoading = false;
  late List<String> allergies = [];
  late ScrollController? _scrollController1;
  late ScrollController? _scrollController2;
  late Timer? _timer;

  //late List<bool> _panelExpanded;

  Map<String, String> allergyIcons = {
    "peanuts": "assets/images/peanuts.png",
    "eggs": "assets/images/egg.png",
    "wheat": "assets/images/wheat.png",
    "soybeans": "assets/images/soy.png",
    "milk": "assets/images/milk.png",
    "fish": "assets/images/fish.png",
    "tree nuts": "assets/images/treenut.png",
    "sesame seeds": "assets/images/sesame.png",
    "gluten": "assets/images/wheat.png",
    "Other": "assets/images/others.png"
  };

  @override
  void initState() {
    super.initState();
    isLoading = true;
    performHealthAnalysis();
    if (widget.product['ingredients'] != null) {
      ingredients =
          List<Map<String, dynamic>>.from(widget.product['ingredients']);
    }
    if (widget.product['nutriments'] != null) {
      nutriments = Map<String, dynamic>.from(widget.product['nutriments']);
    }

    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAutoScroll(_scrollController1);
      startAutoScroll(_scrollController2);
    });
    // _panelExpanded = List.generate(ingredients.length, (index) => false);
  }

  Future<void> performHealthAnalysis() async {
    final String response = await healthAnalysis(widget.product);
    final cleanResponse = getCleanResponse(response);
    if (cleanResponse.isNotEmpty) {
      setState(() {
        analysis = jsonDecode(cleanResponse);
        isLoading = false;
        servingSize = analysis['portion_size_grams'];
        allergies = List<String>.from(analysis['allergens']);
      });
    }
  }

  void startAutoScroll(ScrollController? scrollController) {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (scrollController != null && scrollController.hasClients) {
        double maxScrollExtent = scrollController.position.maxScrollExtent;
        double currentScroll = scrollController.position.pixels;

        if (currentScroll < maxScrollExtent) {
          scrollController.animateTo(
            currentScroll + 2.0, // Speed of the scroll
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        } else {
          scrollController.jumpTo(0); // Restart scrolling
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController1?.dispose();
    _scrollController2?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF055b49),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const LoadingScreen()
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
                                    fontSize: 30,
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
                                buildHealthRatingWidget(analysis['rating']
                                    .toDouble()), // Replace 4.5 with dynamic rating value
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Horizontally scrolling keywords, only show if there are positives
                    if (analysis['positive'] != null &&
                        analysis['positive'].isNotEmpty)
                      Container(
                        height: 40, // Adjust height as needed
                        child: ListView.builder(
                          controller: _scrollController1,
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
                                      offset:
                                          const Offset(0, 2), // Offset shadow
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
                      )
                    else
                      const SizedBox
                          .shrink(), // Return an empty widget if there are no positives

                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 40, // Adjust height as needed
                      child: ListView.builder(
                        controller: _scrollController2,
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

                    // Allergy Info
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
                          child: allergies.isNotEmpty
                              ? Wrap(
                                  spacing: 20.0,
                                  runSpacing: 16.0,
                                  children: allergies.map((allergy) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          allergyIcons.containsKey(
                                                  allergy.toLowerCase())
                                              ? allergyIcons[
                                                  allergy.toLowerCase()]!
                                              : allergyIcons['Other']!,
                                          width: 50,
                                          height: 50,
                                        ),
                                        const SizedBox(height: 8.0),
                                        // Display the allergy name
                                        Text(
                                          allergy,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF555555),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                )
                              : const Padding(
                                  padding: EdgeInsets.only(top: 0.0),
                                  child: Text(
                                    'No allergy warnings.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF555555),
                                    ),
                                  ),
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

                            Text(
                              "per ${analysis['portion_size']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                              height: 20,
                              indent: 16,
                              endIndent: 16,
                            ),
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
                                  const SizedBox(width: 15),
                                  const Text(
                                    'Energy:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    '${calculateNutrientForPortion(nutriments['energy-kcal'] ?? 0, servingSize)} kcal',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 5),

                            // // Cholestrol Section (Non-Collapsible)
                            // Container(
                            //   padding: const EdgeInsets.all(10),
                            //   decoration: BoxDecoration(
                            //     color: const Color.fromARGB(255, 255, 255, 255),
                            //     borderRadius: BorderRadius.circular(16),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Image.asset(
                            //         'assets/images/fat.png', // Use your image asset
                            //         width: 30, // Adjust the size as needed
                            //         height: 30,
                            //       ),
                            //       const SizedBox(width: 15),
                            //       const Text(
                            //         'Cholesterol:',
                            //         style: TextStyle(
                            //           fontSize: 18,
                            //           fontWeight: FontWeight.bold,
                            //           color: Color(0xFF2C2C2C),
                            //         ),
                            //       ),
                            //       const SizedBox(width: 20),
                            //       Text(
                            //         '${calculateNutrientForPortion(nutriments['cholesterol'] ?? 0, servingSize)} g',
                            //         style: const TextStyle(
                            //           fontSize: 18,
                            //           color: Color(0xFF2C2C2C),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            //
                            // const SizedBox(height: 5),

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
                                    '${calculateNutrientForPortion(nutriments['sugars'] ?? 0, servingSize)} g',
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
                                                  //nutriments['carbohydrates'] ?? 0,
                                                  calculateNutrientForPortion(
                                                      nutriments[
                                                              'carbohydrates'] ??
                                                          0,
                                                      servingSize),
                                              "image": 'assets/images/bread.png'
                                            },
                                            {
                                              "Protein":
                                                  calculateNutrientForPortion(
                                                      nutriments['proteins'] ??
                                                          0,
                                                      servingSize),
                                              "image": 'assets/images/salad.png'
                                            },
                                            {
                                              "Fats":
                                                  calculateNutrientForPortion(
                                                      nutriments['fat'] ?? 0,
                                                      servingSize),
                                              "image": 'assets/images/fats.png'
                                            },
                                            {
                                              "Fibers":
                                                  calculateNutrientForPortion(
                                                      nutriments['fiber'] ?? 0,
                                                      servingSize),
                                              "image": 'assets/images/fiber.png'
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

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Card Widget
                          Card(
                            color: Colors.white,
                            elevation: 4, // Shadow depth of the card
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  16.0), // Internal padding for content
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Better Products', // The heading
                                    style: TextStyle(
                                      fontSize:
                                          24, // Larger font size for the heading
                                      fontWeight: FontWeight
                                          .bold, // Make the heading bold
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                    color: Colors.grey[300],
                                    height: 20,
                                    indent: 5,
                                    endIndent: 2,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: analysis['recommendations']
                                        .map<Widget>((product) {
                                      return BulletPoint(text: product);
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

String calculateNutrientForPortion(
    dynamic nutrientValuePer100g, double portionSize) {
  //print(nutrientValuePer100g);
  //print(nutrientValuePer100g.runtimeType);
  double nutrient = parseDouble(nutrientValuePer100g);
  return ((nutrient / 100) * portionSize).toStringAsFixed(1);
}

double parseDouble(dynamic value, {double fallback = 0.0}) {
  if (value is String) {
    double? x = double.tryParse(value);
    return x ?? fallback;
  } else if (value is double) {
    return value;
  } else if (value is int) {
    return value.toDouble();
  }
  return fallback;
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Add spacing between items
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align the icon and text properly
        children: <Widget>[
          const Icon(
            Icons.arrow_circle_right_outlined,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 8), // Spacing between icon and text
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
