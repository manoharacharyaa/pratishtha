import 'package:cloud_firestore/cloud_firestore.dart';

class InterCollegeFootballMatch {
  final String id;
  final String teamAName;
  final String teamBName;
  final String teamAScore;
  final String teamBScore;
  final String teamALocation;
  final String teamBLocation;
  final String? teamATopGoalScorer;
  final String? teamBTopGoalScorer;
  final String teamALogoUrl;
  final String teamBLogoUrl;
  final String result;
  final String matchLocation;
  final String matchTime;
  final String matchDayDate;
  final String matchType;
  final DateTime? timestamp;
  final bool softDelete;

  InterCollegeFootballMatch({
    required this.id,
    required this.teamAName,
    required this.teamBName,
    required this.teamALocation,
    required this.teamBLocation,
    required this.teamAScore,
    required this.teamBScore,
    this.teamATopGoalScorer,
    this.teamBTopGoalScorer,
    required this.teamALogoUrl,
    required this.teamBLogoUrl,
    required this.result,
    required this.matchLocation,
    required this.matchTime,
    required this.matchDayDate,
    required this.matchType,
    required this.softDelete,
    this.timestamp,
  });

  factory InterCollegeFootballMatch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InterCollegeFootballMatch(
      id: doc.id,
      teamAName: data['teamAName'],
      teamBName: data['teamBName'],
      teamALocation: data['teamALocation'] ?? 'Mumbai',
      teamBLocation: data['teamBLocation'] ?? 'Mumbai',
      teamAScore: data['teamAScore'],
      teamBScore: data['teamBScore'],
      teamATopGoalScorer: data['teamATopGoalScorer'],
      teamBTopGoalScorer: data['teamBTopGoalScorer'],
      teamALogoUrl: data['teamALogoUrl'],
      teamBLogoUrl: data['teamBLogoUrl'],
      result: data['result'],
      matchLocation: data['matchLocation'],
      matchTime: data['matchTime'],
      matchDayDate: data['matchDayDate'],
      matchType: data['matchType'],
      softDelete: data['soft_delete'] ?? false,
      timestamp: data['timestamp']?.toDate(),
    );
  }
}
