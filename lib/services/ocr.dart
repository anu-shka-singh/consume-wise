import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path/path.dart';

import 'prompts.dart'; // For file path utilities

import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (await Permission.storage.request().isGranted) {
    // Permission is granted, continue with the screenshot
    print("Storage permission granted");
  } else {
    // Permission is not granted, handle the situation
    print("Storage permission denied");
  }
}

ScreenshotController screenshotController = ScreenshotController();

// The method to process and recognize text from the screen
Future<String?> captureAndOcr() async {
  await requestPermissions();

  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  String? filePath = await NativeScreenshot.takeScreenshot();

  if (filePath != null) {
    print("hogya");
    final inputImage = InputImage.fromFilePath(filePath);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    textRecognizer.close();

    return recognizedText.text;
  }
  return "";
}
