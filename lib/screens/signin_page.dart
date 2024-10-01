// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:overlay/database/database_service.dart';
import 'home.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  final DatabaseService dbService;
  final bool permissionsAvailable;
  const LoginPage(
      {super.key, required this.dbService, required this.permissionsAvailable});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  Future<Map<String, dynamic>> fetchData(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('userProfiles')
              .where('email', isEqualTo: email)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0].data();
      } else {
        print('No user data found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: const Color(0xFF055b49),
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFFFF6E7),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Column(
              children: <Widget>[
                Image.asset(
                  "assets/images/consume-wise.png",
                  height: 250,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Enter Email",
                    icon: Icon(Icons.email),
                    border: OutlineInputBorder(), // Add a border
                  ),
                  controller: _emailTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Enter Password",
                    icon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  controller: _passwordTextController,
                  obscureText: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, true, () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    );
                    final data = await fetchData(_emailTextController.text);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(
                          user: data,
                          currentIndex: 0,
                          dbService: widget.dbService,
                          permissionsAvailable: widget.permissionsAvailable,
                        ),
                      ),
                    );
                  } on FirebaseAuthException catch (error) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                                title: const Text('Error'),
                                content: Text(
                                    "Error ${error.toString().split(']')[1]}"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  )
                                ]));
                  }
                }),
                const SizedBox(
                  height: 10,
                ),
                signUpOption(),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(150, 50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/google.jpg",
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Sign in with Google",
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF055b49),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () => signInWithGoogle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // After successful sign in, navigate to Main Screen
        final data = await fetchData(userCredential.user!.email!);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
              user: data,
              currentIndex: 0,
              dbService: widget.dbService,
              permissionsAvailable: widget.permissionsAvailable,
            ),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text("Error: $e"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ",
            style: TextStyle(color: Color(0xFF055b49))),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SignUp(
                          dbService: widget.dbService,
                          permissionsAvailable: widget.permissionsAvailable,
                        )));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
                color: Color(0xFF055b49), fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget signInSignUpButton(
      BuildContext context, bool isSignIn, Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF055b49),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: const Size(150, 50),
      ),
      child: const Text(
        "Sign In",
        style: TextStyle(
          fontSize: 22,
          color: Colors.white,
        ),
      ),
    );
  }
}
