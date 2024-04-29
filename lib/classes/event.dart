import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String title;
  DateTime dateTime;
  String description;
  String location;
  String imageUrl;
  String creatorId;
  List<String> attendees;
  String? groupId; // Make groupId optional

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.creatorId,
    required this.attendees,
    this.groupId, // groupId is now optional
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateTime': Timestamp.fromDate(dateTime),
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
      'creatorId': creatorId,
      'attendees': attendees,
      'groupId': groupId, // Include groupId in the map
    };
  }
}

