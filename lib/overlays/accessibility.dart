import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String?> captureTextFromScreenshot() async {
  bool isServiceEnabled =
      await FlutterAccessibilityService.isAccessibilityPermissionEnabled();

  if (!isServiceEnabled) {
    await FlutterAccessibilityService.requestAccessibilityPermission();
    log("given accessibility permission");
  }
  await FlutterAccessibilityService.performGlobalAction(
      GlobalAction.globalActionTakeScreenshot);
  await Future.delayed(const Duration(milliseconds: 500));

  PermissionStatus status = await Permission.storage.request();
  if (status.isGranted) {
    log("storage permission granted");
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      log('No image selected.');
      return null;
    }

    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String extractedText = recognizedText.text;

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
