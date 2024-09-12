import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay/image_upload.dart';

class HealthAnalysis extends StatefulWidget {
  const HealthAnalysis({super.key});

  @override
  State<HealthAnalysis> createState() => _HealthAnalysisState();
}

class _HealthAnalysisState extends State<HealthAnalysis> {
  List<bool> _isExpanded = [false, false, false];
  late ScrollController? _scrollController;
  late Timer? _timer;
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAutoScroll(); // Start auto-scrolling after the first frame
    });
    _panelExpanded = List.generate(ingredients.length, (index) => false);
  }

  void startAutoScroll() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_scrollController != null && _scrollController!.hasClients) {
        double maxScrollExtent = _scrollController!.position.maxScrollExtent;
        double currentScroll = _scrollController!.position.pixels;

        if (currentScroll < maxScrollExtent) {
          _scrollController!.animateTo(
            currentScroll + 2.0, // Speed of the scroll
            duration: Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        } else {
          _scrollController!.jumpTo(0); // Restart scrolling
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
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
      body: Container(
        color: Color(0xFFFFF6E7),
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
                padding: const EdgeInsets.only(
                    top: 0, left: 16, right: 16, bottom: 16),
                child: const Text(
                  "Health Analysis",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                elevation: 4,
                color: Color.fromARGB(147, 255, 196, 0),
                margin: const EdgeInsets.all(14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/kit-kat.png',
                            width: 120, // Adjust the width as needed
                            height: 100, // Adjust the height as needed
                          ),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Kit-Kat",
                                    style: TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 30, 30, 30)),
                                  ),
                                  const Text(
                                    "By: Nestle",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 63, 81, 90)),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      // const Divider(
                      //   color: Color.fromARGB(255, 70, 84, 14),
                      //   thickness: 2,
                      // ),
                      Container(
                        width: double
                            .infinity, // Ensure it takes the full width of the card
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 143, 28, 19),
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        // Red color for the band
                        padding: EdgeInsets.symmetric(
                            vertical: 5), // Padding for the text
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Ultra Processed Food", // Your text here
                              textAlign: TextAlign.center, // Center the text
                              style: TextStyle(
                                color: Colors.white, // White color for the text
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Column(
                            children: [
                              Text(
                                "Health",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                "Rating",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          buildHealthRatingWidget(5),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
              //nutritional information
              Card(
                elevation: 4,
                color: Color(0xFFB0E0E6),
                margin: const EdgeInsets.all(14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Nutritional Information",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      StatefulBuilder(builder: (context, state) {
                        return Card(
                          color: Color(0xFFF0F8FF),
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
                              expandIconColor: Colors.blueGrey,
                              expansionCallback: (int index, bool isExpanded) {
                                setState(() {
                                  _isExpanded[index] = !_isExpanded[index];
                                });
                              },
                              children: [
                                _buildPanel(
                                    0,
                                    "Calories",
                                    [
                                      {"Item 1": 10},
                                      {"Item 2": 10},
                                      {"Item 3": 10}
                                    ],
                                    _isExpanded,
                                    setState),
                                _buildPanel(
                                    1,
                                    "Macronutrients",
                                    [
                                      {"Carbohydrates": 7.23},
                                      {"Protien": 0.0},
                                      {"Fats": 9.77}
                                    ],
                                    _isExpanded,
                                    setState),
                                _buildPanel(
                                    2,
                                    "Micronutrients",
                                    [
                                      {"Item 1": 10},
                                      {"Item 2": 10},
                                      {"Item 3": 10}
                                    ],
                                    _isExpanded,
                                    setState),
                              ],
                            ),
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),
              // horizontally scrolling keywords
              Container(
                height: 40, // Adjust height as needed
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: keywords.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(
                              0xFF9BCC9E), // Complementary background color for the box
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
                                  Color.fromARGB(255, 27, 67, 53), // Text color
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ingredients card
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              true, // Can close by tapping outside
                          builder: (BuildContext context) {
                            return BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: 5, sigmaY: 5), // Blurred backdrop
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return Dialog(
                                    backgroundColor:
                                        Color.fromARGB(255, 213, 154, 239),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.6, // Maximum height (60% of screen height)
                                        minWidth:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                                height: 10), // Space at the top
                                            ...ingredients
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int index = entry.key;
                                              Map<String, dynamic> ingredient =
                                                  entry.value;

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 16),
                                                child: ExpansionPanelList(
                                                  elevation: 1,
                                                  expandedHeaderPadding:
                                                      EdgeInsets.all(0),
                                                  expansionCallback:
                                                      (int panelIndex,
                                                          bool isExpanded) {
                                                    setState(() {
                                                      _panelExpanded[index] =
                                                          !_panelExpanded[
                                                              index];
                                                    });
                                                  },
                                                  children: [
                                                    ExpansionPanel(
                                                      headerBuilder:
                                                          (BuildContext context,
                                                              bool isExpanded) {
                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    16),
                                                          ),
                                                          child: ListTile(
                                                            title: Text(
                                                              '${ingredient['name']}',
                                                              style: TextStyle(
                                                                fontSize: 30,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      body: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .vertical(
                                                          bottom:
                                                              Radius.circular(
                                                                  16),
                                                        ),
                                                        child: Container(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16.0),
                                                            child: Text(
                                                              '${ingredient['description']}',
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      isExpanded:
                                                          _panelExpanded[index],
                                                      canTapOnHeader: true,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      child: Card(
                        elevation: 4,
                        color: Color.fromARGB(255, 47, 12, 78),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: EdgeInsets.only(left: 4, right: 4),
                        child: const Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.list_alt,
                                size: 50,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Ingredients',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 10,
                  ),
                  // Serving Tips
                  Stack(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 5, sigmaY: 5), // Blurred backdrop
                                  child: DraggableScrollableSheet(
                                    initialChildSize:
                                        0.6, // Start with 60% height
                                    minChildSize: 0.3, // Minimum height (30%)
                                    maxChildSize: 1.0, // Maximum height (100%)
                                    builder: (BuildContext context,
                                        ScrollController scrollController) {
                                      return Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                        ),
                                        child: SingleChildScrollView(
                                          controller:
                                              scrollController, // Use the ScrollController
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Chocolates', // product tag
                                                style: TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              // Build list items from the provided items
                                              ...facts.map((fact) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    //crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '${fact['name']}: ',
                                                        style: TextStyle(
                                                          fontSize: 40,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        '${fact['description']}',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      const Divider(
                                                        color: Colors.black,
                                                        height: 50,
                                                        indent: 60,
                                                        endIndent: 60,
                                                        thickness: 2,
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                              SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: Card(
                            elevation: 4,
                            color: Color.fromARGB(255, 92, 21, 57),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.restaurant,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Serving Tips',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // claim analysis
              Card(
                elevation: 4,
                color: Color.fromARGB(255, 216, 255, 165),
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
                                      color: Color(0xFF055b49)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageUpload(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Text(
                              "Know the truth of product claims",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
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

              //SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
                child: Text(
                  "Better Options",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 14, 86, 62),
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
            ],
          ),
        ),
      ),
    );
  }
}

Card buildHealthRatingWidget(int rating) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    color: Colors.white, // Keep the background light for contrast
    child: Container(
      width: 90, // Square-like dimensions
      height: 100,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$rating',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Dark color for clear visibility
                ),
              ),
              Icon(
                Icons.star, // Adding an icon to make it more visually appealing
                color: Colors.orangeAccent,
                size: 24,
              ),
            ],
          ),
          Text(
            'out of 10',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700], // Subtle text color for 'out of 10'
            ),
          ),
        ],
      ),
    ),
  );
}

ExpansionPanel _buildPanel(
    int index,
    String headerText,
    List<Map<String, double>> items,
    List<bool> isExpanded,
    void Function(void Function()) setState) {
  return ExpansionPanel(
    headerBuilder: (BuildContext context, bool isExpanded) {
      return ListTile(
        title: Text(
          headerText,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    },
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.expand((item) {
          // Each 'item' is a Map<String, double>
          return item.entries.map((entry) {
            // Extract key and value from the Map
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                  title: Text(
                    '${entry.key}', // Key as title
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    '${entry.value}g', // Value as trailing
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  // You can add other properties or widgets here in the future
                ),
                Divider(
                  indent: 40,
                  endIndent: 40,
                  color: Colors.blueGrey,
                ), // Add a divider between rows
              ],
            );
          }).toList();
        }).toList(),
      ),
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
