import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const ScreenshotScreen({super.key});

  @override
  _ScreenshotScreenState createState() => _ScreenshotScreenState();
}

class _ScreenshotScreenState extends State<ScreenshotScreen> {
  static const platform = MethodChannel('com.example.overlay/capture');

  Future<void> takeScreenshot() async {
    try {
      // Call the native method to take the screenshot
      await platform.invokeMethod('captureScreenshot');
      print("hogya");
    } on PlatformException catch (e) {
      print("Failed to take screenshot: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Screenshot'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: takeScreenshot,
          child: const Text('Take Screenshot'),
        ),
      ),
    );
  }
}
