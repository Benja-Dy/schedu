import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Import the login screen if not already imported

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch the current user
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              // Navigate back to the login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display user's display name if available
              if (user != null && user.displayName != null)
                Text(
                  'Username: ${user.displayName}',
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 20),
              // Display user's email if available
              if (user != null && user.email != null)
                Text(
                  'Email: ${user.email}',
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 20),

         /*
              // Button to leave group
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Implement the action to leave the group here
                    // For example, you can show a confirmation dialog and
                    // handle the leave group logic when confirmed
                    // You can use FirebaseAuth.instance.currentUser to get the current user
                    // and Firebase APIs to update the user's group membership
                  },
                  child: Text('Leave Group'),
                ),
              ),

              */
            ],
          ),
        ),
      ),
    );
  }
}
