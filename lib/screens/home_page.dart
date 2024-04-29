import 'package:flutter/material.dart';
import 'package:schedu/screens/profile_screen.dart';
import '../screens/create_group_screen.dart';
import '../screens/add_event_screen.dart';
import '../screens/event_details_screen.dart';
import '../screens/group_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/invite_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User _user;
  late CollectionReference _groups;
  List<String> _userGroups = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _groups = FirebaseFirestore.instance.collection('groups'); // Initialize _groups
    _fetchUserGroups();
    _listenForGroupChanges();
  }
  void _listenForGroupChanges() {
    FirebaseFirestore.instance.collection('groups').snapshots().listen((snapshot) {
      // Call _fetchUserGroups whenever there's a change in the groups collection
      _fetchUserGroups();
    });
  }

  void _fetchUserGroups() async {
    QuerySnapshot groupSnapshot = await _groups.where('members', arrayContains: _user.uid).get();
    setState(() {
      _userGroups = groupSnapshot.docs.map((doc) => doc.id).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: <Widget>[


          IconButton(
            icon: const Icon(Icons.mail), // Use the mail icon
            tooltip: 'Invitations',
            onPressed: () {
              // Navigate to the invite page (replace with the actual route)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InvitePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: StreamBuilder<QuerySnapshot>(
          stream: _groups.where('members', arrayContains: _user.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              default:
                return ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                      ),
                      child: Text(
                        'Groups',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    ...snapshot.data!.docs.map((DocumentSnapshot document) {
                      final data = document.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GroupScreen(groupId: document.id)),
                          );
                        },
                      );
                    }).toList(),
                    const Divider(), // Add a divider
                    ListTile(
                      title: const Text('Create New Group'),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateGroupScreen()));
                      },
                    ),
                  ],
                );
            }
          },
        ),
      ),
      body: _userGroups.isEmpty ? Center(child: Text('No groups found.')) : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events')
            .where('groupId', whereIn: _userGroups)
            .orderBy('dateTime', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No events found.'));
              }
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('groups').doc(data['groupId']).get(),
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> groupSnapshot) {
                      if (groupSnapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic>? groupData = groupSnapshot.data!.data() as Map<String, dynamic>?;
                        String groupName = groupData?['name'] ?? 'Unknown Group';

                        // Extract date and time information from the event data
                        Timestamp timestamp = data['dateTime'] as Timestamp;
                        DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
                        String formattedDateTime = DateFormat('MMM d, h:mm a').format(dateTime); // Format the date and time

                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(data['title']),
                              Text(formattedDateTime), // Display formatted date and time on the right side
                            ],
                          ),
                          subtitle: Text(groupName), // Display group name
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EventDetailsScreen(data: data)),
                            );
                          },
                        );
                      } else {
                        // Show a loading indicator while fetching the group name
                        return ListTile(
                          title: Text(data['title']),
                          subtitle: Text('Loading...'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EventDetailsScreen(data: data)),
                            );
                          },
                        );
                      }
                    },
                  );
                }).toList(),
              );


          }
        },
      ),

/*
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
        },
        tooltip: 'Create Event',
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, color: Colors.black),
      ),

      */
    );
  }
}
