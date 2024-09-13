import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:overlay/health_analysis.dart';
import 'package:overlay/home.dart';

class ImageUpload extends StatefulWidget {
  const ImageUpload({super.key});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  String? barcode;
  bool isScanned = false;
  MobileScannerController cameraController = MobileScannerController();
  BarcodeCapture? lastCapture; // Store the captured image for display

  // Function to scan barcode
  void scanBarcode(BarcodeCapture capture) {
    //print("barcode:"+barcode!);
    if (!isScanned) {
      setState(() {
        barcode = capture.barcodes.isNotEmpty
            ? capture.barcodes.first.rawValue
            : null;
        isScanned = barcode != null;
        // lastCapture = capture;
      });

      // Stop scanning further after first successful scan
      if (isScanned) {
        lastCapture = capture;
        print("Scanned Image Data: ${lastCapture!.image}");

        // cameraController.stop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF055b49),
          foregroundColor: Colors.white,
          elevation: 0,
          //automaticallyImplyLeading: false,
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.arrow_back_ios),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => MainScreen(),
          //         ),
          //       );
          //     },
          //   ),
          // ],
        ),
        body: Container(
          color: const Color(0xFFFFF6E7),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF055b49),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      top: 0, left: 16, right: 16, bottom: 16),
                  child: const Text(
                    "Scan & Find",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 50, right: 50, top: 20, bottom: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color inside the box
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                      border: Border.all(
                          color: const Color(0xFF055b49), // Border color
                          width: 3, // Border width
                          strokeAlign: BorderSide.strokeAlignOutside),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF055b49)
                              .withOpacity(0.5), // Shadow color
                          spreadRadius: 2, // Spread the shadow
                          blurRadius: 8, // Blur effect
                          offset:
                              const Offset(0, 3), // Position of shadow (x, y)
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF055b49).withOpacity(0.2),
                          Colors.white
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: isScanned &&
                                lastCapture != null &&
                                lastCapture!.image != null
                            ? Image.memory(
                                lastCapture!
                                    .image!, // Display the captured image
                                fit: BoxFit.cover,
                              )
                            : MobileScanner(
                                controller: cameraController,
                                //allowDuplicates: false,
                                onDetect: scanBarcode,
                              ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF055b49),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    //scanBarcode(await cameraController.barcodes.first);

                    if (isScanned) {
                      cameraController.stop();
                      print('Barcode Captured: $barcode');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please scan a barcode first')),
                      );
                    }
                  },
                  child: const Text(
                    'Capture & Scan Barcode',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                if (isScanned)
                  Text(
                    'Barcode Captured: $barcode',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF055b49),
                    ),
                  ),
                const SizedBox(
                  height: 15,
                ),
                Card(
                  elevation: 4,
                  color: const Color.fromARGB(255, 216, 255, 165),
                  margin: const EdgeInsets.all(14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/better-health.png',
                          width: 60, // Adjust the width as needed
                          height: 100, // Adjust the height as needed
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "View Health Analysis",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF055b49)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HealthAnalysis(
                                            product: {},
                                            analysis: {},
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const Text(
                                "Know the implications of consuming this product",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                softWrap:
                                    true, // Ensures text wraps if necessary
                                overflow: TextOverflow
                                    .visible, // Makes sure text doesn't get cut off
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
