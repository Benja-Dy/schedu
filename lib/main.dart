import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check for authentication state
  final user = FirebaseAuth.instance.currentUser;
  runApp(
    MyApp(
      auth: user != null,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.auth}) : super(key: key);

  final bool auth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedu',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: auth ? const HomePage(title: 'Schedu') : const LoginScreen(),
    );
  }
}

