import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay/services/gemini.dart';
import 'package:overlay/services/prompts.dart';
import 'dart:io';
import 'health_analysis.dart';
import 'services/image_processing.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ProductContributionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF055b49),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF055b49),
          secondary: Color(0xFF86b649),
        ),
      ),
      home: ProductContributionPage(),
    );
  }
}

class ProductContributionPage extends StatefulWidget {
  @override
  _ProductContributionPageState createState() =>
      _ProductContributionPageState();
}

class _ProductContributionPageState extends State<ProductContributionPage> {
  final ImageProcessing _imageProcessing = ImageProcessing();
  MobileScannerController cameraController = MobileScannerController();
  XFile? _frontImage;
  XFile? _ingredientsImage;
  XFile? _nutritionalFactsImage;
  String? _barcode;
  bool _isScanned = false;

  String _frontImageText = '';
  String _ingredientsText = '';
  String _nutritionalFactsText = '';
  String image_url = '';

  int _currentStep = 0;
  bool _error = false;

  Future<void> _captureAndCropImage(
      bool isFrontImage, bool isIngredientsImage) async {
    try {
      final pickedFile = await _imageProcessing.captureImage();
      if (pickedFile != null) {
        final croppedFile = await _imageProcessing.cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          final recognizedText = await _imageProcessing.performOCR(croppedFile);

          setState(() {
            _error = false;
            if (isFrontImage) {
              _frontImage = XFile(croppedFile.path);
              _frontImageText = recognizedText;
              _uploadFrontImageToFirebase(File(croppedFile.path));
            } else if (isIngredientsImage) {
              _ingredientsImage = XFile(croppedFile.path);
              _ingredientsText = recognizedText;
            } else {
              _nutritionalFactsImage = XFile(croppedFile.path);
              _nutritionalFactsText = recognizedText;
            }
          });
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to capture or crop image');
    }
  }

  Future<void> _uploadFrontImageToFirebase(File imageFile) async {
    try {
      String downloadUrl = await _imageProcessing.uploadImageToStorage(imageFile);
      setState(() {
        image_url = downloadUrl; 
      });
      print('Front image uploaded: $downloadUrl');
    } catch (e) {
      print('Error uploading front image: $e');
      _showErrorSnackbar('Failed to upload front image');
    }
  }

  // Modify the barcode scanning logic
  void _scanBarcode(BarcodeCapture capture) {
    if (!_isScanned) {
      setState(() {
        _barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
        _isScanned = _barcode != null;
      });

      if (_isScanned) {
        print("Scanned Barcode: $_barcode");
        cameraController.stop();
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF055b49),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFFFF6E7),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Just follow these steps",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF055b49),
              ),
            ),
          ),
          Expanded(
            child: Stepper(
              steps: _getSteps(),
              currentStep: _currentStep,
              onStepContinue: _nextStep,
              onStepCancel: _previousStep,
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF055b49),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: details.onStepCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF055b49),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_currentStep == 3 && _barcode != null)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(10),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 18, vertical: 15), // Adjust values as needed
                  ),
                ),
                onPressed: () async {
                  try {
                    String response = await dataPreprocessing(_barcode!, _frontImageText, _ingredientsText, _nutritionalFactsText);
                    print(response);
                    final cleanResponse = getCleanResponse(response);
                    final Map<String, dynamic> productData = jsonDecode(cleanResponse);
                    print(productData);

                    final String productName = productData['productName'];
                    final String productBarcode = productData['productBarcode'];
                    final String productCategory = productData['productCategory'];
                    final List<dynamic> ingredients = productData['ingredients'];
                    final List<dynamic> nutritionalValue = productData['nutritionalValue'];

                    print('Data to be saved successfully to Firestore');

                    try {
                      await FirebaseFirestore.instance.collection('products').add({
                        'image_url': image_url,
                        'product_name': productName,
                        'product_barcode': productBarcode,
                        'product_category': productCategory,
                        'ingredients': ingredients,
                        'nutriments': nutritionalValue,
                      });

                      print('Data saved successfully to Firestore');

                      final product = convertGPTResponseToProduct(productData, image_url);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HealthAnalysis(
                            product: product,
                          ),
                        ),
                      );
                    } catch (firestoreError) {
                      print('Error saving data to Firestore: $firestoreError');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save data to Firestore: $firestoreError')),
                      );
                    }
                  } catch (error) {
                    print('Error during data processing: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to process data: $error')),
                    );
                  }
                },

                child: const Text('Submit Data', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              ),
            ),
        ],
      ),
    );
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: const Text('Capture Front of the Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: _ImageStepContent(
          image: _frontImage,
          onCaptureImage: () => _captureAndCropImage(true, false),
          detectedText: _frontImageText,
          label: 'front',
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 || (_frontImage != null) ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Capture Ingredients of the Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: _ImageStepContent(
          image: _ingredientsImage,
          onCaptureImage: () => _captureAndCropImage(false, true),
          detectedText: _ingredientsText,
          label: 'ingredients',
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 || (_ingredientsImage != null) ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Capture Nutritional Facts of the Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: _ImageStepContent(
          image: _nutritionalFactsImage,
          onCaptureImage: () => _captureAndCropImage(false, false),
          detectedText: _nutritionalFactsText,
          label: 'nutritional facts',
        ),
        isActive: _currentStep >= 2,
        state: (_frontImage != null && _ingredientsImage != null && _nutritionalFactsImage != null)
            ? StepState.complete
            : StepState.indexed,
      ),
      Step(
        title: const Text('Scan Product Barcode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: _isScanned
            ? Column(
                children: [
                  Text(
                    'Barcode: $_barcode',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF055b49)),
                  ),
                  const SizedBox(height: 20),
                ],
            )
            : SizedBox(
              width: double.infinity,
              height: 400,
              child: MobileScanner(
                controller: cameraController,
                onDetect: (BarcodeCapture capture) {
                  _scanBarcode(capture);
                },
              ),
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 || _barcode != null ? StepState.complete : StepState.indexed,
      ),


    ];
  }

  void _nextStep() {
    if (_isStepValid()) {
      setState(() => _currentStep += 1);
      _error = false;
    } else {
      setState(() => _error = true);
      _showErrorSnackbar('Please capture a photo before continuing.');
    }
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0:
        return _frontImage != null;
      case 1:
        return _ingredientsImage != null;
      case 2:
        return _nutritionalFactsImage != null;
      case 3:
        return _barcode != null; // Validate barcode step
      default:
        return true;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        if (_currentStep == 1) {
          _ingredientsImage = null;
          _ingredientsText = '';
        } else if (_currentStep == 2) {
          _nutritionalFactsImage = null;
          _nutritionalFactsText = '';
        } else if (_currentStep == 3) {
          _barcode = null; // Clear barcode on going back
          _isScanned = false; // Reset scanned status
        }
        _currentStep -= 1;
      });
    } else {
      setState(() {
        _frontImage = null;
        _frontImageText = '';
      });
    }
  }
}

