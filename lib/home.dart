import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
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
                  builder: (context) => MainScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:
      Container(
        color: Color(0xFFFFF6E7),
          child:
            SingleChildScrollView(
              //padding: EdgeInsets.all(16.0),
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
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            // Border radius of 10
                            color: Colors
                                .grey[100],
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Search for products...',
                              prefixIcon: Icon(Icons.search, color: Color(
                                  0xFF055b49)), // Optional: change icon color
                              border: InputBorder.none, // No border
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12), // Adjust padding
                            ),
                            style: TextStyle(
                              color: Colors.blueGrey, // Change text color
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,)
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
                            height: 120, // Adjust the height as needed
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Scan the product",
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
                                          builder: (context) => MainScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Know the nutritional value of \nyour product",
                                style:
                                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                            ],
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
                            color: Color(0xFF055b49), // You can customize this color
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // List for Popular Products
                  SizedBox(
                    height: 170,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0,),
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
                                  },
                                  child: Text(
                                    'Let\'s Go',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF86b649), // Button background color
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 28.0), // Button padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30), // Rounded corners
                                    ),
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

                  const SizedBox(height: 20,)
                ],
              ),
            ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
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
            child:
            Container(
              height: 100,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.fitHeight
                ),
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
}
