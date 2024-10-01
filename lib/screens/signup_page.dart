// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:overlay/database/database_service.dart';
import 'set_profile_page.dart';
import 'signin_page.dart';

class SignUp extends StatefulWidget {
  final DatabaseService dbService;
  final bool permissionsAvailable;
  const SignUp(
      {super.key, required this.dbService, required this.permissionsAvailable});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF055b49),
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
                    border: OutlineInputBorder(),
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
                  obscureText: true, // Hide the password
                ),
                const SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, false, () async {
                  final userExists =
                      await doesUserExist(_emailTextController.text);
                  if (userExists) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('User Exists'),
                        content:
                            const Text('This email is already registered.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    try {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Success'),
                          content: const Text('New User Registered.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileSetupPage(
                                    email: _emailTextController.text,
                                  ),
                                ),
                              ),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } on FirebaseAuthException catch (error) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Error'),
                          content:
                              Text("Error ${error.toString().split(']')[1]}"),
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
                }),
                const SizedBox(
                  height: 10,
                ),
                signInOption(),
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
                        "Sign up with Google",
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

  Row signInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? ",
            style: TextStyle(color: Color(0xFF055b49))),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage(
                          dbService: widget.dbService,
                          permissionsAvailable: widget.permissionsAvailable,
                        )));
          },
          child: const Text(
            "Sign In",
            style: TextStyle(
                color: Color(0xFF055b49), fontWeight: FontWeight.bold),
          ),
        )
      ],
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

        // After successful sign in, navigate to Profile Setup Page
        if (userCredential.user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileSetupPage(
                email: userCredential.user!.email!,
              ),
            ),
          );
        }
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

  Future<bool> doesUserExist(String email) async {
    try {
      // Check if the email is already registered
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      // If methods is not empty, a user with this email exists
      return methods.isNotEmpty;
    } catch (e) {
      // Handle any errors
      return false;
    }
  }
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
      "Sign Up",
      style: TextStyle(
        fontSize: 22,
        color: Colors.white,
      ),
    ),
  );
}
