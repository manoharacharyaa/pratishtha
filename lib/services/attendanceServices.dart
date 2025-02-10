import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendaceServices {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> addHeadorCohead(String currentAcademicYear, String deptName,
      String deptHeadorCoheadName, dynamic departmentPersonUUid) async {
    try {
      // Log parameters for debugging
      log("Parameters: currentAcademicYear=$currentAcademicYear, deptName=$deptName, "
          "deptHeadorCoheadName=$deptHeadorCoheadName, departmentPersonUUid=$departmentPersonUUid");

      // Reference to the department document
      final DocumentReference deptDocRef = firestore
          .collection('attendance')
          .doc(currentAcademicYear)
          .collection("departments")
          .doc(deptName);

      // Check if the department document exists
      final DocumentSnapshot deptDocSnapshot = await deptDocRef.get();
      log("Department document exists: ${deptDocSnapshot.exists}");

      if (!deptDocSnapshot.exists) {
        // Create new document if it doesn't exist
        await deptDocRef.set({'member1': deptHeadorCoheadName});
        log('New department document created with member1=$deptHeadorCoheadName');
      } else {
        // Add a new member field to the existing document
        final data = deptDocSnapshot.data() as Map<String, dynamic>;
        final int currentMemberCount =
            data.keys.where((key) => key.startsWith('member')).length;
        final String nextMemberKey = 'member${currentMemberCount + 1}';
        await deptDocRef.update({nextMemberKey: deptHeadorCoheadName});
        log('Added $nextMemberKey with value=$deptHeadorCoheadName');
      }

      // Reference to the user document
      final DocumentReference userDocRef =
          firestore.collection("users").doc(departmentPersonUUid);

      // Check if the user document exists
      final DocumentSnapshot userDocSnapshot = await userDocRef.get();
      log("User document exists: ${userDocSnapshot.exists}");

      if (!userDocSnapshot.exists) {
        log("Error: User document with UUID $departmentPersonUUid does not exist.");
        return "User document not found.";
      }

      // Update the isDeptHead field in the user document
      await userDocRef
          .set({'isDeptHead2024_25': true}, SetOptions(merge: true));
      log("Updated isDeptHead2024_25 for user with UUID $departmentPersonUUid");

      return "Member Added/Updated Successfully";
    } catch (e, stackTrace) {
      // Handle exceptions and provide detailed error messages
      if (e is FirebaseException && e.code == 'permission-denied') {
        log("Permission Denied: $e");
        return "Permission Denied: Check Firestore rules.";
      }
      if (e.toString().contains("does not exist")) {
        log("User document not found error: $e");
        return "User document not found.";
      }
      log("Error in addHeadorCohead: $e");
      log("StackTrace: $stackTrace");
      return "Unexpected error: $e";
    }
  }

  Future<String?> fetchUsersDepartment(
      String? first_name, String? last_name, String currentAcademicYear) async {
    try {
      String name = "$first_name $last_name";

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
            'SakecId': volunteerData['sakec_id'],
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

 Future<String> addVolunteerAttendance(
  String currentAcademicYear,
  String teamId,
  List<String> volunteerIds,
  List<bool> volunteerAttendanceStatus,
  String date, // Accept the date as a parameter in "DD-MM-YYYY" format
) async {
  if (volunteerIds.length != volunteerAttendanceStatus.length) {
    return "Failed";
  }

  try {
    final collectionPath = FirebaseFirestore.instance
        .collection('attendance')
        .doc(currentAcademicYear)
        .collection('departments')
        .doc(teamId)
        .collection('volunteers');

    final collectionPath2 = FirebaseFirestore.instance
        .collection('attendance')
        .doc(currentAcademicYear)
        .collection('departments')
        .doc(teamId);

    for (int i = 0; i < volunteerIds.length; i++) {
      String docId = volunteerIds[i];
      bool status = volunteerAttendanceStatus[i];

      // Reference to volunteer document
      DocumentReference docRef = collectionPath.doc(docId);
      DocumentSnapshot snapshot = await docRef.get();

      // Retrieve the attendanceStatus field, or initialize it if it doesn't exist
      List<dynamic> attendanceStatus =
          (snapshot.data() as Map<String, dynamic>?)?['attendanceStatus']
                  as List<dynamic>? ??
              [];

      bool dateFound = false;

      // Check for existing entry and update it
      for (var entry in attendanceStatus) {
        if (entry is Map<String, dynamic> && entry.containsKey(date)) {
          entry[date] = status; // Update the status for the specified date
          dateFound = true;
          break;
        }
      }

      // If the specified date is not found, add a new map entry
      if (!dateFound) {
        attendanceStatus.add({date: status});
      }

      // Update the attendanceStatus field in Firestore
      await docRef.set({
        'attendanceStatus': attendanceStatus,
      }, SetOptions(merge: true)); // Merge to avoid overwriting other fields
    }

    // Update attendanceMarkedDate array in collectionPath2
    await collectionPath2.set({
      'attendanceMarkedDate': FieldValue.arrayUnion([
        {date: true}
      ]),
    }, SetOptions(merge: true)); // Merge to avoid overwriting other fields

    return "Success";
  } catch (e) {
    print("Error in add volunteer attendance record: $e");
    return "Failed";
  }
}

  Future<String> checkTodayAttendanceEntry(
      String currentAcademicYear, String teamId) async {
    try {
      final DocumentReference collectionPath2 = FirebaseFirestore.instance
          .collection('attendance')
          .doc(currentAcademicYear)
          .collection('departments')
          .doc(teamId);

      String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      DocumentSnapshot documentSnapshot = await collectionPath2.get();

      if (documentSnapshot.exists) {
        List<dynamic> attendanceMarkedDate =
            documentSnapshot.get('attendanceMarkedDate') ?? [];

        bool isTodayMarked = attendanceMarkedDate.any((entry) {
          if (entry is Map<String, dynamic>) {
            return entry.containsKey(todayDate) && entry[todayDate] == true;
          }
          return false;
        });

        if (isTodayMarked) {
          return "Yes_Today_Entry";
        } else {
          return "No_Today_Entry";
        }
      } else {
        return "No_Today_Entry";
      }
    } catch (e) {
      print("Error in check today attendance entry: $e");
      return "No_Today_Entry";
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
