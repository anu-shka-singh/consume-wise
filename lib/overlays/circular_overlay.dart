import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../services/ocr.dart';

class LeafOverlay extends StatefulWidget {
  const LeafOverlay({Key? key}) : super(key: key);

  @override
  State<LeafOverlay> createState() => _LeafOverlayState();
}

class _LeafOverlayState extends State<LeafOverlay> {
  static const String _kPortNameOverlay = 'OVERLAY'; // Define port name

  @override
  void initState() {
    super.initState();
  }

  Future<void> _performOcrAndShowOverlay() async {
    try {
      // Perform OCR
      final detectedText = await readTextFromScreen();

      if (detectedText != null) {
        // Close any existing overlay
        final isActive = await FlutterOverlayWindow.isActive();
        if (isActive) {
          await FlutterOverlayWindow.closeOverlay();
        }

        // Show the TrueCallerOverlay
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: 'TrueCaller Overlay',
          overlayContent: '',
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.auto,
          height: (MediaQuery.of(context).size.height * 0.6).toInt(),
          width: (MediaQuery.of(context).size.width * 0.8).toInt(),
          startPosition: const OverlayPosition(0, 0),
        );

        // Send detected text to overlay
        IsolateNameServer.lookupPortByName(_kPortNameOverlay)
            ?.send(detectedText);
      } else {
        log("No text detected");
      }
    } catch (e) {
      log("Error performing OCR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: GestureDetector(
          onTap: () {
            log('Leaf overlay tapped');
            _performOcrAndShowOverlay();
          },
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Center(
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
