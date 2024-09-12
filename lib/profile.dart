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
    'diet': ['vegan', 'low-fat']
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
  TextEditingController allergiesController = TextEditingController();
  TextEditingController dietController = TextEditingController();
  TextEditingController medCondController = TextEditingController();
  final cardColor = const Color(0xFFFFF6E7);

  @override
  void initState() {
    super.initState();
    //print(widget.user);

    nameController.text = widget.user['name']?.toString() ?? '';
    ageController.text = widget.user['age']?.toString() ?? '';
    genderController.text = widget.user['gender']?.toString() ?? '';
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
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF055b49),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(70),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40.0,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage(imageURL),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            nameController.text,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              _buildSection(
                title: 'Personal Info',
                bgcolor: cardColor,
                children: isEditMode
                    ? [
                        _buildEditableInfoRow(
                            'Name', nameController.text, nameController),
                        _buildEditableInfoRow(
                            'Age', ageController.text, ageController),
                        _buildEditableInfoRow(
                            'Gender', genderController.text, genderController),
                      ]
                    : [
                        _buildInfoRow('Name', nameController.text),
                        _buildInfoRow('Age', ageController.text),
                        _buildInfoRow('Gender', genderController.text),
                      ],
              ),
              _buildSection(
                title: 'Allergies',
                bgcolor: cardColor,
                imagePath: 'assets/images/allergy.png',
                children: isEditMode
                    ? [_buildTextField(allergiesController)]
                    : (allergiesController.text.split(', '))
                        .map<Widget>((allergies) {
                        return _buildInfoRow(" ", allergies);
                      }).toList(),
              ),
              _buildSection(
                title: 'Diet',
                bgcolor: cardColor,
                imagePath: 'assets/images/better-health.png',
                children: isEditMode
                    ? [_buildTextField(medCondController)]
                    : widget.user['diet'].map<Widget>((condition) {
                        return _buildInfoRow(' ', condition);
                      }).toList(),
              ),
              _buildSection(
                title: 'Medical Conditions',
                bgcolor: cardColor,
                imagePath: 'assets/images/sick.png',
                children: isEditMode
                    ? [_buildTextField(medCondController)]
                    : widget.user['medicalConditions'].map<Widget>((condition) {
                        return _buildInfoRow(' ', condition);
                      }).toList(),
              ),
              isEditMode
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            final user = User(
                              id: widget.user['id'],
                              email: widget.user['email'],
                              name: nameController.text,
                              age: ageController.text,
                              gender: genderController.text,
                              allergies: allergiesController.text.split(','),
                              diet: dietController.text.split(','),
                              medicalConditions:
                                  medCondController.text.split(','),
                            );
                            //saveUserProfile(user);
                            toggleEditMode();
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
                        ElevatedButton(
                          onPressed: toggleEditMode,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(150, 50),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: toggleEditMode,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Color(0xFF055b49),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(150, 50),
                          ),
                          child: const Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ));
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
      child: (!isEditMode && imagePath != '')
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                Image.asset(
                  imagePath,
                  height: 100,
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
    if (label == ' ') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText:
            'Enter ${controller == allergiesController ? 'allergies' : controller == dietController ? 'diet' : 'medical conditions'}',
      ),
    );
  }

  Widget _buildEditableInfoRow(
      String label, String value, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          '$label :  ',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(),
          ),
        ),
      ],
    );
  }

//   void saveUserProfile(
//     User userProfile,
//   ) {
//     String path = 'userProfiles/${userProfile.id}';
//     FirebaseFirestore.instance.doc(path).update({
//       'email': userProfile.email,
//       'name': userProfile.name,
//       'age': userProfile.age,
//       'gender': userProfile.gender,
//       'allergies': userProfile.allergies,
//       'diet': userProfile.deit,
//       'medicalConditions': userProfile.medicalConditions,
//     }).then((value) {
//       // Successfully saved data to Firestore
//     }).catchError((error) {
//       // Handle errors, e.g., Firestore is unreachable
//     });
//   }
}
