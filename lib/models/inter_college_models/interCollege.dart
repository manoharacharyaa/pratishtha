class InterCollege {
  final String id;
  final String collegeName;
  final String collegeShortName;
  final String collegeLocation;

  final int score;
  final String imageUrl;
  final String academicYear;
  final bool softDelete;
  final Map<String, dynamic>? matchesWon;
  final Map<String, dynamic>? matchesLost;
  final Map<String, dynamic>? matchesPlayed;

  InterCollege({
    required this.id,
    required this.collegeName,
    required this.collegeShortName,
    required this.collegeLocation,
    required this.score,
    required this.imageUrl,
    required this.academicYear,
    required this.softDelete,
    required this.matchesWon,
    required this.matchesLost,
    required this.matchesPlayed,
  });

  factory InterCollege.fromMap(Map<String, dynamic> data, String id) {
    return InterCollege(
      id: id,
      collegeName: data['collegeName'] ?? '',
      collegeShortName: data['collegeShortName'] ?? '',
      collegeLocation: data['collegeLocation'] ?? '',
      score: data['score'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      academicYear: data['academicYear'] ?? '',
      softDelete: data['soft_delete'] ?? false,
      matchesWon: Map<String, dynamic>.from(data['matchesWon'] ?? {}),
      matchesLost: Map<String ,dynamic>.from(data['matchesLost'] ?? {}),
      matchesPlayed: Map<String ,dynamic>.from(data['matchesPlayed'] ?? {}),
    );
  }
}
