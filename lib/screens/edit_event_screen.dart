import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> data;

  const EditEventScreen({Key? key, required this.eventId, required this.data}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.data['title']);
    _locationController = TextEditingController(text: widget.data['location']);
    _descriptionController = TextEditingController(text: widget.data['description']);
    _selectedDateTime = widget.data['dateTime'].toDate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _deleteEvent() async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(widget.data['id']).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
      Navigator.pop(context); // Pop back to the previous screen (EventDetailsScreen)
    } catch (error) {
      print('Error deleting event: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting event')),
      );
    }
  }

  Future<void> _updateEventDetails() async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
        'title': _titleController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'dateTime': Timestamp.fromDate(_selectedDateTime),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event details updated successfully')),
      );
    } catch (error) {
      print('Error updating event details: $error');
      widget.data.forEach((key, value) {
        print('$key: $value');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating event details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.data['title']}'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Save event details
              _updateEventDetails();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Date & Time: ${DateFormat('MMM d, h:mm a').format(_selectedDateTime)}'),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? pickedDateTime = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDateTime != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedDateTime = DateTime(
                            pickedDateTime.year,
                            pickedDateTime.month,
                            pickedDateTime.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
