import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import '../../user_datamodel.dart';

void main() {
  runApp(const MaterialApp(
    home: ProfileSetupPage(
      email: 'abc@gmail.com',
    ),
  ));
}

class ProfileSetupPage extends StatefulWidget {
  final String email;
  const ProfileSetupPage({super.key, required this.email});
  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _dietController = TextEditingController();
  final TextEditingController _medicalConditionsController =
      TextEditingController();
  String _selectedGender = "Male";
  String docId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF055b49),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFFFF6E7),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const Center(
                child: Text(
                  'Please enter your details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF055b49),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildSection(
                title: 'Personal Information',
                children: [
                  _buildTextFormField(
                    controller: _nameController,
                    labelText: 'Full Name*',
                    validator: (value) =>
                        value!.isEmpty ? 'This field is required.' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownFormField(
                    value: _selectedGender,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                    items: <String>['Male', 'Female', 'Non-Binary', 'Other'],
                    labelText: 'Gender*',
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _ageController,
                    labelText: 'Age*',
                    validator: (value) =>
                        value!.isEmpty ? 'This field is required.' : null,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _heightController,
                    labelText: 'Height (in cm)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _weightController,
                    labelText: 'Weight (in kg)',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildExpandableSection(
                title: 'Additional Information',
                children: [
                  _buildTextFormField(
                    controller: _allergiesController,
                    labelText: 'Allergies',
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _dietController,
                    labelText: 'Diet Followed',
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _medicalConditionsController,
                    labelText: 'Medical Conditions',
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
                      height: _heightController.text,
                      weight: _weightController.text,
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
                      'height': _heightController.text,
                      'weight': _weightController.text,
                      'allergies': _allergiesController.text.split(','),
                      'diet': _dietController.text.split(','),
                      'medicalConditions':
                          _medicalConditionsController.text.split(','),
                    };

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(
                          user: data,
                          currentIndex: 0,
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
                  fixedSize: const Size(200, 50), // Fixed size for the button
                ),
                child: const Text(
                  "Save Details",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF055b49),
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background for the expandable section
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF055b49),
          ),
        ),
        children: children,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDropdownFormField({
    required String value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
    required String labelText,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
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
        'height': userProfile.height,
        'weight': userProfile.weight,
        'allergies': userProfile.allergies,
        'diet': userProfile.diet,
        'medicalConditions': userProfile.medicalConditions,
      });

      docId = docRef.id;

      await docRef.update({'id': docId});

      // Successfully saved data to Firestore
    } catch (error) {
      print('Error: $error');
    }
  }
}
