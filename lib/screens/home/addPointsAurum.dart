import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/databaseServices.dart';

class AddPointsAurum extends StatefulWidget {
  final String eventId;

  AddPointsAurum({required this.eventId});

  @override
  _AddPointsAurumState createState() => _AddPointsAurumState();
}

class _AddPointsAurumState extends State<AddPointsAurum> {
  final DatabaseServices databaseServices = DatabaseServices();

  // Map to store a TextEditingController for each user.
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> fetchApprovedUsers() async {
    List<Map<String, dynamic>> approvedUsers = [];

    DocumentSnapshot eventDoc =
        await databaseServices.eventCollection.doc(widget.eventId).get();

    if (eventDoc.exists) {
      List<dynamic> approvedUsersList =
          eventDoc.get('approved_users') ?? [];

      for (var userMap in approvedUsersList) {
        String userId = userMap.keys.first; // Extract userId
        int points = userMap[userId]['points'] ?? 0; // Extract points

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          
          String username = userDoc.get('first_name'); // Fetch username

          // Add username & points to list
          approvedUsers.add({
            'userId': userId,
            'username': username,
            'points': points,
          });
        }
      }
    }

    return approvedUsers;
  }

  void assignPoints(eventId, userId, int points) async {
    try {
      await databaseServices.updateUserPoints(eventId, userId, points);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Points assigned successfully!")),
      );
      setState(() {}); // Refresh UI after assigning points
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error assigning points: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Points'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchApprovedUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No approved users found.'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data![index];
                  final userId = user['userId'];
                  // Initialize a controller for this user if one doesn't exist already.
                  if (!_controllers.containsKey(userId)) {
                    _controllers[userId] = TextEditingController(
                      text: user['points'].toString(),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListTile(
                      title: Text(user['username']),
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _controllers[userId],
                          decoration: InputDecoration(
                            labelText: 'Points',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (value) {
                            int points = int.tryParse(value) ?? 0;
                            if (points > 0) {
                              assignPoints(widget.eventId, userId, points);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Enter a valid number")),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all the controllers
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}
