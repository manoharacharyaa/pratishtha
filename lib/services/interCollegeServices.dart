import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/models/interCollege.dart';
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
        // From June to December: current year to next year
        academicYear = "$currentYear-${currentYear + 1}";
      } else {
        // From January to May: previous year to current year
        academicYear = "${currentYear - 1}-$currentYear";
      }

      String uniqueCode = Uuid().v4().substring(0, 6); // Unique Code

      // Reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('interCollege_Logo/$collegeName.png');

      // Upload image to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for the image to be uploaded
      TaskSnapshot snapshot = await uploadTask;

      // Get the image URL after upload
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Add college document to Firestore
      final collegeColl = FirebaseFirestore.instance.collection('colleges');

      // Add the document without the ID
      DocumentReference docRef = await collegeColl.add({
        'unique_code': uniqueCode,
        'collegeName': collegeName,
        'collegeShortName': collegeShortName,
        'collegeLocation': collegeLocation,
        'score': 0, // Default score
        'soft_delete': false,
        'imageUrl': imageUrl,
        'academicYear': academicYear,
      });

      // Get the ID of the added document
      String docId = docRef.id;

      // Update the document with the ID
      await docRef.update({'id': docId});

      return "Success";
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
      print("Getting all Colleges");
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("colleges")
          .where('soft_delete', isEqualTo: false)
          .get();
      return querySnapshot.docs
          .map((doc) =>
              InterCollege.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error in getAllCollegesInter() method, :${e}");
      return [];
    }
  }

  Future<List<String>> fetchImagesFromFirebase() async {
    final ListResult result =
        await FirebaseStorage.instance.ref('interCollege_Banner').listAll();
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
          .collection('inter_coll') // Root collection
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
      });

      return "Match record added successfully";
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
      });

      return "Kabaddi Match Record Added Successfully";
    } catch (e) {
      print("Error recording kabaddi match: $e");
      return "Failed to record kabaddi match";
    }
  }
}
