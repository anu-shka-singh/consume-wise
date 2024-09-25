import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:overlay/overlays/error_overlay.dart';
import 'package:overlay/services/prompts.dart';
import '../services/gemini.dart';
import 'health_overlay.dart';

class LeafOverlay extends StatefulWidget {
  const LeafOverlay({super.key});

  @override
  State<LeafOverlay> createState() => _LeafOverlayState();
}

class _LeafOverlayState extends State<LeafOverlay> {
  static const String _kPortNameOverlay = 'OVERLAY'; // Define port name
  String? detectedText = '';

  void show() async {
    bool isPermissionGranted = await FlutterOverlayWindow.isPermissionGranted();

    if (!isPermissionGranted) {
      await FlutterOverlayWindow.requestPermission();
    }

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayContent: '',
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> captureScreenText() async {
    bool status =
        await FlutterAccessibilityService.isAccessibilityPermissionEnabled();

    /// request accessibility permission
    /// it will open the accessibility settings page and return `true` once the permission granted.
    status = await FlutterAccessibilityService.requestAccessibilityPermission();
    log("permission status : $status");

    StreamSubscription<AccessibilityEvent>? _subscription;
    List<AccessibilityEvent?> events = [];

    _subscription =
        FlutterAccessibilityService.accessStream.listen((event) async {
      setState(() {
        events.add(event);
        handleEvent(event);
      });
    });
  }

  void handleEvent(AccessibilityEvent event) {
    detectedText = event.text!;
  }

  Future<void> showReport() async {
    // capture screen
    // await takeScreenshot();
    //Perform OCR and extract text
    //final detectedText = await captureAndOcr();
    String detectedText = '''
      11:27
      < chocolate
      X
      Off
      munch
      Nestle Nestle Munch Chocolate 38.5 g
      Get for ₹17
      ₹18 ₹20
      Add to Cart
      2% Off
      Π
      Cadbury Dairy Milk, CHOCOLATE
      Cadbury Dairy Milk Chocolate Bar
      Z
      Add items worth 199 to get up to 20% off with pass
      Zepto
      00 Categories
      Cadbury
      Dairy Milk CHOCOLATE
      crackle
      Cadbury Dairy Milk Crackle Chocolate Bar 36 g
      Get for ₹44
      ₹45
      Add to Cart
      Cadbury Dairy Milk
      CHOCOLATE
      3
      Pieces
      Cadbury Dairy Milk Chocolate Combo
      Cart
      ''';

    if (detectedText != null) {
      // send extracted text to gemini to get product name
      Future<String> productName = identifyProductName(detectedText!);

      // if response is none or multiple then display overlay accordingly
      if (productName == "None" || productName == "Multiple") {
        // Show the error Overlay
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                width: 370.0, // Set the width
                height: 270.0, // Set the height
                child: const ErrorOverlay(),
              ),
            );
          },
        );
      } else {
        // else do search in api to fetch product info
        Map<String, dynamic> productInfo = {}; //search(productName);

        // get Health Analysis using gemini
        final response = await healthAnalysis(productInfo);
        final cleanResponse = getCleanResponse(response);
        if (cleanResponse.isNotEmpty) {
          final analysis = jsonDecode(cleanResponse);
          List<String> positive = analysis['positive'];
          List<String> negative = analysis['negative'];
          String rating = analysis['rating'];

          // Show the Health Analysis Overlay
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                  width: 370.0, // Set the width
                  height: 270.0, // Set the height
                  child: HealthOverlay(
                    rating: rating,
                    positive: positive,
                    negative: negative,
                  ),
                ),
              );
            },
          );

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
            ),
            child: const Center(
              child: Icon(
                Icons.energy_savings_leaf,
                color: Colors.white,
                size: 50.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
