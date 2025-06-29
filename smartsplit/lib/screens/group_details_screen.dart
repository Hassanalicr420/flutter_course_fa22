import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart'; // For sumBy

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final Map<String, dynamic> groupData;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.groupData,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final _expenseFormKey = GlobalKey<FormState>();
  final _expenseTitleController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  final _expenseDescriptionController = TextEditingController();
  final _chatController = TextEditingController();
  final _inviteEmailController = TextEditingController();
  bool _isLoading = false;
  int _selectedTab = 0;

  Map<String, double> _balances = {};

  // Add a stream for expenses to listen for real-time updates for balance calculation
  Stream<QuerySnapshot>? _expensesStream;

  @override
  void initState() {
    super.initState();
    _expensesStream = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('expenses')
        .snapshots();
    _expensesStream!.listen((snapshot) {
      _calculateBalances(snapshot.docs);
    });
  }

  Future<void> _addExpense() async {
    if (_expenseFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final expenseId = const Uuid().v4();
        final amount = double.parse(_expenseAmountController.text);
        final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
        final members = (groupDoc.data()?['members'] as List<dynamic>) ?? [];
        final perPersonAmount = amount / members.length;

        final expenseData = {
          'title': _expenseTitleController.text.trim(),
          'amount': amount,
          'description': _expenseDescriptionController.text.trim(),
          'paidBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'perPersonAmount': perPersonAmount,
          'settled': false,
        };

        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('expenses')
            .doc(expenseId)
            .set(expenseData);

        if (mounted) {
          Navigator.pop(context);
          _expenseTitleController.clear();
          _expenseAmountController.clear();
          _expenseDescriptionController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add expense'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_chatController.text.trim().isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final messageData = {
        'text': _chatController.text.trim(),
        'senderId': user.uid,
        'senderEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .add(messageData);

      _chatController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _inviteMember() async {
    final invitedEmail = _inviteEmailController.text.trim();
    if (invitedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Check if the invited email is a registered user
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: invitedEmail.toLowerCase())
          .limit(1)
          .get();

      if (usersSnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No registered user found with this email. Please make sure they have registered first.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final invitedUserId = usersSnapshot.docs.first.id;

      // Check if the user is already a member
      if (widget.groupData['members'].contains(invitedUserId)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This user is already a member of this group.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Check if a pending invitation already exists
      final existingInvite = await FirebaseFirestore.instance
          .collection('invitations')
          .where('groupId', isEqualTo: widget.groupId)
          .where('invitedEmail', isEqualTo: invitedEmail.toLowerCase())
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingInvite.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An invitation has already been sent to this user.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Send invitation
      await FirebaseFirestore.instance.collection('invitations').add({
        'groupId': widget.groupId,
        'groupName': widget.groupData['name'] ?? 'Unnamed Group',
        'invitedBy': currentUser.uid,
        'invitedEmail': invitedEmail.toLowerCase(),
        'invitedUserId': invitedUserId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // Close the dialog
        _inviteEmailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleExpenseSettledStatus(String expenseId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('expenses')
          .doc(expenseId)
          .update({
        'settled': !currentStatus,
        'settledAt': !currentStatus ? FieldValue.serverTimestamp() : null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!currentStatus ? 'Expense marked as settled!' : 'Expense marked as unsettled!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update expense status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _calculateBalances(List<DocumentSnapshot> expenseDocs) {
    final Map<String, double> newBalances = {};
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Initialize balances for all group members
    for (var memberId in widget.groupData['members']) {
      newBalances[memberId] = 0.0;
    }

    for (var doc in expenseDocs) {
      final expense = doc.data() as Map<String, dynamic>;
      if (expense['settled'] == true) continue; // Skip settled expenses

      final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
      final paidBy = expense['paidBy'];
      final members = widget.groupData['members'] as List<dynamic>;

      if (members.isEmpty) continue; // Avoid division by zero
      final perPersonAmount = amount / members.length;

      // Distribute the expense
      for (var memberId in members) {
        if (memberId == paidBy) {
          // The payer gets credited for what others owe them
          newBalances[memberId] = (newBalances[memberId] ?? 0.0) + (amount - perPersonAmount);
        } else {
          // Others owe their share
          newBalances[memberId] = (newBalances[memberId] ?? 0.0) - perPersonAmount;
        }
      }
    }

    setState(() {
      _balances = newBalances;
    });
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Form(
          key: _expenseFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _expenseTitleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expense title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expenseAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expenseDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addExpense,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Member'),
        content: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _inviteEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Member Email',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Enter the email address of the registered user',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _inviteEmailController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _inviteMember,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Invite'),
          ),
        ],
      ),
    );
  }

  void _shareInviteLink() {
    final inviteCode = widget.groupData['inviteCode'];
    final inviteLink = 'https://yourapp.com/join/$inviteCode';
    Share.share('Join my group "${widget.groupData['name']}" on SmartSplit!\n$inviteLink');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.groupData['name'] ?? 'Group'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareInviteLink,
            ),
            if (_selectedTab == 1)
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: _showInviteMemberDialog,
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditGroupDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteGroupConfirmation,
            ),
          ],
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
            tabs: const [
              Tab(text: 'Expenses'),
              Tab(icon: Icon(Icons.group), text: 'Members'),
              Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Expenses Tab
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('expenses')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final expenses = snapshot.data?.docs ?? [];

                if (expenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No expenses yet',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showAddExpenseDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Expense'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index].data() as Map<String, dynamic>;
                    final expenseId = expenses[index].id;
                    final isSettled = expense['settled'] ?? false;
                    final paidByUid = expense['paidBy'];

                    // Fetch paidBy user's name or email
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(paidByUid).get(),
                      builder: (context, userSnapshot) {
                        String paidByName = 'Unknown User';
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          paidByName = userSnapshot.data!['name'] ?? userSnapshot.data!['email'] ?? 'Unknown User';
                        }

                        return GestureDetector(
                          onTap: () => _showExpenseDetailDialog(expenseId),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isSettled 
                                      ? [Colors.grey.shade100, Colors.grey.shade50]
                                      : [Colors.white, Colors.blue.shade50],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: isSettled 
                                                ? Colors.grey.shade300
                                                : Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            isSettled ? Icons.check_circle : Icons.receipt,
                                            color: isSettled 
                                                ? Colors.grey.shade600
                                                : Colors.blue.shade700,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                expense['title'] ?? 'No Title',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSettled ? Colors.grey.shade600 : Colors.black87,
                                                  decoration: isSettled ? TextDecoration.lineThrough : TextDecoration.none,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Paid by $paidByName',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isSettled ? Colors.grey.shade500 : Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '\$${expense['amount']?.toStringAsFixed(2) ?? '0.00'}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isSettled ? Colors.grey.shade500 : Colors.green.shade700,
                                                decoration: isSettled ? TextDecoration.lineThrough : TextDecoration.none,
                                              ),
                                            ),
                                            if (expense['perPersonAmount'] != null)
                                              Text(
                                                '\$${expense['perPersonAmount'].toStringAsFixed(2)} each',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isSettled ? Colors.grey.shade400 : Colors.grey.shade500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (expense['description'] != null && expense['description'].isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSettled ? Colors.grey.shade100 : Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          expense['description'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSettled ? Colors.grey.shade600 : Colors.grey.shade700,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: isSettled ? Colors.grey.shade400 : Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          expense['createdAt'] != null
                                              ? '${DateTime.fromMillisecondsSinceEpoch(expense['createdAt'].millisecondsSinceEpoch).toLocal().toString().split(' ')[0]}'
                                              : 'Unknown date',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSettled ? Colors.grey.shade400 : Colors.grey.shade500,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isSettled)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Settled',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            isSettled ? Icons.undo : Icons.check_circle_outline,
                                            color: isSettled ? Colors.orange.shade600 : Colors.green.shade600,
                                          ),
                                          onPressed: () => _toggleExpenseSettledStatus(
                                            expenseId,
                                            isSettled,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),

            // Members Tab
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where(FieldPath.documentId, whereIn: widget.groupData['members'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final members = snapshot.data?.docs ?? [];
                final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final memberDoc = members[index];
                    final member = memberDoc.data() as Map<String, dynamic>;
                    final memberId = memberDoc.id;
                    final balance = _balances[memberId] ?? 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            (member['name'] as String?)?.isNotEmpty == true
                                ? (member['name'] as String)[0].toUpperCase()
                                : (member['email'] as String).substring(0, 1).toUpperCase(),
                          ),
                        ),
                        title: Text(
                          (member['name'] as String?)?.isNotEmpty == true
                              ? member['name']
                              : member['email'] ?? 'Unknown User',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['uid'] == widget.groupData['createdBy']
                                  ? 'Group Admin'
                                  : 'Member',
                            ),
                            Row(
                              children: [
                                Icon(Icons.payments, size: 16, color: Colors.blue),
                                SizedBox(width: 4),
                                Text('Paid: \$${(balance > 0 ? balance : 0).toStringAsFixed(2)}'),
                                SizedBox(width: 12),
                                Icon(Icons.money_off, size: 16, color: Colors.red),
                                SizedBox(width: 4),
                                Text('Owes: \$${(-balance > 0 ? -balance : 0).toStringAsFixed(2)}'),
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

            // Chat Tab
            Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.groupId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Something went wrong'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final messages = snapshot.data?.docs ?? [];
                      final currentUser = FirebaseAuth.instance.currentUser;

                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index].data() as Map<String, dynamic>;
                          final isMe = message['senderId'] == currentUser?.uid;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['text'] ?? '',
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message['senderEmail'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isMe ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: _selectedTab == 0
            ? FloatingActionButton(
                onPressed: _showAddExpenseDialog,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  void _showEditGroupDialog() async {
    final isAdmin = FirebaseAuth.instance.currentUser?.uid == widget.groupData['createdBy'];
    if (!isAdmin) return;
    final nameController = TextEditingController(text: widget.groupData['name']);
    final descController = TextEditingController(text: widget.groupData['description']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
                'name': nameController.text.trim(),
                'description': descController.text.trim(),
                'lastUpdated': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              setState(() {
                widget.groupData['name'] = nameController.text.trim();
                widget.groupData['description'] = descController.text.trim();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group updated!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupConfirmation() {
    final isAdmin = FirebaseAuth.instance.currentUser?.uid == widget.groupData['createdBy'];
    if (!isAdmin) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).delete();
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group deleted!'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLeaveGroupConfirmation() {
    final isAdmin = FirebaseAuth.instance.currentUser?.uid == widget.groupData['createdBy'];
    if (isAdmin) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
                'members': FieldValue.arrayRemove([uid]),
              });
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You left the group.'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetailDialog(String expenseId) async {
    final expenseDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('expenses')
        .doc(expenseId)
        .get();
    final expense = expenseDoc.data() ?? {};
    final paidByUid = expense['paidBy'];
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(paidByUid).get();
    final paidByName = userDoc['name'] ?? userDoc['email'] ?? 'Unknown User';
    final isSettled = expense['settled'] ?? false;
    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
    final members = (groupDoc.data()?['members'] as List<dynamic>) ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.receipt_long, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Expanded(child: Text(expense['title'] ?? 'Expense Detail')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount:  \$${expense['amount']?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Paid by: $paidByName'),
              if (expense['description'] != null && expense['description'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Description:', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(expense['description']),
              ],
              const SizedBox(height: 12),
              Text('Per Person:', style: const TextStyle(fontWeight: FontWeight.bold)),
              ...members.map((m) => FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(m).get(),
                builder: (context, snap) {
                  final name = snap.hasData && snap.data!.exists ? (snap.data!['name'] ?? snap.data!['email'] ?? 'User') : 'User';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.blue.shade400),
                        const SizedBox(width: 6),
                        Text(name, style: const TextStyle(fontSize: 14)),
                        const Spacer(),
                        Text('\$${expense['perPersonAmount']?.toStringAsFixed(2) ?? '0.00'}'),
                      ],
                    ),
                  );
                },
              )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(expense['createdAt'] != null ? '${DateTime.fromMillisecondsSinceEpoch(expense['createdAt'].millisecondsSinceEpoch).toLocal().toString().split(' ')[0]}' : 'Unknown date', style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              if (isSettled)
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 6),
                    const Text('Settled', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!isSettled)
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                await _toggleExpenseSettledStatus(expenseId, false);
                Navigator.pop(context);
              },
              label: const Text('Settle'),
            ),
          if (isSettled)
            ElevatedButton.icon(
              icon: const Icon(Icons.undo),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                await _toggleExpenseSettledStatus(expenseId, true);
                Navigator.pop(context);
              },
              label: const Text('Unsettle'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _expenseTitleController.dispose();
    _expenseAmountController.dispose();
    _expenseDescriptionController.dispose();
    _chatController.dispose();
    _inviteEmailController.dispose();
    super.dispose();
  }
} 