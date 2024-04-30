// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import '../screens/home_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String emailAddress = '';
    String password = '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  // Sign in with email and password
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailAddress,
                    password: password,
                  );

                  // Navigate to HomeScreen or any other screen after successful login
                  // Here, I'm navigating to HomeScreen which you need to replace with your desired screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage(title: 'Schedu')),
                  );
                } on FirebaseAuthException catch (e) {
                  String errorMessage = 'Username/Password not found';

                  if (e.code == 'user-not-found') {
                    errorMessage = 'No user found for that email.';
                  } else if (e.code == 'wrong-password') {
                    errorMessage = 'Wrong password provided for that user.';
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
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to CreateAccountScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
                );
              },
              child: const Text('Don\'t have an account? Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
