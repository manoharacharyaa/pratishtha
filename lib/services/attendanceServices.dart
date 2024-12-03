import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendaceServices {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> addHeadorCohead(
      String currentAcademicYear, String deptName, String deptHeadorCoheadName) async {
    try {
      // Reference to the Tech document in the attendance collection
      final DocumentReference docRef = firestore
          .collection('attendance')
          .doc(currentAcademicYear)
          .collection(deptName)
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
        final int currentMemberCount = data.keys
            .where((key) => key.startsWith('member'))
            .length;

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

}