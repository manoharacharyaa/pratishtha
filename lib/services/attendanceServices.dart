import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendaceServices {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> addHeadorCohead(String currentAcademicYear, String deptName,
      String deptHeadorCoheadName) async {
    try {
      // Reference to the Tech document in the attendance collection
      final DocumentReference docRef = firestore
          .collection('attendance')
          .doc(currentAcademicYear)
          .collection("departments")
          .doc(deptName);

      // Get the document snapshot
      final DocumentSnapshot docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // If document doesn't exist, create it with 'member1'
        await docRef.set({
          'member1': deptHeadorCoheadName,
        });
        print('Document created with member1: $deptHeadorCoheadName');
        return "Member Added";
      } else {
        // If document exists, check existing members
        final data = docSnapshot.data() as Map<String, dynamic>;
        final int currentMemberCount =
            data.keys.where((key) => key.startsWith('member')).length;

        // Add the next member field (e.g., member2, member3)
        final String nextMemberKey = 'member${currentMemberCount + 1}';
        await docRef.update({
          nextMemberKey: deptHeadorCoheadName,
        });
        print('$nextMemberKey added with value: $deptHeadorCoheadName');
        return "Member Updated";
      }
    } catch (e) {
      print('Error adding head or co-head: $e');
      return "Failed to add member";
    }
  }

  Future<String?> fetchUsersDepartment(
      String? first_name, String? last_name, String currentAcademicYear) async {
    try {
      String name = "$first_name $last_name";
      if (name == null) return null;

      final teamQuery = await firestore
          .collection('attendance')
          .doc(currentAcademicYear)
          .collection('departments')
          .get();

      for (var team in teamQuery.docs) {
        final teamData = team.data();

        for (var field in teamData.entries) {
          if (field.value == name) {
            return team.id;
          }
        }
      }
      return null; // No team found
    } catch (e) {
      debugPrint('Error fetching team: $e');
      return null; // Return null on error
    }
  }

  Future<List<Map<String, dynamic>>> getAllVolunteers(
      String currentAcademicYear) async {
    try {
      final List<Map<String, dynamic>> allVolunteers = [];

      // Reference to the departments collection
      final departmentsSnapshot = await firestore
          .collection('attendance')
          .doc(currentAcademicYear)
          .collection('departments')
          .get();

      // Iterate through each department (team)
      for (var teamDoc in departmentsSnapshot.docs) {
        final teamId = teamDoc.id;

        // Fetch volunteers from the team's volunteers collection
        final volunteersSnapshot = await firestore
            .collection('attendance')
            .doc(currentAcademicYear)
            .collection('departments')
            .doc(teamId)
            .collection('volunteers')
            .get();

        for (var volunteerDoc in volunteersSnapshot.docs) {
          final volunteerData = volunteerDoc.data();
          final volunteer = {
            'teamId':
                teamId, // Add the team ID to know the team the volunteer belongs to
            'docId': volunteerDoc.id,
            'class': volunteerData['class'],
            'rollno': volunteerData['rollNo'],
            'PRN': volunteerData['PRN'],
            'Branch': volunteerData['branch'],
            'SakecId':volunteerData['sakec_id'],
            'name': volunteerData['name'] ?? 'Unknown',
            'attendance': volunteerData['attendanceStatus'] ?? [],
          };

          allVolunteers.add(volunteer);
        }
      }

      return allVolunteers;
    } catch (e) {
      print('Error fetching all volunteers: $e');
      return [];
    }
  }

  Future<String> addVolunteerDetails(
    String firstName,
    String lastName,
    String branch,
    String classDiv,
    String PRN,
    String sakecmail,
    int rollNo,
    String currentAcademicYear,
    String teamId,
  ) async {
    try {
      // Reference to the `volunteers` collection inside the user's team
      final collectionPath = FirebaseFirestore.instance
          .collection('attendance')
          .doc(currentAcademicYear)
          .collection('departments')
          .doc(teamId)
          .collection('volunteers');

      // Concatenate first name and last name
      String fullName = "$firstName $lastName";

      // Add a new document
      await collectionPath.add({
        'name': fullName,
        'branch': branch,
        'class': classDiv,
        'rollNo': rollNo,
        'sakec_id': sakecmail,
        'PRN': PRN,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return "success"; // Return success if the operation completes
    } catch (error) {
      return "failed"; // Return failed if an error occurs
    }
  }

  Future<String> addVoulunteerAttendance(
      String currentAcademicYear,
      String teamId,
      List<String> volunteerids,
      List<bool> volunteerAttendanceStatus) async {
    if (volunteerids.length != volunteerAttendanceStatus.length) {
      return "Failed";
    }

    try {
      final collectionPath = FirebaseFirestore.instance
          .collection('attendance')
          .doc(currentAcademicYear)
          .collection('departments')
          .doc(teamId)
          .collection('volunteers');

      // Get today's date formatted as DD-MM-YYYY
      String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      for (int i = 0; i < volunteerids.length; i++) {
        String docId = volunteerids[i];
        bool status = volunteerAttendanceStatus[i];

        DocumentReference docRef = collectionPath.doc(docId);

        await docRef.update({
          'attendanceStatus': FieldValue.arrayUnion([
            {todayDate: status}
          ])
        });
      }
      return "Sucess";
    } catch (e) {
      print("Error in add volunteer attendance record : $e");
      return "Failed";
    }
  }

  Future<List<Map<String, String>>> getVolunteerList(
      String currentAcademicYear, String teamId) async {
    try {
      // Reference to the `volunteers` collection inside the specific team
      final collectionPath = firestore
          .collection('attendance')
          .doc(currentAcademicYear)
          .collection('departments')
          .doc(teamId)
          .collection('volunteers');

      // Fetch the documents in the collection
      final snapshot = await collectionPath.get();

      List<Map<String, String>> volunteerList = [];

      // Iterate through each document and collect the document ID and student name
      for (var doc in snapshot.docs) {
        String docId = doc.id;
        String name = doc.data()['name'] ?? 'Unknown';

        volunteerList.add({'docId': docId, 'name': name});
      }

      return volunteerList;
    } catch (e) {
      print('Error fetching volunteer list: $e');
      return [];
    }
  }
}
