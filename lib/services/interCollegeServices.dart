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
          'matchesWon': {},
           'matchesLost': {},
            'matchesPlayed': {}, // Initialize empty matchesWon map
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
    required String teamBattingSecond,
    required String teamBattingFirstLocation, // Team batting first
    required String teamBattingSecondLocation,// Team batting second
    required String teamBattingFirstScore, // Format: "127/8 (20)"
    required String teamBattingSecondScore, // Format: "120/7 (20)"
    required String teamBattingFirstTopBatter, // e.g., "PlayerName: 45(30)"
    required String teamBattingFirstTopBowlerPerformance, // e.g., "PlayerName: 3-20"
    required String teamBattingSecondTopBatter, // e.g., "PlayerName: 50(40)"
    required String teamBattingSecondTopBowlerPerformance, // e.g., "PlayerName: 4-25"
    required String teamBattingFirstLogoUrl, // Firebase storage URL
    required String teamBattingSecondLogoUrl, // Firebase storage URL
    required String teamBattingFirstId,
    required String teamBattingSecondId,
  }) async {
    try {
      String winningTeamDcId;
      String losingTeamDcId;

      // Parse scores and overs
      RegExp scorePattern = RegExp(r"(\d+)/(\d+)\s*\((\d+)\)");
      var teamBattingFirstMatch = scorePattern.firstMatch(teamBattingFirstScore);
      var teamBattingSecondMatch = scorePattern.firstMatch(teamBattingSecondScore);

      if (teamBattingFirstMatch == null || teamBattingSecondMatch == null) {
        throw Exception("Invalid score format");
      }

      int teamBattingFirstRuns = int.parse(teamBattingFirstMatch.group(1)!);
      int teamBattingFirstWickets = int.parse(teamBattingFirstMatch.group(2)!);
      int teamBattingFirstOvers = int.parse(teamBattingFirstMatch.group(3)!);

      int teamBattingSecondRuns = int.parse(teamBattingSecondMatch.group(1)!);
      int teamBattingSecondWickets = int.parse(teamBattingSecondMatch.group(2)!);
      int teamBattingSecondOvers = int.parse(teamBattingSecondMatch.group(3)!);

      // Determine the result
      String result;
      if (teamBattingFirstRuns > teamBattingSecondRuns) {
        // Team Batting First wins by runs
        int runMargin = teamBattingFirstRuns - teamBattingSecondRuns;
        winningTeamDcId = teamBattingFirstId;
        losingTeamDcId = teamBattingSecondId;
        result = "$teamBattingFirst won by $runMargin runs";
      } else {
        // Team Batting Second wins by wickets
        int wicketMargin = 10 - teamBattingSecondWickets;
        winningTeamDcId = teamBattingSecondId;
        losingTeamDcId = teamBattingFirstId;
        result = "$teamBattingSecond won by $wicketMargin wickets";
      }

     // Update teams' match data
      DocumentReference winningTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(winningTeamDcId);
      DocumentReference losingTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(losingTeamDcId);

      // Get the data for both teams
      DocumentSnapshot winningTeamSnapshot = await winningTeamDoc.get();
      DocumentSnapshot losingTeamSnapshot = await losingTeamDoc.get();

      // Update matchesWon
      Map<String, dynamic> matchesWon = winningTeamSnapshot['matchesWon'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesWon'])
          : {};
      matchesWon['cricket'] = (matchesWon['cricket'] ?? 0) + 1;

      // Update matchesLost
      Map<String, dynamic> matchesLost = losingTeamSnapshot['matchesLost'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesLost'])
          : {};
      matchesLost['cricket'] = (matchesLost['cricket'] ?? 0) + 1;

      // Update matchesPlayed for both teams
      Map<String, dynamic> winningMatchesPlayed = winningTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesPlayed'])
          : {};
      Map<String, dynamic> losingMatchesPlayed = losingTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesPlayed'])
          : {};

      winningMatchesPlayed['cricket'] = (winningMatchesPlayed['cricket'] ?? 0) + 1;
      losingMatchesPlayed['cricket'] = (losingMatchesPlayed['cricket'] ?? 0) + 1;

      // Commit updates
      await winningTeamDoc.update({
        'matchesWon': matchesWon,
        'matchesPlayed': winningMatchesPlayed,
      });

      await losingTeamDoc.update({
        'matchesLost': matchesLost,
        'matchesPlayed': losingMatchesPlayed,
      });

      print("Updated team data successfully!");

      CollectionReference cricketColl = FirebaseFirestore.instance
          .collection('intercollege_sports') // Root collection
          .doc(academicYear) // Document for the academic year
          .collection('cricket'); // Cricket matches collection

      // Add a new document for the match
      DocumentReference docRef = await cricketColl.add({
        'teamBattingFirst': teamBattingFirst,
        'teamBattingSecond': teamBattingSecond,
        'teamBattingFirstScore': teamBattingFirstScore, // Full score with overs
        'teamBattingSecondScore': teamBattingSecondScore, // Full score with overs
        'teamBattingFirstLocation': teamBattingFirstLocation,
        'teamBattingSecondLocation': teamBattingSecondLocation,
        'teamBattingFirstTopBatter': teamBattingFirstTopBatter,
        'teamBattingFirstTopBowlerPerformance': teamBattingFirstTopBowlerPerformance,
        'teamBattingSecondTopBatter': teamBattingSecondTopBatter,
        'teamBattingSecondTopBowlerPerformance': teamBattingSecondTopBowlerPerformance,
        'teamBattingFirstLogoUrl': teamBattingFirstLogoUrl,
        'teamBattingSecondLogoUrl': teamBattingSecondLogoUrl,
        'result': result, // Store the calculated result
        'matchLocation': matchLocation,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'matchType': matchType,
        'timestamp': FieldValue.serverTimestamp(), // Record the match date and time
        'soft_delete': false,
      });

      // Now include the document ID as a field in the document
      await docRef.update({
        'matchId': docRef.id, // Adding the document ID as matchId
      });

      return "Cricket Match Record Added Successfully";
    } catch (e) {
      print("Error recording match: $e");
      return "Failed to record match";
    }
  }


Future<String> recordFootballMatch({
    required String academicYear,
    required String matchLocation,
    required String matchType,
    required String matchTime,
    required String matchDayDate,
    required String teamAName,
    required String teamBName,
    required String teamALocation,
    required String teamBLocation,
    required String teamAScore,
    required String teamBScore,
    required String teamATopGoalScorer,
    required String teamBTopGoalScorer,
    required String teamALogoUrl,
    required String teamBLogoUrl,
    required String teamAId,
    required String teamBId,
  }) async {
    try {
      String result;
      String winningTeamDcId = "";
      String losingTeamDcId = "";

      // Function to parse scores with or without penalties
      int extractScore(String score) {
        if (score.contains("(")) {
          return int.parse(score.split("(")[1].replaceAll(")", ""));
        }
        return int.parse(score);
      }

      // Extract main and penalty scores
      int teamAMainScore = int.parse(teamAScore.split("(")[0]);
      int teamBMainScore = int.parse(teamBScore.split("(")[0]);

      int teamAPenaltyScore =
      teamAScore.contains("(") ? extractScore(teamAScore) : 0;
      int teamBPenaltyScore =
      teamBScore.contains("(") ? extractScore(teamBScore) : 0;

      // Determine the result
      if (teamAMainScore > teamBMainScore) {
        result = "$teamAName won by ${teamAMainScore - teamBMainScore} goals";
        winningTeamDcId = teamAId;
        losingTeamDcId = teamBId;
      } else if (teamBMainScore > teamAMainScore) {
        result = "$teamBName won by ${teamBMainScore - teamAMainScore} goals";
        winningTeamDcId = teamBId;
        losingTeamDcId = teamAId;
      } else if (teamAPenaltyScore > teamBPenaltyScore) {
        result =
        "$teamAName won ${teamAPenaltyScore}-${teamBPenaltyScore} on penalties";
        winningTeamDcId = teamAId;
        losingTeamDcId = teamBId;
      } else if (teamBPenaltyScore > teamAPenaltyScore) {
        result =
        "$teamBName won ${teamBPenaltyScore}-${teamAPenaltyScore} on penalties";
        winningTeamDcId = teamBId;
        losingTeamDcId = teamAId;
      } else {
        result = "Match drawn";
      }

      // Update matchesWon, matchesLost, and matchesPlayed for both teams
      Future<void> updateTeamStats(String teamId, bool isWinner, bool isLoser) async {
        DocumentReference teamDocRef =
        FirebaseFirestore.instance.collection('colleges').doc(teamId);

        DocumentSnapshot docSnapshot = await teamDocRef.get();

        Map<String, dynamic> matchesWon = docSnapshot['matchesWon'] != null
            ? Map<String, dynamic>.from(docSnapshot['matchesWon'])
            : {};
        Map<String, dynamic> matchesLost = docSnapshot['matchesLost'] != null
            ? Map<String, dynamic>.from(docSnapshot['matchesLost'])
            : {};
        Map<String, dynamic> matchesPlayed = docSnapshot['matchesPlayed'] != null
            ? Map<String, dynamic>.from(docSnapshot['matchesPlayed'])
            : {};

        if (isWinner) {
          matchesWon['football'] = (matchesWon['football'] ?? 0) + 1;
        }
        if (isLoser) {
          matchesLost['football'] = (matchesLost['football'] ?? 0) + 1;
        }

        matchesPlayed['football'] = (matchesPlayed['football'] ?? 0) + 1;

        await teamDocRef.update({
          'matchesWon': matchesWon,
          'matchesLost': matchesLost,
          'matchesPlayed': matchesPlayed,
        });
      }

      if (winningTeamDcId.isNotEmpty) {
        await updateTeamStats(winningTeamDcId, true, false);
        await updateTeamStats(losingTeamDcId, false, true);
      } else {
        // If the match is a draw, update matchesPlayed for both teams
        await updateTeamStats(teamAId, false, false);
        await updateTeamStats(teamBId, false, false);
      }

      // Add match details to Firestore
      CollectionReference footballColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('football');

      await footballColl.add({
        'teamAName': teamAName,
        'teamBName': teamBName,
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'teamALocation': teamALocation,
        'teamBLocation': teamBLocation,
        'teamATopGoalScorer': teamATopGoalScorer,
        'teamBTopGoalScorer': teamBTopGoalScorer,
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
    required String teamALocation, // Team A name
    required String teamBLocation, // Team B name
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
      String losingTeamDcId = "";

      // Determine the result
      if (teamAPoints > teamBPoints) {
        result = "$teamAName won by ${teamAPoints - teamBPoints} points";
        winningTeamDcId = teamAId;
        losingTeamDcId = teamBId;
      } else if (teamBPoints > teamAPoints) {
        result = "$teamBName won by ${teamBPoints - teamAPoints} points";
        winningTeamDcId = teamBId;
        losingTeamDcId = teamAId;
      } else {
        result = "Match drawn";
      }

      if (winningTeamDcId.isNotEmpty) {
// Update teams' match data
      DocumentReference winningTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(winningTeamDcId);
      DocumentReference losingTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(losingTeamDcId);

      // Get the data for both teams
      DocumentSnapshot winningTeamSnapshot = await winningTeamDoc.get();
      DocumentSnapshot losingTeamSnapshot = await losingTeamDoc.get();

      // Update matchesWon
      Map<String, dynamic> matchesWon = winningTeamSnapshot['matchesWon'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesWon'])
          : {};
      matchesWon['kabaddi'] = (matchesWon['kabaddi'] ?? 0) + 1;

      // Update matchesLost
      Map<String, dynamic> matchesLost = losingTeamSnapshot['matchesLost'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesLost'])
          : {};
      matchesLost['kabaddi'] = (matchesLost['kabaddi'] ?? 0) + 1;

      // Update matchesPlayed for both teams
      Map<String, dynamic> winningMatchesPlayed = winningTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesPlayed'])
          : {};
      Map<String, dynamic> losingMatchesPlayed = losingTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesPlayed'])
          : {};

      winningMatchesPlayed['kabaddi'] = (winningMatchesPlayed['kabaddi'] ?? 0) + 1;
      losingMatchesPlayed['kabaddi'] = (losingMatchesPlayed['kabaddi'] ?? 0) + 1;

      // Commit updates
      await winningTeamDoc.update({
        'matchesWon': matchesWon,
        'matchesPlayed': winningMatchesPlayed,
      });

      await losingTeamDoc.update({
        'matchesLost': matchesLost,
        'matchesPlayed': losingMatchesPlayed,
      });

      print("Updated team data successfully!");      }

      CollectionReference kabaddiColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('kabaddi');

      // Add a new document for the match
      DocumentReference docRef = await kabaddiColl.add({
        'teamAName': teamAName,
        'teamBName': teamBName,
        'teamAPoints': teamAPoints,
        'teamBPoints': teamBPoints,
        'teamALocation': teamALocation,
        'teamBLocation': teamBLocation,
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

      // Now include the document ID as a field in the document
      await docRef.update({
        'matchId': docRef.id, // Adding the document ID as matchId
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

  Future<List<InterCollegeFootballMatch>>   getAllInterCollegeFootballMatches(
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
    required String teamALocation, // Team A name
    required String teamBLocation, // Team B name
    required String teamAScore,
    required String teamBScore,
    required String teamALogoUrl,
    required String teamBLogoUrl,
    required String teamAId,
    required String teamBId,
  }) async {
    try {
      String result;
      String winningTeamDcId = "";
      String losingTeamDcId = "";

      // Determine the result
      if (int.parse(teamAScore) > int.parse(teamBScore)) {
        result = "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
        winningTeamDcId = teamAId;
        losingTeamDcId = teamBId;
      } else if (int.parse(teamBScore) > int.parse(teamAScore)) {
        result =  "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
        winningTeamDcId = teamBId;
        losingTeamDcId = teamAId;
      } else {
        result = "Match drawn";
      }

      // if (int.parse(teamAScore) > int.parse(teamBScore)) {
      //   result =
      //       "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
      // } else {
      //   result =
      //       "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
      // }
      // Update teams' match data
      DocumentReference winningTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(winningTeamDcId);
      DocumentReference losingTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(losingTeamDcId);

      // Get the data for both teams
      DocumentSnapshot winningTeamSnapshot = await winningTeamDoc.get();
      DocumentSnapshot losingTeamSnapshot = await losingTeamDoc.get();

      // Update matchesWon
      Map<String, dynamic> matchesWon = winningTeamSnapshot['matchesWon'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesWon'])
          : {};
      matchesWon['volleyball_boys'] = (matchesWon['volleyball_boys'] ?? 0) + 1;

      // Update matchesLost
      Map<String, dynamic> matchesLost = losingTeamSnapshot['matchesLost'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesLost'])
          : {};
      matchesLost['volleyball_boys'] = (matchesLost['volleyball_boys'] ?? 0) + 1;

      // Update matchesPlayed for both teams
      Map<String, dynamic> winningMatchesPlayed = winningTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesPlayed'])
          : {};
      Map<String, dynamic> losingMatchesPlayed = losingTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesPlayed'])
          : {};

      winningMatchesPlayed['volleyball_boys'] = (winningMatchesPlayed['volleyball_boys'] ?? 0) + 1;
      losingMatchesPlayed['volleyball_boys'] = (losingMatchesPlayed['volleyball_boys'] ?? 0) + 1;

      // Commit updates
      await winningTeamDoc.update({
        'matchesWon': matchesWon,
        'matchesPlayed': winningMatchesPlayed,
      });

      await losingTeamDoc.update({
        'matchesLost': matchesLost,
        'matchesPlayed': losingMatchesPlayed,
      });

      print("Updated team data successfully!");

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
        'teamALocation': teamALocation,
        'teamBLocation': teamBLocation,
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'teamALogoUrl': teamALogoUrl,
        'teamBLogoUrl': teamBLogoUrl,
        'result': result,
        'soft_delete': false,
      });

      // Update the document to include its ID as a field
      await docRef.update({'matchId': docRef.id});

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
    required String teamALocation, // Team A name
    required String teamBLocation, // Team B name
    required String teamAScore,
    required String teamBScore,
    required String teamALogoUrl,
    required String teamBLogoUrl,
    required String teamAId,
    required String teamBId,
  }) async {
    try {
 String result;
      String winningTeamDcId = "";
      String losingTeamDcId = "";

      // Determine the result
      if (int.parse(teamAScore) > int.parse(teamBScore)) {
        result = "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
        winningTeamDcId = teamAId;
        losingTeamDcId = teamBId;
      } else if (int.parse(teamBScore) > int.parse(teamAScore)) {
        result =  "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
        winningTeamDcId = teamBId;
        losingTeamDcId = teamAId;
      } else {
        result = "Match drawn";
      }

      // if (int.parse(teamAScore) > int.parse(teamBScore)) {
      //   result =
      //       "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
      // } else {
      //   result =
      //       "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
      // }
      // Update teams' match data
      DocumentReference winningTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(winningTeamDcId);
      DocumentReference losingTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(losingTeamDcId);

      // Get the data for both teams
      DocumentSnapshot winningTeamSnapshot = await winningTeamDoc.get();
      DocumentSnapshot losingTeamSnapshot = await losingTeamDoc.get();

      // Update matchesWon
      Map<String, dynamic> matchesWon = winningTeamSnapshot['matchesWon'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesWon'])
          : {};
      matchesWon['volleyball_girls'] = (matchesWon['volleyball_girls'] ?? 0) + 1;

      // Update matchesLost
      Map<String, dynamic> matchesLost = losingTeamSnapshot['matchesLost'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesLost'])
          : {};
      matchesLost['volleyball_girls'] = (matchesLost['volleyball_girls'] ?? 0) + 1;

      // Update matchesPlayed for both teams
      Map<String, dynamic> winningMatchesPlayed = winningTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesPlayed'])
          : {};
      Map<String, dynamic> losingMatchesPlayed = losingTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesPlayed'])
          : {};

      winningMatchesPlayed['volleyball_girls'] = (winningMatchesPlayed['volleyball_girls'] ?? 0) + 1;
      losingMatchesPlayed['volleyball_girls'] = (losingMatchesPlayed['volleyball_girls'] ?? 0) + 1;

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
        'teamALocation': teamALocation,
        'teamBLocation': teamBLocation,
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'teamALogoUrl': teamALogoUrl,
        'teamBLogoUrl': teamBLogoUrl,
        'result': result,
        'soft_delete': false,
      });

      // Update the document to include its ID as a field
      await docRef.update({'matchId': docRef.id});

      return "Volleyball Girls Match Recorded Successfully";
    } catch (e) {
      print("Error recording volleyball girls match: $e");
      return "Failed to record volleyball girls match";
    }
  }
 

  Future<String> recordBasketBsallMatch({
    required String academicYear,
    required String matchLocation,
    required String matchType,
    required String matchTime,
    required String matchDayDate,
    required String teamAName,
    required String teamBName,
    required String teamALocation, // Team A name
    required String teamBLocation, // Team B name
    required String teamAScore,
    required String teamBScore,
    required String teamALogoUrl,
    required String teamBLogoUrl,
    required String teamAId,
    required String teamBId,
  }) async {
    try {
 String result;
      String winningTeamDcId = "";
      String losingTeamDcId = "";

      // Determine the result
      if (int.parse(teamAScore) > int.parse(teamBScore)) {
        result = "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
        winningTeamDcId = teamAId;
        losingTeamDcId = teamBId;
      } else if (int.parse(teamBScore) > int.parse(teamAScore)) {
        result =  "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
        winningTeamDcId = teamBId;
        losingTeamDcId = teamAId;
      } else {
        result = "Match drawn";
      }

      // if (int.parse(teamAScore) > int.parse(teamBScore)) {
      //   result =
      //       "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
      // } else {
      //   result =
      //       "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
      // }
      // Update teams' match data
      DocumentReference winningTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(winningTeamDcId);
      DocumentReference losingTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(losingTeamDcId);

      // Get the data for both teams
      DocumentSnapshot winningTeamSnapshot = await winningTeamDoc.get();
      DocumentSnapshot losingTeamSnapshot = await losingTeamDoc.get();

      // Update matchesWon
      Map<String, dynamic> matchesWon = winningTeamSnapshot['matchesWon'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesWon'])
          : {};
      matchesWon['basketball'] = (matchesWon['basketball'] ?? 0) + 1;

      // Update matchesLost
      Map<String, dynamic> matchesLost = losingTeamSnapshot['matchesLost'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesLost'])
          : {};
      matchesLost['basketball'] = (matchesLost['basketball'] ?? 0) + 1;

      // Update matchesPlayed for both teams
      Map<String, dynamic> winningMatchesPlayed = winningTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesPlayed'])
          : {};
      Map<String, dynamic> losingMatchesPlayed = losingTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesPlayed'])
          : {};

      winningMatchesPlayed['basketball'] = (winningMatchesPlayed['basketball'] ?? 0) + 1;
      losingMatchesPlayed['basketball'] = (losingMatchesPlayed['basketball'] ?? 0) + 1;

      CollectionReference BasketBallfbcall = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('basketball');

      // Add the document and get the document reference
      DocumentReference docRef = await BasketBallfbcall.add({
        'academicYear': academicYear,
        'matchLocation': matchLocation,
        'matchType': matchType,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'teamAName': teamAName,
        'teamBName': teamBName,
        'teamALocation': teamALocation,
        'teamBLocation': teamBLocation,
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'teamALogoUrl': teamALogoUrl,
        'teamBLogoUrl': teamBLogoUrl,
        'result': result,
        'soft_delete': false,
      });

      // Update the document to include its ID as a field
      await docRef.update({'matchId': docRef.id});

      return "BasketBall Match Recorded Successfully";
    } catch (e) {
      print("Error recording BasketBall match: $e");
      return "Failed to record BasketBall match";
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
    required String teamALocation, // Team A name
    required String teamBLocation, // Team B name
    required String teamAScore,
    required String teamBScore,
    required String teamALogoUrl,
    required String teamBLogoUrl,
    required String teamAId,
    required String teamBId,
  }) async {
    try {
 String result;
      String winningTeamDcId = "";
      String losingTeamDcId = "";

      // Determine the result
      if (int.parse(teamAScore) > int.parse(teamBScore)) {
        result = "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
        winningTeamDcId = teamAId;
      } else if (int.parse(teamBScore) > int.parse(teamAScore)) {
        result =  "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
        winningTeamDcId = teamBId;
      } else {
        result = "Match drawn";
      }

      // if (int.parse(teamAScore) > int.parse(teamBScore)) {
      //   result =
      //       "$teamAName won by ${int.parse(teamAScore) - int.parse(teamBScore)} points";
      // } else {
      //   result =
      //       "$teamBName won by ${int.parse(teamBScore) - int.parse(teamAScore)} points";
      // }
      // Update teams' match data
      DocumentReference winningTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(winningTeamDcId);
      DocumentReference losingTeamDoc = FirebaseFirestore.instance.collection('colleges').doc(losingTeamDcId);

      // Get the data for both teams
      DocumentSnapshot winningTeamSnapshot = await winningTeamDoc.get();
      DocumentSnapshot losingTeamSnapshot = await losingTeamDoc.get();

      // Update matchesWon
      Map<String, dynamic> matchesWon = winningTeamSnapshot['matchesWon'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesWon'])
          : {};
      matchesWon['tug_of_war'] = (matchesWon['tug_of_war'] ?? 0) + 1;

      // Update matchesLost
      Map<String, dynamic> matchesLost = losingTeamSnapshot['matchesLost'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesLost'])
          : {};
      matchesLost['tug_of_war'] = (matchesLost['tug_of_war'] ?? 0) + 1;

      // Update matchesPlayed for both teams
      Map<String, dynamic> winningMatchesPlayed = winningTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(winningTeamSnapshot['matchesPlayed'])
          : {};
      Map<String, dynamic> losingMatchesPlayed = losingTeamSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(losingTeamSnapshot['matchesPlayed'])
          : {};

      winningMatchesPlayed['tug_of_war'] = (winningMatchesPlayed['tug_of_war'] ?? 0) + 1;
      losingMatchesPlayed['tug_of_war'] = (losingMatchesPlayed['tug_of_war'] ?? 0) + 1;

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
        'teamALocation': teamALocation,
        'teamBLocation': teamBLocation,
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
  Future<List<InterCollege>> fetchCollegesBySport(String sportName) async {
    try {

      final collectionRef = FirebaseFirestore.instance.collection('colleges');

      final querySnapshot = await collectionRef.get();

      List<InterCollege> colleges = querySnapshot.docs
          .map((doc) {
        // Convert Firestore document to InterCollege model
        final data = doc.data() as Map<String, dynamic>;
        final interCollege = InterCollege.fromMap(data, doc.id);

        // Check if the sport is in matchesPlayed
        if (interCollege.matchesPlayed!.containsKey(sportName)) {
          return interCollege;
        }
        return null;
      })
          .where((college) => college != null) // Remove null entries
          .cast<InterCollege>() // Cast to List<InterCollege>
          .toList();

      return colleges;
    } catch (e) {
      print("Error fetching colleges for sport $sportName: $e");
      return [];
    }
  }

    // Indoor Games

  Future<String> recordCarromSingleMatch({
    required String academicYear, // e.g., "2024-2025"
    required String matchLocation, // Like Indoor Sports Arena
    required String matchType, // Like GroupStage, RO16, QF, SF, Final
    required String matchTime, // Like 1.30 PM
    required String matchDayDate, // Like Sun, 24 Dec 2024
    required String collegeA, // College A name
    required String collegeB, // College B name
    required List<String> playersCollegeA, // Players from College A
    required List<String> playersCollegeB, // Players from College B
    required String collegeALogoUrl, // Firebase storage URL for College A logo
    required String collegeBLogoUrl, // Firebase storage URL for College B logo
    required String collegeAId, // Firebase document ID for College A
    required String collegeBId, // Firebase document ID for College B
    required String winningCollegeId, // ID of the winning college
  }) async {
    try {
      // Determine the losing college ID
      String losingCollegeId =
      (winningCollegeId == collegeAId) ? collegeBId : collegeAId;

      String result = (winningCollegeId == collegeAId)
          ? "$collegeA defeated $collegeB"
          : "$collegeB defeated $collegeA";

      // Update colleges' match data
      DocumentReference winningCollegeDoc =
      FirebaseFirestore.instance.collection('colleges').doc(winningCollegeId);
      DocumentReference losingCollegeDoc =
      FirebaseFirestore.instance.collection('colleges').doc(losingCollegeId);

      // Get the data for both colleges
      DocumentSnapshot winningCollegeSnapshot = await winningCollegeDoc.get();
      DocumentSnapshot losingCollegeSnapshot = await losingCollegeDoc.get();

      // Update matchesWon
      Map<String, dynamic> matchesWon = winningCollegeSnapshot['matchesWon'] !=
          null
          ? Map<String, dynamic>.from(winningCollegeSnapshot['matchesWon'])
          : {};
      matchesWon['carrom'] = (matchesWon['carrom'] ?? 0) + 1;

      // Update matchesLost
      Map<String, dynamic> matchesLost = losingCollegeSnapshot['matchesLost'] !=
          null
          ? Map<String, dynamic>.from(losingCollegeSnapshot['matchesLost'])
          : {};
      matchesLost['carrom'] = (matchesLost['carrom'] ?? 0) + 1;

      // Update matchesPlayed for both colleges
      Map<String,
          dynamic> winningMatchesPlayed = winningCollegeSnapshot['matchesPlayed'] !=
          null
          ? Map<String, dynamic>.from(winningCollegeSnapshot['matchesPlayed'])
          : {};
      Map<String,
          dynamic> losingMatchesPlayed = losingCollegeSnapshot['matchesPlayed'] !=
          null
          ? Map<String, dynamic>.from(losingCollegeSnapshot['matchesPlayed'])
          : {};

      winningMatchesPlayed['carrom'] =
          (winningMatchesPlayed['carrom'] ?? 0) + 1;
      losingMatchesPlayed['carrom'] = (losingMatchesPlayed['carrom'] ?? 0) + 1;

      // Commit updates
      await winningCollegeDoc.update({
        'matchesWon': matchesWon,
        'matchesPlayed': winningMatchesPlayed,
      });

      await losingCollegeDoc.update({
        'matchesLost': matchesLost,
        'matchesPlayed': losingMatchesPlayed,
      });

      print("Updated college data successfully!");

      CollectionReference carromColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('carrom');

      DocumentReference matchDoc = await carromColl.add({
        'collegeA': collegeA,
        'collegeB': collegeB,
        'playersCollegeA': playersCollegeA,
        'playersCollegeB': playersCollegeB,
        'collegeALogoUrl': collegeALogoUrl,
        'collegeBLogoUrl': collegeBLogoUrl,
        'result': result,
        'matchLocation': matchLocation,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'matchType': matchType,
        'timestamp': FieldValue.serverTimestamp(),
        'soft_delete': false,
      });

      await matchDoc.update({'matchId': matchDoc.id});

      return "Success";
    } catch (e) {
      print("Error recording match: $e");
      return "Failed to record match";
    }
  }


  Future<String> recordCarromDoublesMatch({
    required String academicYear, // e.g., "2024-2025"
    required String matchLocation, // Like Indoor Sports Arena
    required String matchType, // Like GroupStage, RO16, QF, SF, Final
    required String matchTime, // Like 1.30 PM
    required String matchDayDate, // Like Sun, 24 Dec 2024
    required String collegeA, // College A name
    required String collegeB, // College B name
    required String playersCollegeA1, // Doubles pairs from College A
    required String playersCollegeA2, // Doubles pairs from College A
    required String playersCollegeB1, // Doubles pairs from College A
    required String playersCollegeB2, // Doubles pairs from College B
    required String collegeALogoUrl, // Firebase storage URL for College A logo
    required String collegeBLogoUrl, // Firebase storage URL for College B logo
    required String collegeAId, // Firebase document ID for College A
    required String collegeBId, // Firebase document ID for College B
    required String winningCollegeId, // ID of the winning college
  }) async {
    try {
      // Determine the losing college ID
      String losingCollegeId =
      (winningCollegeId == collegeAId) ? collegeBId : collegeAId;

      String result = (winningCollegeId == collegeAId)
          ? "$collegeA defeated $collegeB"
          : "$collegeB defeated $collegeA";

      // Update colleges' match data
      DocumentReference winningCollegeDoc =
      FirebaseFirestore.instance.collection('colleges').doc(winningCollegeId);
      DocumentReference losingCollegeDoc =
      FirebaseFirestore.instance.collection('colleges').doc(losingCollegeId);

      // Get the data for both colleges
      DocumentSnapshot winningCollegeSnapshot = await winningCollegeDoc.get();
      DocumentSnapshot losingCollegeSnapshot = await losingCollegeDoc.get();

      // Update matchesWon
      Map<String, dynamic> matchesWon = winningCollegeSnapshot['matchesWon'] !=
          null
          ? Map<String, dynamic>.from(winningCollegeSnapshot['matchesWon'])
          : {};
      matchesWon['carromDoubles'] = (matchesWon['carromDoubles'] ?? 0) + 1;

      // Update matchesLost
      Map<String, dynamic> matchesLost = losingCollegeSnapshot['matchesLost'] !=
          null
          ? Map<String, dynamic>.from(losingCollegeSnapshot['matchesLost'])
          : {};
      matchesLost['carromDoubles'] = (matchesLost['carromDoubles'] ?? 0) + 1;

      // Update matchesPlayed for both colleges
      Map<String,
          dynamic> winningMatchesPlayed = winningCollegeSnapshot['matchesPlayed'] !=
          null
          ? Map<String, dynamic>.from(winningCollegeSnapshot['matchesPlayed'])
          : {};
      Map<String,
          dynamic> losingMatchesPlayed = losingCollegeSnapshot['matchesPlayed'] !=
          null
          ? Map<String, dynamic>.from(losingCollegeSnapshot['matchesPlayed'])
          : {};

      winningMatchesPlayed['carromDoubles'] =
          (winningMatchesPlayed['carromDoubles'] ?? 0) + 1;
      losingMatchesPlayed['carromDoubles'] =
          (losingMatchesPlayed['carromDoubles'] ?? 0) + 1;

      // Commit updates
      await winningCollegeDoc.update({
        'matchesWon': matchesWon,
        'matchesPlayed': winningMatchesPlayed,
      });

      await losingCollegeDoc.update({
        'matchesLost': matchesLost,
        'matchesPlayed': losingMatchesPlayed,
      });

      print("Updated college data successfully!");

      // Add match record to 'intercollege_sports'
      CollectionReference carromColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('carromDoubles');

      DocumentReference matchDoc = await carromColl.add({
        'collegeA': collegeA,
        'collegeB': collegeB,
        'playersCollegeA1': playersCollegeA1,
        'playersCollegeA2': playersCollegeA2,
        'playersCollegeB1': playersCollegeB1, // Nested list for doubles pairs
        'playersCollegeB2': playersCollegeB2, // Nested list for doubles pairs
        'collegeALogoUrl': collegeALogoUrl,
        'collegeBLogoUrl': collegeBLogoUrl,
        'result': result,
        'matchLocation': matchLocation,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'matchType': matchType,
        'timestamp': FieldValue.serverTimestamp(),
        'soft_delete': false,
      });

      await matchDoc.update({'matchId': matchDoc.id});

      return "Success";
    } catch (e) {
      print("Error recording doubles match: $e");
      return "Failed to record doubles match";
    }
  }


  Future<String> recordChessMatch({
    required String academicYear, // e.g., "2024-2025"
    required String matchLocation, // Like Indoor Sports Arena
    required String matchType, // Like GroupStage, RO16, QF, SF, Final
    required String matchTime, // Like 1.30 PM
    required String matchDayDate, // Like Sun, 24 Dec 2024
    required String collegeA, // College A name
    required String collegeB, // College B name
    required String playerCollegeA, // Chess player from College A
    required String playerCollegeB, // Chess player from College B
    required String collegeALogoUrl, // Firebase storage URL for College A logo
    required String collegeBLogoUrl, // Firebase storage URL for College B logo
    required String collegeAId, // Firebase document ID for College A
    required String collegeBId, // Firebase document ID for College B
    required String winningCollegeId, // ID of the winning college
    required String winningCollegeName, // Name of the winning college
  }) async {
    try {
      // Determine the losing college ID
      String losingCollegeId =
      (winningCollegeId == collegeAId) ? collegeBId : collegeAId;

      String result = "$winningCollegeName won the match";

      // Update colleges' match data
      DocumentReference winningCollegeDoc =
      FirebaseFirestore.instance.collection('colleges').doc(winningCollegeId);
      DocumentReference losingCollegeDoc =
      FirebaseFirestore.instance.collection('colleges').doc(losingCollegeId);

      // Get the data for both colleges
      DocumentSnapshot winningCollegeSnapshot = await winningCollegeDoc.get();
      DocumentSnapshot losingCollegeSnapshot = await losingCollegeDoc.get();

      // Update matchesWon
      Map<String, dynamic> matchesWon = winningCollegeSnapshot['matchesWon'] !=
          null
          ? Map<String, dynamic>.from(winningCollegeSnapshot['matchesWon'])
          : {};
      matchesWon['chess'] = (matchesWon['chess'] ?? 0) + 1;

      // Update matchesLost
      Map<String, dynamic> matchesLost = losingCollegeSnapshot['matchesLost'] !=
          null
          ? Map<String, dynamic>.from(losingCollegeSnapshot['matchesLost'])
          : {};
      matchesLost['chess'] = (matchesLost['chess'] ?? 0) + 1;

      // Update matchesPlayed for both colleges
      Map<String,
          dynamic> winningMatchesPlayed = winningCollegeSnapshot['matchesPlayed'] !=
          null
          ? Map<String, dynamic>.from(winningCollegeSnapshot['matchesPlayed'])
          : {};
      Map<String,
          dynamic> losingMatchesPlayed = losingCollegeSnapshot['matchesPlayed'] !=
          null
          ? Map<String, dynamic>.from(losingCollegeSnapshot['matchesPlayed'])
          : {};

      winningMatchesPlayed['chess'] = (winningMatchesPlayed['chess'] ?? 0) + 1;
      losingMatchesPlayed['chess'] = (losingMatchesPlayed['chess'] ?? 0) + 1;

      // Commit updates
      await winningCollegeDoc.update({
        'matchesWon': matchesWon,
        'matchesPlayed': winningMatchesPlayed,
      });

      await losingCollegeDoc.update({
        'matchesLost': matchesLost,
        'matchesPlayed': losingMatchesPlayed,
      });

      print("Updated college data successfully!");

      // Add match record to 'intercollege_sports'
      CollectionReference chessColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('chess');

      DocumentReference matchDoc = await chessColl.add({
        'collegeA': collegeA,
        'collegeB': collegeB,
        'playerCollegeA': playerCollegeA,
        'playerCollegeB': playerCollegeB,
        'collegeALogoUrl': collegeALogoUrl,
        'collegeBLogoUrl': collegeBLogoUrl,
        'result': result,
        'matchLocation': matchLocation,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'matchType': matchType,
        'timestamp': FieldValue.serverTimestamp(),
        'soft_delete': false,
      });

      await matchDoc.update({'matchId': matchDoc.id});

      return "Success";
    } catch (e) {
      print("Error recording powerlifting match: $e");
      return "Failed to record powerlifting match";
    }
  }


  Future<String> recordTableTennisDoublesMatch({
    required String academicYear, // e.g., "2024-2025"
    required String matchLocation, // Like Indoor Sports Arena
    required String matchType, // Like GroupStage, RO16, QF, SF, Final
    required String matchTime, // Like 1.30 PM
    required String matchDayDate, // Like Sun, 24 Dec 2024
    required String collegeA, // College A name
    required String collegeB, // College B name
    required String playerA1, // Player 1 from College A
    required String playerA2, // Player 2 from College A
    required String playerB1, // Player 1 from College B
    required String playerB2, // Player 2 from College B
    required String collegeALogoUrl, // Firebase storage URL for College A logo
    required String collegeBLogoUrl, // Firebase storage URL for College B logo
    required String collegeAId, // Firebase document ID for College A
    required String collegeBId, // Firebase document ID for College B
    required String winningCollegeName, // Name of the winning college
    required String winningCollegeId, // Name of the winning college
    required String winningPoints, // Points won by winning college in format "X-Y,Z-W,..."
  }) async {
    try {
      // Determine the losing college ID
      String losingCollegeId =
      (winningCollegeName == collegeA) ? collegeBId : collegeAId;

      // Generate result string
      String result = "$winningCollegeName wins by points $winningPoints";

      // Update colleges' match data
      DocumentReference winningCollegeDoc =
      FirebaseFirestore.instance.collection('colleges').doc(winningCollegeId);
      DocumentReference losingCollegeDoc =
      FirebaseFirestore.instance.collection('colleges').doc(losingCollegeId);

      // Get the data for both colleges
      DocumentSnapshot winningCollegeSnapshot = await winningCollegeDoc.get();
      DocumentSnapshot losingCollegeSnapshot = await losingCollegeDoc.get();

      // Update matchesWon
      Map<String, dynamic> matchesWon = winningCollegeSnapshot['matchesWon'] != null
          ? Map<String, dynamic>.from(winningCollegeSnapshot['matchesWon'])
          : {};
      matchesWon['tableTennisDoubles'] = (matchesWon['tableTennisDoubles'] ?? 0) + 1;

      // Update matchesLost
      Map<String, dynamic> matchesLost = losingCollegeSnapshot['matchesLost'] != null
          ? Map<String, dynamic>.from(losingCollegeSnapshot['matchesLost'])
          : {};
      matchesLost['tableTennisDoubles'] = (matchesLost['tableTennisDoubles'] ?? 0) + 1;

      // Update matchesPlayed for both colleges
      Map<String, dynamic> winningMatchesPlayed = winningCollegeSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(winningCollegeSnapshot['matchesPlayed'])
          : {};
      Map<String, dynamic> losingMatchesPlayed = losingCollegeSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(losingCollegeSnapshot['matchesPlayed'])
          : {};

      winningMatchesPlayed['tableTennisDoubles'] = (winningMatchesPlayed['tableTennisDoubles'] ?? 0) + 1;
      losingMatchesPlayed['tableTennisDoubles'] = (losingMatchesPlayed['tableTennisDoubles'] ?? 0) + 1;

      // Commit updates
      await winningCollegeDoc.update({
        'matchesWon': matchesWon,
        'matchesPlayed': winningMatchesPlayed,
      });

      await losingCollegeDoc.update({
        'matchesLost': matchesLost,
        'matchesPlayed': losingMatchesPlayed,
      });

      print("Updated college data successfully!");

      // Add match record to 'intercollege_sports'
      CollectionReference tableTennisDoublesColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('tableTennisDoubles');

      DocumentReference matchDoc = await tableTennisDoublesColl.add({
        'collegeA': collegeA,
        'collegeB': collegeB,
        'playerA1': playerA1,
        'playerA2': playerA2,
        'playerB1': playerB1,
        'playerB2': playerB2,
        'collegeALogoUrl': collegeALogoUrl,
        'collegeBLogoUrl': collegeBLogoUrl,
        'result': result,
        'matchLocation': matchLocation,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'matchType': matchType,
        'winningPoints': winningPoints, // Points like 10-9, 11-12, 11-9
        'timestamp': FieldValue.serverTimestamp(),
        'soft_delete': false,
      });

      await matchDoc.update({'matchId': matchDoc.id});

      return "Success";
    } catch (e) {
      print("Error recording table tennis doubles match: $e");
      return "Failed to record table tennis doubles match";
    }
  }

  Future<String> recordPowerliftingMatch({
    required String academicYear, // e.g., "2024-2025"
    required String matchLocation, // Like Indoor Sports Arena
    required String matchType, // Like GroupStage, RO16, QF, SF, Final
    required String matchTime, // Like 1.30 PM
    required String matchDayDate, // Like Sun, 24 Dec 2024
    required String collegeName, // College name
    required String playerName, // Player's name
    required String positionSecured, // Position secured like 1, 2, 3, etc.
    required String collegeLogoUrl, // Firebase storage URL for College logo
    required String collegeId, // Firebase document ID for College
  }) async {
    try {
      // Add match result
      String result = "$playerName from $collegeName secured position $positionSecured";

      // Update college match data
      DocumentReference collegeDoc = FirebaseFirestore.instance.collection('colleges').doc(collegeId);

      // Get the data for the college
      DocumentSnapshot collegeSnapshot = await collegeDoc.get();

      // Update matchesPlayed and powerlifting results
      Map<String, dynamic> powerliftingResults = collegeSnapshot['powerliftingResults'] != null
          ? Map<String, dynamic>.from(collegeSnapshot['powerliftingResults'])
          : {};
      powerliftingResults[positionSecured] = (powerliftingResults[positionSecured] ?? 0) + 1;

      Map<String, dynamic> matchesPlayed = collegeSnapshot['matchesPlayed'] != null
          ? Map<String, dynamic>.from(collegeSnapshot['matchesPlayed'])
          : {};

      matchesPlayed['powerlifting'] = (matchesPlayed['powerlifting'] ?? 0) + 1;

      // Commit updates
      await collegeDoc.update({
        'powerliftingResults': powerliftingResults,
        'matchesPlayed': matchesPlayed,
      });

      print("Updated college data successfully!");

      // Add match record to 'intercollege_sports'
      CollectionReference powerliftingColl = FirebaseFirestore.instance
          .collection('intercollege_sports')
          .doc(academicYear)
          .collection('powerlifting');

      DocumentReference matchDoc = await powerliftingColl.add({
        'collegeName': collegeName,
        'playerName': playerName,
        'positionSecured': positionSecured,
        'collegeLogoUrl': collegeLogoUrl,
        'result': result,
        'matchLocation': matchLocation,
        'matchTime': matchTime,
        'matchDayDate': matchDayDate,
        'matchType': matchType,
        'timestamp': FieldValue.serverTimestamp(),
        'soft_delete': false,
      });

      await matchDoc.update({'matchId': matchDoc.id});

      return "Success";
    } catch (e) {
      print("Error recording powerlifting match: $e");
      return "Failed to record powerlifting match";
    }
  }
}
