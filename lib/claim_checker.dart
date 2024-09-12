import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: ClaimCheckerPage(
      product: const {
        'name': 'bornvita',
        'ingridients': [
          'Cereal extract (51%*)',
          'Sugar',
          'Cocoa Solids',
          'Milk Solids',
          'Liquid Glucose',
          'Emulsifiers (322 , 471)',
          'Raising agent (500(ii))',
          'Vitamins',
          'Minerals',
          'Salt'
        ]
      },
    ),
  ));
}

class ClaimCheckerPage extends StatefulWidget {
  final Map<String, dynamic> product;
  ClaimCheckerPage({super.key, required this.product});
  @override
  _ClaimCheckerPageState createState() => _ClaimCheckerPageState();
}

class _ClaimCheckerPageState extends State<ClaimCheckerPage> {
  final TextEditingController claimController = TextEditingController();
  ClaimResult? result; // Assume ClaimResult is a model for the analysis result

  Future<void> analyzeClaim(String claim) async {
    const String apiUrl =
        'https://cwbackend-a3332a655e1f.herokuapp.com/claims/analyze';

    // Construct the query parameters
    Map<String, String> queryParams = {
      'ingredients': widget.product['ingridients'].join(', '),
      'claim': claim
    };

    // Append the query parameters to the base URL
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // If the server returns a response, parse the JSON
        final data = json.decode(response.body);
        print('Response data: $data');
        setState(() {
          print('hello');
          result = ClaimResult(
            verdict: data['verdict'],
            why: data['why'],
            details: data['detailed_analysis'],
          );
        });
      } else {
        // If the server did not return a 200 OK response, throw an error
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF055b49),
          elevation: 0,
        ),
        backgroundColor: const Color(0xFFFFF6E7),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF055b49),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Claim Checker : Uncover the Truth!',
                  style: TextStyle(
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Image.asset(
                  "assets/images/claim_checker.gif",
                  height: 250,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // Padding around the text
                child: Text(
                  'Enter the claim you want to check:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
              ),
              const SizedBox(height: 20.0), // Adjusted spacing

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // Padding around the text
                child: TextField(
                  controller: claimController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'E.g., "Contains 20% protein"',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF055b49), width: 2.0),
                    ),
                  ),
                  maxLines: 3,
                ),
              ),

              const SizedBox(height: 30.0), // Adjusted spacing

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    analyzeClaim(claimController.text);
                  },
                  child: Text(
                    'Check Claim',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF055b49),
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              if (result != null) ...[
                SizedBox(
                    height: 24.0), // Added spacing before the result section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Claim Analysis Result:',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(height: 12.0),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 24),
                            Icon(Icons.star, color: Colors.yellow, size: 24),
                            Icon(Icons.star, color: Colors.yellow, size: 24),
                            Icon(Icons.star_half,
                                color: Colors.yellow, size: 24),
                            Icon(Icons.star_border,
                                color: Colors.yellow, size: 24),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          result!.verdict,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text(result!.why),
                        Text(result!.details),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        )));
  }
}

class ClaimResult {
  final String verdict;
  final String why;
  final String details;

  ClaimResult({
    required this.verdict,
    required this.why,
    required this.details,
  });
}
