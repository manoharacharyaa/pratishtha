class InterCollege {
  String id;
  String collegeName;
  String collegeShortName;
  String collegeLocation;
  int score;
  String imageUrl;
  String academicYear;
  bool softDelete;
  List<Map<String, int>>? matchesWon;

  InterCollege({
    required this.id,
    required this.collegeName,
    required this.collegeShortName,
    required this.collegeLocation,
    required this.score,
    required this.imageUrl,
    required this.academicYear,
    required this.softDelete,
    this.matchesWon,
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
      matchesWon: (data['matchesWon'] as List<dynamic>?)
          ?.map((item) => Map<String, int>.from(item))
          .toList(),
    );
  }
}
