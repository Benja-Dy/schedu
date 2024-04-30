import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/edit_event_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final List<dynamic>? groupEvents;

  const EventDetailsScreen({Key? key, required this.data, this.groupEvents}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Future<String?> _eventIdFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch the event ID
    _eventIdFuture = fetchEventId();
  }

  Future<String?> fetchEventId() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('title', isEqualTo: widget.data['title'])
          .where('description', isEqualTo: widget.data['description'])
          .get();
      final List<DocumentSnapshot> documents = querySnapshot.docs;
      if (documents.isNotEmpty) {
        return documents.first.id;
      } else {
        return null; // Event not found
      }
    } catch (error) {
      print('Error fetching event ID: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _eventIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.data['title']),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.data['title']),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          final eventId = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.data['title']),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: eventId != null
                      ? () {
                    // Navigate to edit event screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditEventScreen(eventId: eventId, data: widget.data)),
                    );
                  }
                      : null, // Disable edit button if eventId is null
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM d, h:mm a').format(widget.data['dateTime'].toDate()),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  if (widget.data['location'] != null && widget.data['location'].isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Location:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.data['location'],
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data['description'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
