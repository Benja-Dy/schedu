// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add the image_picker package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add Firebase Storage
import 'package:firebase_auth/firebase_auth.dart'; // Get User ID
import '../classes/event.dart';
import 'package:intl/intl.dart'; // Add this line

class CreateEventScreen extends StatefulWidget {
  final String groupId; // Add groupId parameter

  const CreateEventScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _dateTime = DateTime.now();
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
      final storageRef =
      FirebaseStorage.instance.ref().child('event_images/$imageName');
      final uploadTask = storageRef.putData(imageData);
      final snapshot = await uploadTask.whenComplete(() => null);
      _imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {}); // Update UI to show the selected image
    }
  }

  // Add a method to handle date picking
  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (pickedDate != null) {
      setState(() {
        _dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _dateTime.hour,
          _dateTime.minute,
        );
      });
    }
  }

  // Add a method to handle time picking
  Future<void> pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (pickedTime != null) {
      setState(() {
        _dateTime = DateTime(
          _dateTime.year,
          _dateTime.month,
          _dateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference events =
    FirebaseFirestore.instance.collection('events');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration:
                  const InputDecoration(labelText: 'Description'),
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                      labelText: 'Location (Optional)'),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: pickDate,
                        child: const Text('Select Date'),
                      ),
                      const SizedBox(
                          width: 10), // Add some space between the buttons
                      TextButton(
                        onPressed: pickTime,
                        child: const Text('Select Time'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                    height:
                    10), // Add some vertical space between the date/time and the selected date/time
                Text(
                  DateFormat('yyyy-MM-dd hh:mm a')
                      .format(_dateTime), // Format the date and time
                  style: const TextStyle(
                      fontSize: 18), // Adjust the font size
                ),

                /*
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
*/
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: 200, // Adjust width as needed
                      height: 50, // Adjust height as needed
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Create an Event object with the groupId parameter
                            final event = Event(
                              id: "", // Generate a unique ID on the server
                              title: _titleController.text,
                              dateTime: _dateTime,
                              description: _descriptionController.text,
                              location: _locationController.text,
                              imageUrl: _imageUrl,
                              creatorId: user!.uid,
                              attendees: [],
                              groupId: widget.groupId, // Pass the groupId parameter
                            );
                            try {
                              // Save event to Firestore
                              final eventRef = await events.add(event.toMap());

                              // Update group data to include the eventId in the events array
                              final groups = FirebaseFirestore.instance
                                  .collection('groups');
                              await groups
                                  .doc(widget.groupId)
                                  .update({'events': FieldValue.arrayUnion([eventRef.id])});

                              Navigator.pop(context); // Navigate back
                            } catch (e) {
                              print('Failed to create event: $e');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                              fontSize: 20), // Adjust font size
                        ),
                        child: const Text('Create Event'),
                      ),
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
