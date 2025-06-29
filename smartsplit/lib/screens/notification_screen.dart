import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<void> _acceptInvitation(String invitationId, String groupId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([user.uid]),
      });
      await FirebaseFirestore.instance.collection('invitations').doc(invitationId).update({
        'status': 'accepted',
      });
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group invitation accepted!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept invitation: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _declineInvitation(String invitationId) async {
    try {
      await FirebaseFirestore.instance.collection('invitations').doc(invitationId).update({
        'status': 'declined',
      });
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group invitation declined.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decline invitation: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('invitations')
                  .where('invitedEmail', isEqualTo: user.email)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final invitations = snapshot.data?.docs ?? [];
                if (invitations.isEmpty) {
                  return const Center(child: Text('No new group invitations.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final invitation = invitations[index].data() as Map<String, dynamic>;
                    final invitationId = invitations[index].id;
                    final groupName = invitation['groupName'] ?? 'Unnamed Group';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.group, color: Colors.blue, size: 36),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('users').doc(invitation['invitedBy']).get(),
                                builder: (context, senderSnapshot) {
                                  String senderName = 'Unknown';
                                  if (senderSnapshot.hasData && senderSnapshot.data!.exists) {
                                    senderName = senderSnapshot.data!['name']?.toString().isNotEmpty == true
                                      ? senderSnapshot.data!['name']
                                      : senderSnapshot.data!['email'] ?? 'Unknown';
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        groupName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Invited by $senderName',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'You have been invited to join this group.',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _acceptInvitation(invitationId, invitation['groupId']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    minimumSize: const Size(80, 36),
                                  ),
                                  child: const Text('Accept'),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () => _declineInvitation(invitationId),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    minimumSize: const Size(80, 36),
                                  ),
                                  child: const Text('Decline'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
} 