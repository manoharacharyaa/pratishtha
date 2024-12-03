import 'package:flutter/material.dart';
import 'package:pratishtha/screens/home/olympusLeaderboardPage.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => olympusLeaderboardPage()),
              );
            },
            child: Text("My Event Posting"),
          ),
        ],
      ),
    );
  }
}
