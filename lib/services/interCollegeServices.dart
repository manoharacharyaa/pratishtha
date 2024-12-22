import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/models/cricketInterCollege.dart';
import 'package:pratishtha/models/footballInterCollege.dart';
import 'package:pratishtha/models/interCollege.dart';
import 'package:pratishtha/models/interCollegeBoysVolleyballMatch.dart';
import 'package:pratishtha/models/interCollegeGirlsVolleyballMatch.dart';
import 'package:pratishtha/models/interCollegeTugOfWarMatch.dart';
import 'package:pratishtha/models/kabaddiInterCollege.dart';
import 'package:uuid/uuid.dart';

class InterCollegeServices {
  Future<String> addCollegeForInter(
    String collegeName,
    String collegeShortName,
    String collegeLocation,
    File imageFile,
  ) async {
    try {
      // Calculate the academic year
      DateTime now = DateTime.now();
      int currentYear = now.year;
      String academicYear;
      if (now.month >= 6) {
        academicYear = "$currentYear-${currentYear + 1}";
      } else {
        academicYear = "${currentYear - 1}-$currentYear";
      }

      String uniqueCode = Uuid().v4().substring(0, 6);

      // Create a unique filename with timestamp to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'colleges/${timestamp}_${collegeName.replaceAll(' ', '_')}.jpg';

      // Reference to Firebase Storage with the unique filename
      final storageRef = FirebaseStorage.instance.ref().child(fileName);

      // Set proper metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'collegeName': collegeName,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload image to Firebase Storage with metadata
      final uploadTask = await storageRef.putFile(imageFile, metadata);

      if (uploadTask.state == TaskState.success) {
        // Get the image URL after upload
        String imageUrl = await uploadTask.ref.getDownloadURL();

        // Add college document to Firestore
        final collegeColl = FirebaseFirestore.instance.collection('colleges');

        // Add the document with initial data
        DocumentReference docRef = await collegeColl.add({
          'unique_code': uniqueCode,
          'collegeName': collegeName,
          'collegeShortName': collegeShortName,
          'collegeLocation': collegeLocation,
          'score': 0,
          'soft_delete': false,
          'imageUrl': imageUrl,
          'academicYear': academicYear,
          'matchesWon': {}, // Initialize empty matchesWon map
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update the document with its ID
        await docRef.update({'id': docRef.id});

        return "Success";
      } else {
        throw Exception('Upload failed: ${uploadTask.state}');
      }
    } catch (e) {
      print('Error adding college: $e');
      return "Failed";
    }
  }

  Future<String> updateCollege(
    String collegeName,
    String collegeId,
    TextEditingController updatedScoreController,
  ) async {
    try {
      // Parse the entered score
      int scoreChange = int.tryParse(updatedScoreController.text) ?? 0;

      // Fetch the current score from Firestore
      DocumentSnapshot collegeDoc = await FirebaseFirestore.instance
          .collection('colleges')
          .doc(collegeId)
          .get();

      if (!collegeDoc.exists) {
        return "Failed to update score: College not found.";
      }

      // Perform addition or subtraction
      int currentScore = collegeDoc['score'];
      int newScore = currentScore + scoreChange;

      // Ensure score doesn't drop below 0
      if (newScore < 0) {
        newScore = 0;
      }

      // Update the score in Firestore
      await FirebaseFirestore.instance
          .collection('colleges')
          .doc(collegeId)
          .update({
        'score': newScore,
      });

      // Clear the text controller
      updatedScoreController.clear();

      // Return success message
      return "Score updated for $collegeName to $newScore.";
    } catch (e) {
      print('Error updating score: $e');
      return "Failed to update score.";
    }
  }

  Future<List<InterCollege>> getAllCollegesInter() async {
    try {
      final collegeColl = FirebaseFirestore.instance.collection('colleges');
      final snapshot = await collegeColl
          .where('soft_delete', isEqualTo: false)
          // .orderBy('score', descending: true)
          .get();

      List<InterCollege> colleges = [];
      for (var doc in snapshot.docs) {
        colleges.add(InterCollege.fromMap(doc.data(), doc.id));
      }

      return colleges;
    } catch (e) {
      print('Error fetching colleges: $e');
      return [];
    }
  }

  Future<List<String>> fetchImagesFromFirebase() async {
    final ListResult result =
        await FirebaseStorage.instance.ref('interCollege_Banners').listAll();
    final List<String> urls = await Future.wait(
      result.items.map((item) => item.getDownloadURL()).toList(),
    );
    return urls; // Return the list of URLs
  }

  Future<String> recordCricketMatch({
    required String academicYear, // e.g., "2024-2025"
    required String matchLocation, // Like Azad Maidan, CSMT
    required String matchType, //Like GroupStage, RO16, QF,SF,Final
    required String matchTime, // Like 1.30 PM
    required String matchDayDate, // Like Sun, 24 Dec 2024
    required String teamBattingFirst, // Team batting first
    required String teamBattingSecond, // Team batting second
    required String teamBattingFirstScore, // Format: "127/8"
    required String teamBattingSecondScore, // Format: "120/7"
    required String teamBattingFirstTopBatter, // e.g., "PlayerName: 45(30)"
    required String
        teamBattingFirstTopBowlerPerformance, // e.g., "PlayerName: 3-20"
    required String teamBattingSecondTopBatter, // e.g., "PlayerName: 50(40)"
    required String
        teamBattingSecondTopBowlerPerformance, // e.g., "PlayerName: 4-25"
    required String teamBattingFirstLogoUrl, // Firebase storage URL
    required String teamBattingSecondLogoUrl, // Firebase storage URL
    required String teamBattingFirstId,
    required String teamBattingSecondId,
  }) async {
    try {
      String winningTeamDcId;
      int teamBattingFirstRuns = int.parse(teamBattingFirstScore.split('/')[0]);
      int.parse(teamBattingFirstScore.split('/')[1]);

      int teamBattingSecondRuns =
          int.parse(teamBattingSecondScore.split('/')[0]);
      int teamBattingSecondWickets =
          int.parse(teamBattingSecondScore.split('/')[1]);

      // Determine the result
      String result;
      if (teamBattingFirstRuns > teamBattingSecondRuns) {
        // Team Batting First wins by runs
        int runMargin = teamBattingFirstRuns - teamBattingSecondRuns;
        winningTeamDcId = teamBattingFirstId;
        result = "$teamBattingFirst won by $runMargin runs";
      } else {
        // Team Batting Second wins by wickets
        int wicketMargin = 10 - teamBattingSecondWickets;
        winningTeamDcId = teamBattingSecondId;
        result = "$teamBattingSecond won by $wicketMargin wickets";
      }

      DocumentReference teamDocRef = FirebaseFirestore.instance
          .collection('colleges')
          .doc(winningTeamDcId);

      DocumentSnapshot docSnapshot = await teamDocRef.get();

      Map<String, dynamic> matchesWon = docSnapshot['matchesWon'] != null
          ? Map<String, dynamic>.from(docSnapshot['matchesWon'])
          : {};

      matchesWon['cricket'] = (matchesWon['cricket'] ?? 0) + 1;

      await teamDocRef.update({
        'matchesWon': matchesWon,
      });

      print("Updated matchesWon for cricket successfully!");

      CollectionReference cricketColl = FirebaseFirestore.instance
          .collection('intercollege_sports') // Root collection
          .doc(academicYear) // Document for the academic year
          .collection('cricket'); // Cricket matches collection

      // Add a new document for the match
      await cricketColl.add({
        'teamBattingFirst': teamBattingFirst,
        'teamBattingSecond': teamBattingSecond,
        'teamBattingFirstScore': teamBattingFirstScore,
        'teamBattingSecondScore': teamBattingSecondScore,
        'teamBattingFirstTopBatter': teamBattingFirstTopBatter,
        'teamBattingFirstTopBowlerPerformance':
            teamBattingFirstTopBowlerPerformance,
        'teamBattingSecondTopBatter': teamBattingSecondTopBatter,
        'teamBattingSecondTopBowlerPerformance':
            teamBattingSecondTopBowlerPerformance,
        'teamBattingFirstLogoUrl': teamBattingFirstLogoUrl,
        'teamBattingSecondLogoUrl': teamBattingSecondLogoUrl,
        'result': result, // Store the calculated result
        'matchLocation': matchLocation,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'matchType': matchType,
        'timestamp':
            FieldValue.serverTimestamp(), // Record the match date and time
        'soft_delete': false,
      });

      return "Cricket Match Record Added Successfully";
    } catch (e) {
      print("Error recording match: $e");
      return "Failed to record match";
    }
  }

  Future<String> recordFootballMatch({
    required String academicYear, // e.g., "2024-2025"
    required String matchLocation, // Like Azad Maidan, CSMT
    required String matchType, // Like GroupStage, RO16, QF, SF, Final
    required String matchTime, // Like 1.30 PM
    required String matchDayDate, // Like Sun, 24 Dec 2024
    required String teamAName, // Team A name
    required String teamBName, // Team B name
    required int teamAGoals, // Goals scored by Team A
    required int teamBGoals, // Goals scored by Team B
    String? teamATopGoalScorer, // Optional: Top scorer for Team A
    String? teamBTopGoalScorer, // Optional: Top scorer for Team B
    required String teamALogoUrl, // Firebase storage URL for Team A logo
    required String teamBLogoUrl, // Firebase storage URL for Team B logo
    required String
        teamAId, // Document ID for Team A in the colleges collection
    required String
        teamBId, // Document ID for Team B in the colleges collection
  }) async {
    try {
      String result;
      String winningTeamDcId = "";

      // Determine the result
      if (teamAGoals > teamBGoals) {
        result = "$teamAName won by ${teamAGoals - teamBGoals} goals";
        winningTeamDcId = teamAId;
      } else if (teamBGoals > teamAGoals) {
        result = "$teamBName won by ${teamBGoals - teamAGoals} goals";
        winningTeamDcId = teamBId;
      } else {
        result = "Match drawn";
      }

      if (winningTeamDcId.isNotEmpty) {
        DocumentReference teamDocRef = FirebaseFirestore.instance
            .collection('colleges')
            .doc(winningTeamDcId);

        DocumentSnapshot docSnapshot = await teamDocRef.get();

        Map<String, dynamic> matchesWon = docSnapshot['matchesWon'] != null
            ? Map<String, dynamic>.from(docSnapshot['matchesWon'])
            : {};

        matchesWon['football'] = (matchesWon['football'] ?? 0) + 1;

        await teamDocRef.update({
          'matchesWon': matchesWon,
        });

        print("Updated matchesWon for football successfully!");
      }

      CollectionReference footballColl = FirebaseFirestore.instance
          .collection('intercollege_sports') // Root collection
          .doc(academicYear) // Document for the academic year
          .collection('football'); // Football matches collection

      // Add a new document for the match
      await footballColl.add({
        'teamAName': teamAName,
        'teamBName': teamBName,
        'teamAGoals': teamAGoals,
        'teamBGoals': teamBGoals,
        'teamATopGoalScorer': teamATopGoalScorer ?? "None",
        'teamBTopGoalScorer': teamBTopGoalScorer ?? "None",
        'teamALogoUrl': teamALogoUrl,
        'teamBLogoUrl': teamBLogoUrl,
        'result': result,
        'matchLocation': matchLocation,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'matchType': matchType,
        'timestamp': FieldValue.serverTimestamp(),
        'soft_delete': false,
      });

      return "Football Match Record Added Successfully";
    } catch (e) {
      print("Error recording football match: $e");
      return "Failed to record football match";
    }
  }

  // Record Kabaddi Match
  Future<String> recordKabaddiMatch({
    required String academicYear, // e.g., "2024-2025"
    required String matchLocation, // Like Azad Maidan, CSMT
    required String matchType, // Like GroupStage, RO16, QF, SF, Final
    required String matchTime, // Like 1.30 PM
    required String matchDayDate, // Like Sun, 24 Dec 2024
    required String teamAName, // Team A name
    required String teamBName, // Team B name
    required int teamAPoints, // Points scored by Team A
    required int teamBPoints, // Points scored by Team B
    String? teamATopRaider, // Optional: Top raider for Team A
    String? teamATopDefender, // Optional: Top defender for Team A
    String? teamBTopRaider, // Optional: Top raider for Team B
    String? teamBTopDefender, // Optional: Top defender for Team B
    required String teamALogoUrl, // Firebase storage URL for Team A logo
    required String teamBLogoUrl, // Firebase storage URL for Team B logo
    required String
        teamAId, // Document ID for Team A in the colleges collection
    required String
        teamBId, // Document ID for Team B in the colleges collection
  }) async {
    try {
      String result;
      String winningTeamDcId = "";

      // Determine the result
      if (teamAPoints > teamBPoints) {
        result = "$teamAName won by ${teamAPoints - teamBPoints} points";
        winningTeamDcId = teamAId;
      } else if (teamBPoints > teamAPoints) {
        result = "$teamBName won by ${teamBPoints - teamAPoints} points";
        winningTeamDcId = teamBId;
      } else {
        result = "Match drawn";
      }

      if (winningTeamDcId.isNotEmpty) {
        DocumentReference teamDocRef = FirebaseFirestore.instance
            .collection('colleges')
            .doc(winningTeamDcId);

        DocumentSnapshot docSnapshot = await teamDocRef.get();

        Map<String, dynamic> matchesWon = docSnapshot['matchesWon'] != null
            ? Map<String, dynamic>.from(docSnapshot['matchesWon'])
            : {};

        matchesWon['kabaddi'] = (matchesWon['kabaddi'] ?? 0) + 1;

        await teamDocRef.update({
          'matchesWon': matchesWon,
        });

        print("Updated matchesWon for kabaddi successfully!");
      }

      CollectionReference kabaddiColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('kabaddi');

      // Add a new document for the match
      await kabaddiColl.add({
        'teamAName': teamAName,
        'teamBName': teamBName,
        'teamAPoints': teamAPoints,
        'teamBPoints': teamBPoints,
        'teamATopRaider': teamATopRaider ?? "None",
        'teamATopDefender': teamATopDefender ?? "None",
        'teamBTopRaider': teamBTopRaider ?? "None",
        'teamBTopDefender': teamBTopDefender ?? "None",
        'teamALogoUrl': teamALogoUrl,
        'teamBLogoUrl': teamBLogoUrl,
        'result': result,
        'matchLocation': matchLocation,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'matchType': matchType,
        'timestamp': FieldValue.serverTimestamp(),
        'soft_delete': false,
      });

      return "Kabaddi Match Record Added Successfully";
    } catch (e) {
      print("Error recording kabaddi match: $e");
      return "Failed to record kabaddi match";
    }
  }

  Future<List<InterCollegeCricketMatch>> getAllInterCollegeCricketMatches(
      String currentAcademicYear) async {
    try {
      // Query the Firestore collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("intercollege_sports")
          .doc(currentAcademicYear)
          .collection('cricket')
          // .where('soft_delete', isEqualTo: false)
          .get();

      // Map the documents to a list of `InterCollegeCricketMatch`
      return querySnapshot.docs
          .map((doc) => InterCollegeCricketMatch.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Log the error
      print("Error in getting cricket matches: $e");

      // Return an empty list to indicate failure gracefully
      return [];
    }
  }

  Future<List<InterCollegeFootballMatch>> getAllInterCollegeFootballMatches(
      String currentAcademicYear) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("intercollege_sports")
          .doc(currentAcademicYear)
          .collection('football')
          .where('soft_delete', isEqualTo: false)
          .get();
      return querySnapshot.docs
          .map((doc) => InterCollegeFootballMatch.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error in getting football matches: $e");
      return [];
    }
  }

  Future<List<InterCollegeKabaddiMatch>> getAllInterCollegeKabaddiMatches(
      String currentAcademicYear) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("intercollege_sports")
          .doc(currentAcademicYear)
          .collection('kabaddi')
          .where('soft_delete', isEqualTo: false)
          .get();
      return querySnapshot.docs
          .map((doc) => InterCollegeKabaddiMatch.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error in getting kabaddi matches: $e");
      return [];
    }
  }

  Future<String> recordVolleyballBoysMatch({
    required String academicYear,
    required String matchLocation,
    required String matchType,
    required String matchTime,
    required String matchDayDate,
    required String teamAName,
    required String teamBName,
    required String teamAScore,
    required String teamBScore,
    required String teamALogoUrl,
    required String teamBLogoUrl,
  }) async {
    try {
      String result;
      if (int.parse(teamAScore) > int.parse(teamBScore)) {
        result =
            "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
      } else {
        result =
            "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
      }

      CollectionReference volleyballColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('volleyball_boys');

      // Add the document and get the document reference
      DocumentReference docRef = await volleyballColl.add({
        'academicYear': academicYear,
        'matchLocation': matchLocation,
        'matchType': matchType,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'teamAName': teamAName,
        'teamBName': teamBName,
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'teamALogoUrl': teamALogoUrl,
        'teamBLogoUrl': teamBLogoUrl,
        'result': result,
        'soft_delete': false,
      });

      // Update the document to include its ID as a field
      await docRef.update({'id': docRef.id});

      return "Volleyball Boys Match Recorded Successfully";
    } catch (e) {
      print("Error recording volleyball boys match: $e");
      return "Failed to record volleyball boys match";
    }
  }

  Future<String> recordVolleyballGirlsMatch({
    required String academicYear,
    required String matchLocation,
    required String matchType,
    required String matchTime,
    required String matchDayDate,
    required String teamAName,
    required String teamBName,
    required String teamAScore,
    required String teamBScore,
    required String teamALogoUrl,
    required String teamBLogoUrl,
  }) async {
    try {
      String result;
      if (int.parse(teamAScore) > int.parse(teamBScore)) {
        result =
            "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
      } else {
        result =
            "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
      }

      CollectionReference volleyballColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('volleyball_girls');

      // Add the document and get the document reference
      DocumentReference docRef = await volleyballColl.add({
        'academicYear': academicYear,
        'matchLocation': matchLocation,
        'matchType': matchType,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'teamAName': teamAName,
        'teamBName': teamBName,
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'teamALogoUrl': teamALogoUrl,
        'teamBLogoUrl': teamBLogoUrl,
        'result': result,
        'soft_delete': false,
      });

      // Update the document to include its ID as a field
      await docRef.update({'id': docRef.id});

      return "Volleyball Girls Match Recorded Successfully";
    } catch (e) {
      print("Error recording volleyball girls match: $e");
      return "Failed to record volleyball girls match";
    }
  }

  Future<String> recordTugOfWarMatch({
    required String academicYear,
    required String matchLocation,
    required String matchType,
    required String matchTime,
    required String matchDayDate,
    required String teamAName,
    required String teamBName,
    required String teamAScore,
    required String teamBScore,
    required String teamALogoUrl,
    required String teamBLogoUrl,
  }) async {
    try {
      String result;
      if (teamAScore.compareTo(teamBScore) > 0) {
        result =
            "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
      } else {
        result =
            "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
      }

      CollectionReference tugOfWarColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('tug_of_war');

      DocumentReference docRef = await tugOfWarColl.add({
        'academicYear': academicYear,
        'matchLocation': matchLocation,
        'matchType': matchType,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'teamAName': teamAName,
        'teamBName': teamBName,
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'teamALogoUrl': teamALogoUrl,
        'teamBLogoUrl': teamBLogoUrl,
        'result': result,
        'soft_delete': false,
      });

      // Now include the document ID as a field in the document
      await docRef.update({
        'matchId': docRef.id, // Adding the document ID as matchId
      });

      return "Tug of War Match Recorded Successfully";
    } catch (e) {
      print("Error recording tug of war match: $e");
      return "Failed to record tug of war match";
    }
  }

  Future<List<InterCollegeVlleyballBoysMatch>> getAllVolleyballBoysMatches(
      String currentAcademicYear) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("intercollege_sports")
          .doc(currentAcademicYear)
          .collection('volleyball_boys')
          .where('soft_delete', isEqualTo: false)
          .get();

      return querySnapshot.docs
          .map((doc) => InterCollegeVlleyballBoysMatch.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error in getting volleyball boys matches: $e");
      return [];
    }
  }

  Future<List<InterCollegeVlleyballGirlsMatch>> getAllVolleyballGirlsMatches(
      String currentAcademicYear) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("intercollege_sports")
          .doc(currentAcademicYear)
          .collection('volleyball_girls')
          .where('soft_delete', isEqualTo: false)
          .get();

      return querySnapshot.docs
          .map((doc) => InterCollegeVlleyballGirlsMatch.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error in getting volleyball girls matches: $e");
      return [];
    }
  }

  Future<List<InterCollegeTugOfWarMatch>> getAllTugOfWarMatches(
      String currentAcademicYear) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("intercollege_sports")
          .doc(currentAcademicYear)
          .collection('tug_of_war')
          .where('soft_delete', isEqualTo: false)
          .get();

      return querySnapshot.docs
          .map((doc) => InterCollegeTugOfWarMatch.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error in getting tug of war matches: $e");
      return [];
    }
  }
}
