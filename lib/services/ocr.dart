import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

ScreenshotController screenshotController = ScreenshotController();

// The method to process and recognize text from the screen
Future<String?> Ocr(String filePath) async {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final inputImage = InputImage.fromFilePath(filePath);
  final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);
  textRecognizer.close();

  return recognizedText.text;
}

const platform = MethodChannel('com.example.overlay/capture');

Future<void> takeScreenshot() async {
  try {
    // Call the native method to take the screenshot
    await platform.invokeMethod('captureScreenshot');
    print("hogya");
  } on PlatformException catch (e) {
    print("Failed to take screenshot: '${e.message}'.");
  }
}