class _ImageStepContent extends StatelessWidget {
  final XFile? image;
  final VoidCallback onCaptureImage;
  final String detectedText;
  final String label;

  const _ImageStepContent({
    required this.image,
    required this.onCaptureImage,
    required this.detectedText,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Please take a clear photo of the $label of the product.', style: TextStyle(fontSize: 15),),
        const SizedBox(height: 10),
        image == null
            ? Container()
            : Image.file(File(image!.path), height: 200),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onCaptureImage,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_sharp, size: 22, color: Color(0xFF055b49)),
              SizedBox(width: 8),
              Text(
                'Capture Photo',
                style: TextStyle(color: Color(0xFF055b49), fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

Map<String, dynamic> convertGPTResponseToProduct(Map<String, dynamic> gptResponse, String imageUrl) {
  // Convert ingredients list (assuming they are plain strings from GPT)
  List<Map<String, dynamic>> convertedIngredients = [];
  if (gptResponse['ingredients'] != null) {
    convertedIngredients = List<String>.from(gptResponse['ingredients']).map((ingredient) {
      return {"text": ingredient};  // Wrap each ingredient as {"text": "ingredient"}
    }).toList();
  }

  // Convert nutritional values list to nutriments map
  Map<String, dynamic> convertedNutriments = {};
  if (gptResponse['nutritionalValue'] != null) {
    for (var nutrient in gptResponse['nutritionalValue']) {
      nutrient.forEach((key, value) {
        convertedNutriments[key] = value;  // Assuming GPT returns a nutrient_name: value structure
      });
    }
  }

  // Assemble the final product map
  return {
    'image_url': imageUrl,
    'product_name': gptResponse['productName'] ?? '',
    'brands' : '',
    'productBarcode': gptResponse['productBarcode'] ?? '',
    'productCategory': gptResponse['productCategory'] ?? '',
    'ingredients': convertedIngredients,  // Converted ingredient list with "text" key
    'nutriments': convertedNutriments,    // Converted nutriments map
    'allergens_hierarchy': []  // If you have allergens, add them here or leave empty
  };
}
