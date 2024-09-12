import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'user_datamodel.dart';

void main() {
  final data = {
    'email': 'bob@example.com',
    'name': 'Bob',
    'age': '70',
    'gender': 'male',
    'allergies': ['Peanuts', 'Shellfish'],
    'medicalConditions': ['High Blood Pressure', 'Diabetes'],
    'diet': ['Vegan', 'Low-fat']
  };
  runApp(MaterialApp(
    home: ProfilePage(user: data),
  ));
}

class ProfilePage extends StatefulWidget {
  Map<String, dynamic> user;
  ProfilePage({super.key, required this.user});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditMode = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController allergiesController = TextEditingController();
  TextEditingController dietController = TextEditingController();
  TextEditingController medCondController = TextEditingController();

  final cardColor = const Color.fromARGB(255, 255, 255, 255);

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user['name']?.toString() ?? '';
    ageController.text = widget.user['age']?.toString() ?? '';
    genderController.text = widget.user['gender']?.toString() ?? '';
    heightController.text = widget.user['height']?.toString() ?? '';
    weightController.text = widget.user['weight']?.toString() ?? '';
    allergiesController.text =
        (widget.user['allergies'] as List<dynamic>?)?.join(', ') ?? '';
    dietController.text =
        (widget.user['diet'] as List<dynamic>?)?.join(', ') ?? '';
    medCondController.text =
        (widget.user['medicalConditions'] as List<dynamic>?)?.join(', ') ?? '';
  }

  void toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageURL = (genderController.text == 'male')
        ? 'assets/images/male.png'
        : 'assets/images/female.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF055b49),
        foregroundColor: Colors.white,
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        actions: [
          isEditMode
              ? IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    final user = User(
                      id: widget.user['id'],
                      email: widget.user['email'],
                      name: nameController.text,
                      age: ageController.text,
                      gender: genderController.text,
                      height: heightController.text,
                      weight: weightController.text,
                      allergies: allergiesController.text.split(','),
                      diet: dietController.text.split(','),
                      medicalConditions: medCondController.text.split(','),
                    );
                    saveUserProfile(user);
                    toggleEditMode();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: toggleEditMode,
                ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF6E7),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(imageURL),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Personal Info',
                  bgcolor: cardColor,
                  children: isEditMode
                      ? [
                          _buildEditableInfoRow(
                              'Name', nameController.text, nameController),
                          _buildEditableInfoRow(
                              'Age', ageController.text, ageController),
                          _buildEditableInfoRow('Gender', genderController.text,
                              genderController),
                        ]
                      : [
                          _buildInfoRow('Name', nameController.text),
                          _buildInfoRow('Age', ageController.text),
                          _buildInfoRow('Gender', genderController.text),
                          _buildInfoRow('Height', heightController.text),
                          _buildInfoRow('Weight', weightController.text),
                        ],
                ),
                _buildSection(
                  title: 'Allergies',
                  bgcolor: cardColor,
                  imagePath: 'assets/images/allergy.png',
                  children: isEditMode
                      ? [_buildTextField(allergiesController)]
                      : (allergiesController.text.split(', '))
                          .map<Widget>((allergy) {
                          return _buildInfoRow("", allergy);
                        }).toList(),
                ),
                _buildSection(
                  title: 'Diet',
                  bgcolor: cardColor,
                  imagePath: 'assets/images/diet.png',
                  children: isEditMode
                      ? [_buildTextField(dietController)]
                      : widget.user['diet']
                          .map<Widget>((diet) => _buildInfoRow("", diet))
                          .toList(),
                ),
                _buildSection(
                  title: 'Medical Conditions',
                  bgcolor: cardColor,
                  imagePath: 'assets/images/health-report.png',
                  children: isEditMode
                      ? [_buildTextField(medCondController)]
                      : widget.user['medicalConditions']
                          .map<Widget>(
                              (condition) => _buildInfoRow("", condition))
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String imageURL) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF055b49),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(70),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 50.0,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(imageURL),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameController.text,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.user['email'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required bgcolor,
    String imagePath = '',
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgcolor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      child: (!isEditMode && imagePath.isNotEmpty)
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: children,
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  imagePath,
                  height: 70,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: children,
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (label == '') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label Section
          Expanded(
            flex: 3,
            child: Text(
              label.isNotEmpty ? label : '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Value Section
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow(
      String label, String value, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(),
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText:
              'Enter ${controller == allergiesController ? 'allergies' : controller == dietController ? 'diet' : 'medical conditions'}',
          hintStyle: const TextStyle(fontSize: 16),
          fillColor: Colors.white,
        ),
      ),
    );
  }

  void saveUserProfile(
    User userProfile,
  ) {
    String path = 'userProfiles/${userProfile.id}';
    FirebaseFirestore.instance.doc(path).update({
      'email': userProfile.email,
      'name': userProfile.name,
      'age': userProfile.age,
      'gender': userProfile.gender,
      'height': userProfile.height,
      'weight': userProfile.weight,
      'allergies': userProfile.allergies,
      'diet': userProfile.diet,
      'medicalConditions': userProfile.medicalConditions,
    }).then((value) {
      //Successfully saved data to Firestore
    }).catchError((error) {
//Handle errors, e.g., Firestore is unreachable
    });
  }
}
