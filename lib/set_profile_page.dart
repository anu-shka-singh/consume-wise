import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import '../user_datamodel.dart';

void main() {
  runApp(MaterialApp(
    home: ProfileSetupPage(
      email: 'abc@gmail.com',
    ),
  ));
}

class ProfileSetupPage extends StatefulWidget {
  String email;
  ProfileSetupPage({super.key, required this.email});
  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _dietController = TextEditingController();
  final TextEditingController _medicalConditionsController =
      TextEditingController();
  String _selectedGender = "Male";
  String docId = '';

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Setup'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(children: <Widget>[
              Center(
                child: Image.asset(
                  'assets/images/login.png',
                  height: 150,
                ),
              ),
              _buildSection(
                title: 'Personal Information',
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10), // Add space
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Gender*',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    items: <String>[
                      'Male',
                      'Female',
                      'Non-Binary',
                      'Other',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10), // Add space
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              _buildSection(
                title: 'Additional Information',
                children: [
                  TextFormField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(
                      labelText: 'Allergies',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dietController,
                    decoration: const InputDecoration(
                      labelText: 'Diet Followed',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _medicalConditionsController,
                    decoration: const InputDecoration(
                      labelText: 'Medical Conditions',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user = User(
                      email: widget.email,
                      name: _nameController.text,
                      age: _ageController.text,
                      gender: _selectedGender,
                      allergies: _allergiesController.text.split(','),
                      diet: _dietController.text.split(','),
                      medicalConditions:
                          _medicalConditionsController.text.split(','),
                    );
                    await saveUserProfile(user);

                    Map<String, dynamic> data = {
                      'id': docId,
                      'email': widget.email,
                      'name': _nameController.text,
                      'age': _ageController.text,
                      'gender': _selectedGender,
                      'allergies': _allergiesController.text.split(','),
                      'diet': _dietController.text.split(','),
                      'medicalConditions':
                          _medicalConditionsController.text.split(','),
                    };
                    // If Form is valid, save user's profile

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(
                          user: data,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF055b49),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(150, 50),
                ),
                child: const Text(
                  "Save Details",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
          ),
        ));
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      title: Text(title),
      children: children,
    );
  }

  Future<void> saveUserProfile(User userProfile) async {
    try {
      final DocumentReference docRef =
          await FirebaseFirestore.instance.collection('userProfiles').add({
        'email': userProfile.email,
        'name': userProfile.name,
        'age': userProfile.age,
        'gender': userProfile.gender,
        'allergies': userProfile.allergies,
        'diet': userProfile.diet,
        'medicalConditions': userProfile.medicalConditions,
      });

      // Get the auto-generated Firestore document ID
      docId = docRef.id;

      // Update the 'id' field in the document with the generated ID
      await docRef.update({'id': docId});

      // Successfully saved data to Firestore
    } catch (error) {
      // Handle errors, e.g., Firestore is unreachable
      print('Error: $error');
    }
  }
}
