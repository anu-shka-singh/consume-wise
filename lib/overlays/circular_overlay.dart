import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/src/input_image.dart';
import 'package:overlay/overlays/error_overlay.dart';
import 'package:overlay/services/prompts.dart';
import 'package:path_provider/path_provider.dart';
import '../services/gemini.dart';
import '../services/ocr.dart';
import 'health_overlay.dart';
import 'package:http/http.dart' as http;

class LeafOverlay extends StatefulWidget {
  const LeafOverlay({super.key});

  @override
  State<LeafOverlay> createState() => _LeafOverlayState();
}

class _LeafOverlayState extends State<LeafOverlay> {
  //static const String _kPortNameOverlay = 'OVERLAY'; // Define port name
  String? detectedText = '';
  Map<String, dynamic> productInfo = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> searchProduct(String productName) async {
    int retryCount = 3; // Maximum number of retries in case of timeout
    Duration timeoutDuration = const Duration(seconds: 10); // Timeout duration

    setState(() {
      // isLoading = true;
      //something maybe a loading overlay
    });

    for (int retry = 0; retry < retryCount; retry++) {
      try {
        final url = Uri.parse(
            'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$productName&countries_tags_en=india&languages_tags_en=english&json=true&page=1&page_size=1');

        print("Searching product: $productName, attempt ${retry + 1}");

        final response = await http.get(url).timeout(timeoutDuration);

        if (response.statusCode == 200) {
          print("Search status-code: ${response.statusCode}");
          final data = json.decode(response.body);

          if (data['products'] != null && data['products'].isNotEmpty) {
            productInfo = data['products'][0]; // Get the first product

            break; // Exit retry loop if a product is found
          } else {
            print("No products found");
            break;
          }
        } else {
          print("Error fetching search result: ${response.statusCode}");
          break; // Stop further requests in case of non-200 status code
        }
      } on TimeoutException catch (e) {
        print("Request timed out, attempt ${retry + 1}: $e");

        if (retry == retryCount - 1) {
          print("Max retries reached. No product found.");
        }
      } catch (e) {
        print("An error occurred: $e");
        break;
      }
    }

    setState(() {
      // Save the first product details or update the UI as needed
      // isLoading = false;
    });
  }

  Future<InputImage> loadAssetImageForOCR() async {
    // Load the image from assets
    ByteData data = await rootBundle.load('assets/images/ss.jpg');

    // Get the temporary directory to store the image
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/ss.jpg';

    // Write the byte data to a file in the temporary directory
    File imageFile = File(filePath);
    await imageFile.writeAsBytes(data.buffer.asUint8List());

    // Now create an InputImage from the file path for OCR
    final inputImage = InputImage.fromFilePath(filePath);
    return inputImage;
  }

  Future<void> showReport() async {
    // capture screen
    // await takeScreenshot();
    final screenshot = await loadAssetImageForOCR();
    //Perform OCR and extract text
    final detectedText = await ocr(screenshot as InputImage);

    if (detectedText != null) {
      // send extracted text to gemini to get product name
      String productName = await identifyProductName(detectedText);

      // if response is none or multiple then display overlay accordingly
      if (productName == "None" || productName == "Multiple") {
        // Show the error Overlay
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                width: 370.0, // Set the width
                height: 70.0, // Set the height
                child: const ErrorOverlay(),
              ),
            );
          },
        );
      } else {
        // else do search in api to fetch product info
        await searchProduct(productName);

        if (productInfo.isEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                    width: 370.0, // Set the width
                    height: 70.0, // Set the height
                    child: const ErrorOverlay()),
              );
            },
          );
        }

        // get Health Analysis using gemini
        else {
          final response = await healthAnalysis(productInfo);
          final cleanResponse = getCleanResponse(response);
          if (cleanResponse.isNotEmpty) {
            final analysis = jsonDecode(cleanResponse);
            List<dynamic> positive = analysis['positive'];
            List<dynamic> negative = analysis['negative'];
            double rating = analysis['rating'];

            // Show the Health Analysis Overlay
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Container(
                    width: 370.0, // Set the width
                    height: 200.0, // Set the height
                    child: HealthOverlay(
                      rating: rating,
                      positive: positive,
                      negative: negative,
                    ),
                  ),
                );
              },
            );
          }

          // Close the existing overlay
          // final isActive = await FlutterOverlayWindow.isActive();
          // if (isActive) {
          //   await FlutterOverlayWindow.closeOverlay();
          // }
        }
      }
    } else {
      log("No text detected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: GestureDetector(
          onTap: () async {
            log('Leaf overlay tapped');
            showReport();
          },
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
                color: const Color(0xFF055b49),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
                image: const DecorationImage(
                    image: AssetImage('assets/images/overlay_logo.png'),
                    fit: BoxFit.cover)),
          ),
        ),
      ),
    );
  }

  // void show() async {
  //   bool isPermissionGranted = await FlutterOverlayWindow.isPermissionGranted();

  //   if (!isPermissionGranted) {
  //     await FlutterOverlayWindow.requestPermission();
  //   }

  //   await FlutterOverlayWindow.showOverlay(
  //     enableDrag: true,
  //     overlayContent: '',
  //   );
  // }

  // Future<void> captureScreenText() async {
  //   bool status =
  //       await FlutterAccessibilityService.isAccessibilityPermissionEnabled();

  //   /// request accessibility permission
  //   /// it will open the accessibility settings page and return `true` once the permission granted.
  //   status = await FlutterAccessibilityService.requestAccessibilityPermission();
  //   log("permission status : $status");

  //   StreamSubscription<AccessibilityEvent>? _subscription;
  //   List<AccessibilityEvent?> events = [];

  //   _subscription =
  //       FlutterAccessibilityService.accessStream.listen((event) async {
  //     setState(() {
  //       events.add(event);
  //       handleEvent(event);
  //     });
  //   });
  // }

  // void handleEvent(AccessibilityEvent event) {
  //   detectedText = event.text!;
  // }
}
