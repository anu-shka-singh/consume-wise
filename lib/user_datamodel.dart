class User {
  String id;
  final String email;
  final String name;
  final String age;
  final String gender;
  final String height;
  final String weight;
  final List allergies;
  final List diet;
  final List medicalConditions;

  User({
    this.id = '',
    required this.email,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.allergies,
    required this.diet,
    required this.medicalConditions,
  });
}
