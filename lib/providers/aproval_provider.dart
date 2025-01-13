import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:toastification/toastification.dart';

class AprovalProvider extends ChangeNotifier {
  List<User> registeredUsers = [];
  bool isLoading = true;
  List<int> selectedIndices = [];
  List<String> userIds = [];
  List<String> team1 = [];
  List<String> team2 = [];
  List uid = [];

  bool addedToTeam1 = false;
  bool addedToTeam2 = false;

  Future<List<User>> eventRegisteredUsers(
    Event event,
    BuildContext context,
  ) async {
    try {
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .get();

      if (!eventSnapshot.exists) {
        toastification.show(
          context: context,
          title: Text('Document does not exist'),
          autoCloseDuration: const Duration(seconds: 5),
        );
      }

      List<dynamic> registeredUsersArray = eventSnapshot['registered_users'];

      userIds =
          registeredUsersArray.map((user) => (user)['uid'] as String).toList();

      if (userIds.isEmpty) {
        return [];
      }

      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: userIds)
          .get();

      List<User> users = userQuery.docs.map((doc) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return registeredUsers = users;
    } catch (e) {
      toastification.show(
        context: context,
        title: Text('Users Not Found'),
        autoCloseDuration: const Duration(seconds: 5),
      );
      return [];
    }
  }

  // void getUsers() async {
  //   try {
  //     List<User> users = await eventRegisteredUsers();

  //     registeredUsers = users;
  //     isLoading = false;

  //     print(userIds);
  //   } catch (e) {
  //     isLoading = false;

  //     print('Error fetching users: $e');
  //   }
  // }

  Future<void> updateTeamInFirestore(Event event, String teamField,
      List<String> teamUIDs, String matchId) async {
    try {
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .get();

      if (!eventSnapshot.exists) {
        throw Exception('Event doc do not exist');
      }

      List<dynamic> matches = eventSnapshot['matches'] ?? [];

      int matchIndex =
          matches.indexWhere((match) => match['matchId'] == matchId);

      if (matchIndex != -1) {
        matches[matchIndex][teamField] = teamUIDs;

        await FirebaseFirestore.instance
            .collection('events')
            .doc(event.id)
            .update({'matches': matches});

        print('$teamField updated sucessfully for matchId ${matchId}');
      } else {
        print("Match with matchId: ${matchId} not found");
      }
    } catch (e) {
      print("Error updating teams: $e");
    }
  }
}
