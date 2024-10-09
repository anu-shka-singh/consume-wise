import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Screenshot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ScreenshotScreen(),
    );
  }
}

class ScreenshotScreen extends StatefulWidget {
  const ScreenshotScreen({Key? key}) : super(key: key);

  @override
  _ScreenshotScreenState createState() => _ScreenshotScreenState();
}

class _ScreenshotScreenState extends State<ScreenshotScreen> {
  static const platform = MethodChannel('com.example.screenshot/capture');
  String detectedText = '';
  Future<void> _takeScreenshot() async {
    try {
      await platform.invokeMethod('captureScreenshot');
    } on PlatformException catch (e) {
      print("Failed to take screenshot: '${e.message}'.");
    }
  }

  // Function to handle the detected text from the platform
  void _handleDetectedText(String text) {
    setState(() {
      detectedText = text; // Update the state with the detected text
    });
  }

  @override
  void initState() {
    super.initState();

    // Listen for method calls from the native side
    platform.setMethodCallHandler((call) async {
      if (call.method == "onTextDetected") {
        _handleDetectedText(call.arguments); // Call to handle detected text
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Screenshot'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _takeScreenshot,
              child: const Text('Take Screenshot'),
            ),
            const SizedBox(height: 20),
            Text(
              detectedText.isEmpty ? 'No text detected yet.' : 'Detected Text:\n$detectedText',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}