import 'package:flutter/material.dart';
import 'package:overlay/services/prompts.dart';

import 'calorie_counter_result.dart';
import 'loading_screen.dart';

void main() {
  runApp(const MaterialApp(
    home: CalorieCounterPage(
      height: '154 cm',
      weight: '45 kg',
    ),
  ));
}

class CalorieCounterPage extends StatefulWidget {
  final String height;
  final String weight;
  const CalorieCounterPage(
      {super.key, required this.height, required this.weight});

  @override
  _CalorieCounterPageState createState() => _CalorieCounterPageState();
}

class _CalorieCounterPageState extends State<CalorieCounterPage> {
  final TextEditingController _textController = TextEditingController();
  String userMeal = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF055b49), // Same color as the container
        elevation: 0, // Remove shadow
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 20.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF055b49),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      'Calorie Counter',
                      style: TextStyle(
                        fontSize: 28.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Heading
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'What did you eat today?',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sample answers
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Wrap(
                      spacing: 5.0,
                      runSpacing: 1.0,
                      children: [
                        Chip(
                          label: const Text(
                            '2 Rotis with some Shahi Paneer',
                            style: TextStyle(color: Colors.grey),
                          ),
                          deleteIcon: const Icon(Icons.add_circle,
                              color: Color(
                                  0xFF055b49)), // Use a plus icon instead of the cross
                          onDeleted: () {
                            setState(() {
                              _textController.text =
                                  '2 Rotis with some Shahi Paneer';
                            });
                          },
                        ),
                        Chip(
                          label: const Text(
                            '1 Bowl of Rice with 1 Bowl of Moong Dal',
                            style: TextStyle(color: Colors.grey),
                          ),
                          deleteIcon: const Icon(Icons.add_circle,
                              color: Color(
                                  0xFF055b49)), // Use a plus icon instead of the cross
                          onDeleted: () {
                            setState(() {
                              _textController.text =
                                  '1 Bowl of Rice with 1 Bowl of Moong Dal';
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Textbox for user input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      elevation: 2,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12.0), // Rounded corners
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Optional padding inside the card
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Enter the food you ate',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.fastfood,
                                color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none, // Remove the border
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 20.0,
                            ),
                          ),
                          style: const TextStyle(fontSize: 18.0),
                          maxLines:
                              null, // Allows the text to wrap and grow vertically
                          keyboardType: TextInputType
                              .multiline, // Allows multi-line input
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Submit button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_textController.text.trim().isEmpty) {
                          // If the text field is empty, show a SnackBar with a message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a meal'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          setState(() {
                            userMeal = _textController.text;
                          });

                          // Show the loading screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoadingScreen()),
                          );

                          // Call your API and wait for the response
                          var response = await calorieCalculator(
                              userMeal, widget.height, widget.weight);

                          // Once the response is received, pop the loading screen
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResultScreen(
                                      response: response,
                                    )),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF86b649),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 14.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded button
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Disclaimer as a footer
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFeaf2e1), // Lighter complementary color
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please note: The provided calorie count is an estimate. For more accurate results, include detailed descriptions of your meal along with portion sizes.',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFF6E7),
    );
  }
}
