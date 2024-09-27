Council councilFromMap(Map<String, dynamic> data) => Council.fromMap(data);

class Council {

  Council({
    this.id ,
    this.name = "",
    this.post = "",
    this.phone = "",
    this.index = 0,
    this.photo = "",
    this.description = "",
    this.startYear,
    this.endYear,
    this.year,
  });

  String? id;
  String name;
  String post;
  String phone;
  int index;
  String photo;
  String description;
  DateTime? startYear;
  DateTime? endYear;
  String? year;

  factory Council.fromMap(Map<String, dynamic> map) => Council(
    id: map['id'],
    name: map['name'] ?? "",
    post: map['post'] ?? "",
    phone: map['phone'].toString() ?? "",
    index: map['index'] ?? 0,
    photo: map['photo'] ?? "",
    description: map['description'] ?? "",
    startYear: map['start_year'] != null ? DateTime.parse(map['start_year'].toDate().toString()) : DateTime.now(),
    endYear: map['end_year'] != null ? DateTime.parse(map['end_year'].toDate().toString()) : DateTime.now(),
    year: map['year'] ?? "",
  );

}