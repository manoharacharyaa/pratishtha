import 'package:cloud_firestore/cloud_firestore.dart';

class InterCollegeVlleyballGirlsMatch {
  final String id;
  final String academicYear;
  final String matchLocation;
  final String matchType;
  final String matchTime;
  final String matchDayDate;
  final String teamAName;
  final String teamBName;
  final String teamALocation;
  final String teamBLocation;
  final String teamAScore;
  final String teamBScore;
  final String result;
  final String teamALogoUrl;
  final String teamBLogoUrl;
  final bool softDelete;

  InterCollegeVlleyballGirlsMatch({
    required this.id,
    required this.academicYear,
    required this.matchLocation,
    required this.matchType,
    required this.matchTime,
    required this.matchDayDate,
    required this.teamAName,
    required this.teamBName,
    required this.teamALocation,
    required this.teamBLocation,
    required this.teamAScore,
    required this.teamBScore,
    required this.result,
    required this.teamALogoUrl,
    required this.teamBLogoUrl,
    this.softDelete = false,
  });

  factory InterCollegeVlleyballGirlsMatch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InterCollegeVlleyballGirlsMatch(
      id: doc.id,
      academicYear: data['academicYear'] ?? '',
      matchLocation: data['matchLocation'] ?? '',
      matchType: data['matchType'] ?? '',
      matchTime: data['matchTime'] ?? '',
      matchDayDate: data['matchDayDate'] ?? '',
      teamAName: data['teamAName'] ?? '',
      teamBName: data['teamBName'] ?? '',
      teamALocation: data['teamALocation'] ?? 'Mumbai',
      teamBLocation: data['teamBLocation'] ?? 'Mumbai',
      teamAScore: data['teamAScore'] ?? '',
      teamBScore: data['teamBScore'] ?? '',
      result: data['result'] ?? '',
      teamALogoUrl: data['teamALogoUrl'] ?? '',
      teamBLogoUrl: data['teamBLogoUrl'] ?? '',
      softDelete: data['soft_delete'] ?? false,
    );
  }
}
