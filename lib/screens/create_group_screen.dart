// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../classes/group.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _imageUrl = ""; // To store the downloaded image URL

  // Add a method to handle image picking
  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
    await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // Upload image to Firebase Storage and get the download URL
      final imageData = await pickedImage.readAsBytes();
      final imageName =
      DateTime.now().millisecondsSinceEpoch.toString(); // Generate unique image name
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('group_images/$imageName');
      final uploadTask = storageRef.putData(imageData);
      final snapshot = await uploadTask.whenComplete(() => null);
      _imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {}); // Update UI to show the selected image
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference groups =
    FirebaseFirestore.instance.collection('groups');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Group Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a group name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                Column(
                  children: [
                    Center(
                      child: TextButton(
                        onPressed: pickImage,
                        child: const Text('Select Image (Optional)'),
                      ),
                    ),
                    if (_imageUrl.isNotEmpty)
                      Image.network(_imageUrl, height: 50, width: 50),
                  ],
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 200, // Adjust width as needed
                    height: 50, // Adjust height as needed
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Create a Group object
                          final group = Group(
                            id: "", // Generate a unique ID on the server
                            name: _nameController.text,
                            description: _descriptionController.text,
                            creatorId: user!.uid,
                            members: [user.uid], // Add creator as a member
                          );
                          try {
                            await groups.add(group.toMap()); // Save group to Firestore
                            Navigator.pop(context); // Navigate back
                          } catch (e) {
                            print('Failed to create group: $e');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20), // Adjust font size
                      ),
                      child: const Text('Create Group'),
                    ),
                  ),
                ),
              ],
                ),
          ),
        ),
      ),
    );
  }
}
