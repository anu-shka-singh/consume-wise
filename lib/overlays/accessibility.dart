import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
//String? capturedText;

// Future<String?> captureText() async {
//   // Check if accessibility service is enabled
//   bool isServiceEnabled = await FlutterAccessibilityService.isAccessibilityPermissionEnabled();

//   if (!isServiceEnabled) {
//     FlutterAccessibilityService.requestAccessibilityPermission();
//   }

//   // Perform the global action to take a screenshot
//   await FlutterAccessibilityService.performGlobalAction(GlobalAction.globalActionTakeScreenshot);

//   // Get the window content
//   String capturedText = await FlutterAccessibilityService.getTextContent();

//   if (capturedText.isNotEmpty) {
//     print("Captured Text: $capturedText");
//     return capturedText;
//   } else {
//     print("No text found on the screen");
//     return null;
//   }
// }

Future<String?> captureTextFromScreenshot() async {
  // Ensure the accessibility service is enabled
  bool isServiceEnabled =
      await FlutterAccessibilityService.isAccessibilityPermissionEnabled();

  if (!isServiceEnabled) {
    await FlutterAccessibilityService.requestAccessibilityPermission();
    log("given accessibility permission");
  }

  // Perform the global action to take a screenshot
  await FlutterAccessibilityService.performGlobalAction(
      GlobalAction.globalActionTakeScreenshot);

  // Add a slight delay to ensure UI is ready for image picker
  await Future.delayed(const Duration(milliseconds: 500));

  PermissionStatus status = await Permission.storage.request();

  // Pick the screenshot image from the device storage
  // final XFile? image;
  if (status.isGranted) {
    log("storage permission granted");
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      log('No image selected.');
      return null;
    }

    // Perform OCR on the captured image
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    // Extract text from the image
    String extractedText = recognizedText.text;

    // Close the text recognizer
    textRecognizer.close();

    if (extractedText.isNotEmpty) {
      log("Extracted Text: $extractedText");
      return extractedText;
    } else {
      log("No text found in the screenshot.");
      return null;
    }
  }
}

Future<String?> captureTextWithInitialization() async {
  String? extractedText;
  log("inside first function");
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    extractedText = await captureTextFromScreenshot();
    log("second function executed");
  });
  return extractedText;
}
