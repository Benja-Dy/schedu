// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/group_event_screen.dart';
import '../screens/event_details_screen.dart';
import '../screens/edit_group_screen.dart';

class GroupScreen extends StatelessWidget {
  final String groupId;

  const GroupScreen({Key? key, required this.groupId}) : super(key: key);

  // Function to show invite user dialog
  void _showInviteUserDialog(BuildContext context) {
    String username = ''; // Store the entered username

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invite User'),
          content: TextField(
            onChanged: (value) {
              username = value; // Update the username as it is entered
            },
            decoration: const InputDecoration(hintText: 'Enter username'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Invite'),
              onPressed: () async {
                // Invitation logic
                try {
                  // Find the user document based on the entered username
                  final userDoc = await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username).get();
                  print(userDoc.docs);
                  if (userDoc.docs.isEmpty) {
                    // User not found
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not found')),
                    );
                    return;
                  }

                  final invitedUserId = userDoc.docs.first.id;

                  // Create a new invitation document
                  final invitationDoc = FirebaseFirestore.instance.collection('group_invitations').doc();
                  await invitationDoc.set({
                    'id': invitationDoc.id,
                    'groupId': groupId,
                    'invitedUserId': invitedUserId,
                    'inviterId': FirebaseAuth.instance.currentUser!.uid,
                    'sentAt': DateTime.now(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitation sent!')),
                  );
                } catch (error) {
                  print('Error sending invitation: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error sending invitation')),
                  );
                }

                // Close the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to retrieve users in the group
  Future<List<String>> getUsersInGroup() async {
    try {
      final groupSnapshot = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      final groupData = groupSnapshot.data() as Map<String, dynamic>;
      final List<String> memberIds = List.from(groupData['members']);
      return memberIds;
    } catch (error) {
      print('Error fetching group members: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('groups').doc(groupId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error ?? "Group not found"}'),
            ),
          );
        }

        final groupData = snapshot.data!.data() as Map<String, dynamic>;
        final groupName = groupData['name'];
        print(groupData['events']);

        return Scaffold(
          appBar: AppBar(
            title: Text(groupName),
            actions: [
              IconButton(
                icon: const Icon(Icons.group),
                onPressed: () {
                  // Show the users in the group
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Users in $groupName'),
                        content: FutureBuilder<List<String>>(
                          future: getUsersInGroup(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text('No users in the group');
                            } else {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: snapshot.data!.map((userId) {
                                  // You can fetch user details here and display them
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (userSnapshot.hasError || !userSnapshot.hasData) {
                                        return const SizedBox(); // Handle error or no data
                                      } else {
                                        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                        final username = userData['username'];
                                        return Text(username);
                                      }
                                    },
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to the screen to edit group details
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditGroupScreen(groupId: groupId)),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('events').where('groupId', isEqualTo: groupId).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No events found for this group'),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        final eventData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () {
                            // Navigate to event details screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EventDetailsScreen(data: eventData, groupEvents: groupData['events'])),
                            );
                          },
                          child: ListTile(
                            title: Text(eventData['title']),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  // Show invite user dialog
                  _showInviteUserDialog(context);
                },
                tooltip: 'Invite Users',
                heroTag: 'inviteButton',
                backgroundColor: Colors.teal[200],
                child: const Icon(Icons.person_add),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateEventScreen(groupId: groupId)),
                  );
                },
                tooltip: 'Create Event',
                backgroundColor: Colors.teal[200],
                child: const Icon(Icons.add),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Align FloatingActionButton to the bottom right
        );
      },
    );
  }
}
