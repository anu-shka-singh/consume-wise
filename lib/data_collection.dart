import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart'; // Image cropper package

void main() {
  runApp(ProductContributionApp());
}

class ProductContributionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: const Color(0xFF055b49)),
      home: ProductContributionPage(),
    );
  }
}

class ProductContributionPage extends StatefulWidget {
  @override
  _ProductContributionPageState createState() => _ProductContributionPageState();
}

class _ProductContributionPageState extends State<ProductContributionPage> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _frontImage;
  XFile? _ingredientsImage;
  XFile? _nutritionalFactsImage;

  String _frontImageText = '';
  String _ingredientsText = '';
  String _nutritionalFactsText = '';

  int _currentStep = 0;

  Future<void> _captureAndCropImage(bool isFrontImage, bool isIngredientsImage) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          print("not null is cropped image");
          final recognizedText = await _performOCR(croppedFile);
          print("ocr hogyaaa!!!!!!");
          setState(() {
            if (isFrontImage) {
              _frontImage = XFile(croppedFile.path);
              _frontImageText = recognizedText;
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
      print(e);
      _showErrorSnackbar('Failed to capture or crop image');
    }
  }

  Future<CroppedFile?> _cropImage(File _pickedFile) async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF055b49),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(
              width: 520,
              height: 520,
            ),
          ),
        ],
      );

      return croppedFile;
    }
  }

  // Future<CroppedFile?> _cropImage2(File imageFile) async {
  //   return await ImageCropper().cropImage(
  //     sourcePath: imageFile.path,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: 'Crop Image',
  //         toolbarColor: Colors.blue,
  //         toolbarWidgetColor: Colors.white,
  //         lockAspectRatio: false,
  //       ),
  //       IOSUiSettings(
  //         title: 'Crop Image',
  //       ),
  //     ],
  //   );
  // }

  // Future<String> _performOCR(CroppedFile imageFile) async {
  //   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  //   final inputImage = InputImage.fromFile(imageFile);
  //   try {
  //     final recognizedText = await textRecognizer.processImage(inputImage);
  //     return recognizedText.text;
  //   } catch (e) {
  //     _showErrorSnackbar('Failed to recognize text from image');
  //     return '';
  //   }
  // }

  Future<String> _performOCR(CroppedFile croppedFile) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFilePath(croppedFile.path); // Use fromFilePath instead of fromFile
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      _showErrorSnackbar('Failed to recognize text from image: $e'); // Added error details
      return '';
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
      appBar: AppBar(title: Text('Contribute Product Data'), backgroundColor: const Color(0xFF055b49), foregroundColor: Colors.white,),
      body: Column(
        children: [
          Expanded(
            child: Stepper(
              connectorColor: MaterialStateProperty.all(const Color(0xFF055b49)),
              steps: _getSteps(),
              currentStep: _currentStep,
              onStepContinue: _nextStep,
              onStepCancel: _previousStep,
              onStepTapped: (step) => _goToStep(step),
            ),

          ),
          if (_currentStep == 2 && _frontImage != null && _ingredientsImage != null && _nutritionalFactsImage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Submit the data to the backend or database here.
                },
                child: Text('Submit Data'),
              ),
            ),
        ],
      ),
    );
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: Text('Front Photo'),
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
        title: Text('Ingredients Photo'),
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
        title: Text('Nutritional Facts Photo'),
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
    ];
  }

  void _nextStep() {
    if (_currentStep < _getSteps().length - 1) {
      setState(() => _currentStep += 1);
    }
  }

  void _previousStep2() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        if (_currentStep == 1) {
          // Reset ingredients image and text
          _ingredientsImage = null;
          _ingredientsText = '';
        } else if (_currentStep == 2) {
          // Reset nutritional facts image and text
          _nutritionalFactsImage = null;
          _nutritionalFactsText = '';
        }
        _currentStep -= 1;
      });
    }
    else{
      setState(() {
          _frontImage = null;
          _frontImageText = '';
      });
    }
  }


  void _goToStep(int step) {
    setState(() => _currentStep = step);
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
        Text('Please take a clear photo of the $label of the product.'),
        SizedBox(height: 10),
        image == null
            ? const Placeholder(fallbackHeight: 100)
            : Image.file(File(image!.path), height: 200),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onCaptureImage,
          style: ButtonStyle(backgroundColor:  MaterialStateProperty.all(const Color(0xFF055b49)),),
          child: Text('Capture $label Photo', style: TextStyle(color: Colors.white),),
        ),
        const SizedBox(height: 10),
        detectedText.isNotEmpty
            ? const Text(
          'Detected Text:',
          style: TextStyle(fontWeight: FontWeight.bold),
        )
            : Container(),
        detectedText.isNotEmpty ? Text(detectedText) : Container(),
      ],
    );
  }
}
