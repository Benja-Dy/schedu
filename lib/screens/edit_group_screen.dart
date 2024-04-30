import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditGroupScreen extends StatefulWidget {
  final String groupId;

  const EditGroupScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _EditGroupScreenState createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch group details and populate text controllers
    _fetchGroupDetails();
  }

  Future<void> _fetchGroupDetails() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
      Map<String, dynamic> groupData = groupSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = groupData['name'] ?? '';
        _descriptionController.text = groupData['description'] ?? '';
      });
    } catch (error) {
      print('Error fetching group details: $error');
    }
  }

  Future<void> _updateGroupDetails() async {
    try {
      await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
        'name': _nameController.text,
        'description': _descriptionController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group details updated successfully')),
      );
    } catch (error) {
      print('Error updating group details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating group details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save group details
              _updateGroupDetails();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Name',
              style: Theme.of(context).textTheme.headline6,
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter group name',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Group Description',
              style: Theme.of(context).textTheme.headline6,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter group description',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
