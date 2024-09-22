import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRButtonOverlay extends StatefulWidget {
  @override
  _OCRButtonOverlayState createState() => _OCRButtonOverlayState();
}

class _OCRButtonOverlayState extends State<OCRButtonOverlay> {
  static const platform = MethodChannel('com.example.yourapp/screenshot');
  String detectedText = "";

  Future<void> captureScreenshotAndOCR() async {
    try {
      // Invoke the platform channel to take a screenshot
      final Uint8List screenshotBytes =
          await platform.invokeMethod('takeScreenshot');

      // Convert the screenshot bytes into an InputImage for OCR
      final inputImage = InputImage.fromBytes(
          bytes: screenshotBytes,
          metadata: InputImageMetadata(
              size: Size(1080, 1920),
              rotation: InputImageRotation.rotation0deg,
              format: InputImageFormat.nv21,
              bytesPerRow: 1080));

      // Use Google ML Kit's text recognizer to process the image
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      print(recognizedText.text);

      setState(() {
        detectedText = recognizedText.text;
      });

      await textRecognizer.close();
    } catch (e) {
      print("Failed to capture screenshot and perform OCR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your overlay button
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: captureScreenshotAndOCR,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(15),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          // Display detected text
          if (detectedText.isNotEmpty)
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.black.withOpacity(0.7),
                child: Text(
                  detectedText,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Overlay App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('OCR Button Overlay'),
        ),
        body: OCRButtonOverlay(),
      ),
    );
  }
}
