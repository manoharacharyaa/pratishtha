
Team teamFromMap(Map<String, dynamic> data) => Team.fromMap(data);

class Team {

  Team({
    this.id,
    this.name = "",
    this.position = "",
    this.index = 0,
    this.photo = "",
    this.description = "",
    this.startYear,
    this.endYear,
    this.year,
    this.post,
  });

  String? id;
  String name;
  String position;
  int index;
  String photo;
  String description;
  DateTime? startYear;
  DateTime? endYear;
  String? year;
  String? post;

  factory Team.fromMap(Map<String, dynamic> map) => Team(
      id: map['id'],
      name: map['name'] ?? "",
      position: map['position'] ?? "",
      index: map['index']!=null ? int.parse(map['index'].toString()) : 0,
      photo: map['photo'] ?? "",
      description: map['description'] ?? "",
      startYear: map['start_year'] != null ? DateTime.parse(map['start_year'].toDate().toString()) : DateTime.now(),
      endYear: map['end_year'] != null ? DateTime.parse(map['end_year'].toDate().toString()) : DateTime.now(),
      year: map['year'] ?? "",
      post:   map['post'] ?? "",
  );

}