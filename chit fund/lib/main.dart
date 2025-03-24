import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(ChitFundApp());
}

class ChitFundApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chit Fund Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> members = [];
  double totalFunds = 0.0;
  int chitDuration = 6;
  String? selectedMember;

  void addMember(String name, double amount) {
    setState(() {
      members.add({'name': name, 'amount': amount});
      totalFunds += amount;
    });
  }

  void selectRandomMember() {
    if (members.isNotEmpty) {
      final random = Random();
      int index = random.nextInt(members.length);
      setState(() {
        selectedMember = members[index]['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chit Fund Overview')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Total Funds: \$${totalFunds.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                DropdownButton<int>(
                  value: chitDuration,
                  items: [6, 12, 18].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value Months'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      chitDuration = value!;
                    });
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: selectRandomMember,
                  child: Text('Select Monthly Member'),
                ),
                if (selectedMember != null)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('Selected Member: $selectedMember',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(members[index]['name']),
                  subtitle: Text('Contributed: \$${members[index]['amount']}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddMemberScreen(addMember: addMember),
          ),
        ),
      ),
    );
  }
}

class AddMemberScreen extends StatefulWidget {
  final Function(String, double) addMember;
  AddMemberScreen({required this.addMember});

  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Member')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Member Name'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Contribution Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String name = _nameController.text;
                double amount = double.tryParse(_amountController.text) ?? 0.0;
                if (name.isNotEmpty && amount > 0) {
                  widget.addMember(name, amount);
                  Navigator.pop(context);
                }
              },
              child: Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}
