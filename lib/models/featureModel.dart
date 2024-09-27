
Features featuresFromMap(Map<String, dynamic> data, String id) => Features.fromMap(data, id);

class Features {
  Features({
    this.id,
    this.name = "",
    this.roles
  });

  int? id;
  String name;
  List<int>? roles;

  factory Features.fromMap(Map<String, dynamic> map, String id) => Features(
      id: map['id'],
    name: map['name'] ?? "",
    roles: map['roles'] ?? []
  );
}
