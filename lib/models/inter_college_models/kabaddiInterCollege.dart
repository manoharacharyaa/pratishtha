import 'package:cloud_firestore/cloud_firestore.dart';

class InterCollegeKabaddiMatch {
  final String id;
  final String teamAName;
  final String teamBName;
  final String teamALocation;
  final String teamBLocation;
  final int teamAPoints;
  final int teamBPoints;
  final String? teamATopRaider;
  final String? teamATopDefender;
  final String? teamBTopRaider;
  final String? teamBTopDefender;
  final String teamALogoUrl;
  final String teamBLogoUrl;
  final String result;
  final String matchLocation;
  final String matchTime;
  final String matchDayDate;
  final String matchType;
  final DateTime? timestamp;
  final bool softDelete;

  InterCollegeKabaddiMatch({
    required this.id,
    required this.teamAName,
    required this.teamBName,
    required this.teamALocation,
    required this.teamBLocation,
    required this.teamAPoints,
    required this.teamBPoints,
    this.teamATopRaider,
    this.teamATopDefender,
    this.teamBTopRaider,
    this.teamBTopDefender,
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

  factory InterCollegeKabaddiMatch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InterCollegeKabaddiMatch(
      id: doc.id,
      teamAName: data['teamAName'],
      teamBName: data['teamBName'],
      teamALocation: data['teamALocation'] ?? 'Mumbai',
      teamBLocation: data['teamBLocation'] ?? 'Mumbai',
      teamAPoints: data['teamAPoints'],
      teamBPoints: data['teamBPoints'],
      teamATopRaider: data['teamATopRaider'],
      teamATopDefender: data['teamATopDefender'],
      teamBTopRaider: data['teamBTopRaider'],
      teamBTopDefender: data['teamBTopDefender'],
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
