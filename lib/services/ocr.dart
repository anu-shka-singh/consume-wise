import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path/path.dart'; // For file path utilities

ScreenshotController screenshotController = ScreenshotController();

// Function to capture the screen and save it to a temporary file
Future<InputImage> getInputImageFromScreen() async {
  try {
    // Capture the screen as Uint8List (in-memory image)
    final Uint8List? imageBytes = await screenshotController.capture();

    if (imageBytes != null) {
      // Get the temporary directory to store the screenshot
      final Directory tempDir = await getTemporaryDirectory();

      // Create a file path for the image
      String filePath = join(tempDir.path, 'screenshot.png');

      // Write the screenshot to the file
      File imageFile = File(filePath);
      await imageFile.writeAsBytes(imageBytes);

      // Convert the file to an InputImage for Google ML Kit
      final inputImage = InputImage.fromFilePath(filePath);
      return inputImage;
    } else {
      throw Exception("Failed to capture screen");
    }
  } catch (e) {
    throw Exception("Error capturing or saving image: $e");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String detectedText = "Tap the button to detect text";

  Future<void> _detectText() async {
    try {
      final text = await readTextFromScreen();
      setState(() {
        detectedText = text ?? "No text detected";
      });
    } catch (e) {
      setState(() {
        detectedText = "Error detecting text: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Text Recognition Overlay'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(detectedText),
              ElevatedButton(
                onPressed: _detectText,
                child: const Text('Capture Screen & Detect Text'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The method to process and recognize text from the screen
Future<String?> readTextFromScreen() async {
  final textRecognizer = GoogleMlKit.vision.textRecognizer();

  // Capture screenshot and convert it to InputImage
  InputImage inputImage = await getInputImageFromScreen();

  final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

  String productName = '';

  // Iterate over the recognized blocks and lines to extract text
  for (TextBlock block in recognizedText.blocks) {
    for (TextLine line in block.lines) {
      productName = line.text; // Get the first recognized text (can be refined)
      break;
    }
    break;
  }

  textRecognizer.close();
  return productName;
}
