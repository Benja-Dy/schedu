import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvitePage extends StatelessWidget {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('group_invitations').where('invitedUserId', isEqualTo: user.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have no pending invitations.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final invitationData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final groupId = invitationData['groupId'];
              final invitationId = snapshot.data!.docs[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('groups').doc(groupId).get(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> groupSnapshot) {
                  if (groupSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  final groupName = groupSnapshot.data!.get('name');

                  return ListTile(
                    title: Text('Invitation to join group: $groupName'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            acceptInvitation(invitationId, groupId, user.uid);
                          },
                          child: const Text('Accept'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            rejectInvitation(invitationId);
                          },
                          child: const Text('Reject'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Method to accept an invitation
  void acceptInvitation(String invitationId, String groupId, String userId) async {
    try {
      // Add the user to the group
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([userId])
      });

      // Delete the invitation
      await FirebaseFirestore.instance.collection('group_invitations').doc(invitationId).delete();

      // Show success message or update UI
    } catch (e) {
      print('Error accepting invitation: $e');
      // Handle errors
    }
  }

  // Method to reject an invitation
  void rejectInvitation(String invitationId) async {
    try {
      // Delete the invitation
      await FirebaseFirestore.instance.collection('group_invitations').doc(invitationId).delete();

      // Show success message or update UI
    } catch (e) {
      print('Error rejecting invitation: $e');
      // Handle errors
    }
  }
}
