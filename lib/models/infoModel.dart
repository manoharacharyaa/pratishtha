
Info infoFromMap(Map<String, dynamic> data) => Info.fromMap(data);

class Info {

  Info({
    this.id,
    this.name = "",
    this.photo = "",
    this.video = "",
    this.description = "",
    this.index = 0
  });

  String? id;
  String name;
  String photo;
  String video;
  String description;
  int index;

  factory Info.fromMap(Map<String, dynamic> map) => Info(
      id: map['id'],
      name: map['name'] ?? "",
      photo: map['photo'] ?? "",
      video: map['video'] ?? "",
      description: map['description'] ?? "",
      index: map['index']!=null ? int.parse(map['index'].toString()) : 0
  );

}