// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  Future<Map<String, dynamic>> fetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('userProfiles')
              .where('email', isEqualTo: _emailTextController.text)
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
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              top: size.height * 0.1,
              right: 20,
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                  width: 20,
                ),
                Image.asset("assets/images/login.png"),
                const SizedBox(
                  height: 40,
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
                    final data = await fetchData();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(
                          user: data,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ",
            style: TextStyle(color: const Color(0xFF055b49))),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUp()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
                color: const Color(0xFF055b49), fontWeight: FontWeight.bold),
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
