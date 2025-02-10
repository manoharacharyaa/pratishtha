import 'package:cloud_firestore/cloud_firestore.dart';

class InterCollegeCricketMatch {
  final String docId;
  final String teamBattingFirst;
  final String teamBattingSecond;
  final String teamBattingFirstScore;
  final String teamBattingSecondScore;
  final String teamBattingFirstTopBatter;
  final String teamBattingFirstLocation;
  final String teamBattingFirstLogoUrl;
  final String teamBattingSecondLogoUrl;
  final String teamBattingSecondLocation;
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
    required this.teamBattingFirstLocation,
    required this.teamBattingFirstLogoUrl,
    required this.teamBattingSecondLogoUrl,
    required this.teamBattingSecondLocation,
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
      teamBattingFirstLocation: data['teamBattingFirstLocation'] ?? 'Mumbai',
      teamBattingSecondLocation: data['teamBattingSecondLocation'] ?? 'Mumbai',
      teamBattingFirstTopBatter: data['teamBattingFirstTopBatter'] ?? '',
      teamBattingFirstTopBowlerPerformance:
          data['teamBattingFirstTopBowlerPerformance'] ?? '',
      teamBattingSecondTopBatter: data['teamBattingSecondTopBatter'] ?? '',
      teamBattingFirstLogoUrl: data['teamBattingFirstLogoUrl'] ?? '',
      teamBattingSecondLogoUrl: data['teamBattingSecondLogoUrl'] ?? '',
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
