
Sponsorship sponsorshipFromMap(Map<String, dynamic> data, String id) =>
    Sponsorship.fromMap(data, id);

Map sponsorshipToJson(Sponsorship data) => data.toJson();

class Sponsorship {
  Sponsorship(
      {this.id,
      this.name,
      this.description = "",
      this.value = 0,
      this.imgUrl = "",
      this.logoUrl = "",
      this.softDelete
      });

  String? id;
  String? name;
  String description;
  double value;
  String imgUrl;
  String logoUrl;
  bool? softDelete;

  factory Sponsorship.fromMap(
          Map<String, dynamic> map, String id) =>
      Sponsorship(
          id: id,
          name: map['name'],
          description: map['description'] ?? "",
          value:
              map['value'] != null ? double.parse(map['value'].toString()) : 0,
          imgUrl: map['img_url'] ?? "",
          logoUrl: map['logo_url'] ?? "",
          softDelete: map["soft_delete"]);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'value': value,
        'img_url': imgUrl,
        'logo_url': logoUrl,
        "soft_delete":softDelete,
      };
}
