import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class InterCollegeCricketMatch {
  final String docId;
  final String teamBattingFirst;
  final String teamBattingSecond;
  final String teamBattingFirstScore;
  final String teamBattingSecondScore;
  final String teamBattingFirstTopBatter;
  final String teamBattingFirstTopBowlerPerformance;
  final String teamBattingSecondTopBatter;
  final String teamBattingSecondTopBowlerPerformance;
  final String result;
  final String matchLocation;
  final String matchTime;
  final String matchDayDate;
  final String matchType;
  final bool softDelete;

  InterCollegeCricketMatch({
    required this.docId,
    required this.teamBattingFirst,
    required this.teamBattingSecond,
    required this.teamBattingFirstScore,
    required this.teamBattingSecondScore,
    required this.teamBattingFirstTopBatter,
    required this.teamBattingFirstTopBowlerPerformance,
    required this.teamBattingSecondTopBatter,
    required this.teamBattingSecondTopBowlerPerformance,
    required this.result,
    required this.matchLocation,
    required this.matchTime,
    required this.matchDayDate,
    required this.matchType,
    required this.softDelete,
  });

  factory InterCollegeCricketMatch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InterCollegeCricketMatch(
      docId: doc.id,
      teamBattingFirst: data['teamBattingFirst'] ?? '',
      teamBattingSecond: data['teamBattingSecond'] ?? '',
      teamBattingFirstScore: data['teamBattingFirstScore'] ?? '',
      teamBattingSecondScore: data['teamBattingSecondScore'] ?? '',
      teamBattingFirstTopBatter: data['teamBattingFirstTopBatter'] ?? '',
      teamBattingFirstTopBowlerPerformance:
          data['teamBattingFirstTopBowlerPerformance'] ?? '',
      teamBattingSecondTopBatter: data['teamBattingSecondTopBatter'] ?? '',
      teamBattingSecondTopBowlerPerformance:
          data['teamBattingSecondTopBowlerPerformance'] ?? '',
      result: data['result'] ?? '',
      matchLocation: data['matchLocation'] ?? '',
      matchTime: data['matchTime'] ?? '',
      matchDayDate: data['matchDayDate'] ?? '',
      matchType: data['matchType'] ?? '',
      softDelete: data['soft_delete'] ?? false,
    );
  }
}
