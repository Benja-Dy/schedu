// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart';
import '../screens/home_page.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String emailAddress = '';
    String password = '';
    String username = '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                username = value;
              },
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                emailAddress = value;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                password = value;
              },
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final usernameSnapshot = await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username).get();

                  if (usernameSnapshot.docs.isNotEmpty) {
                    // Username already exists
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Username already taken!')),
                    );
                    return; // Exit the function if username exists
                  }
                  // Create user account with email and password
                  final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: emailAddress,
                    password: password,
                  );

                  // Update display name
                  await userCredential.user?.updateDisplayName(username);


                  final userData = {
                    'username': username,
                    'email': emailAddress,
                  };
                  await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(userData);

                  // Automatically sign in the user after successful account creation
                  if (userCredential.user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage(title: 'Schedu')),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  String errorMessage = 'An error occurred.';

                  if (e.code == 'weak-password') {
                    errorMessage = 'The password provided is too weak.';
                  } else if (e.code == 'email-already-in-use') {
                    errorMessage = 'The account already exists for that email.';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                    ),
                  );
                } catch (e) {
                  print(e);
                }
              },
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate back to LoginScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
