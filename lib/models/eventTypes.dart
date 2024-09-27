
EventTypes eventTypeFromMap(Map<String, dynamic> data, int id) =>
    EventTypes.fromMap(data, id);

Map eventTypeToJson(EventTypes data, String id) => data.toJson();


class EventTypes {
  int? id;
  String? name;
  String? registrationLimit;

  EventTypes({this.id, this.name, this.registrationLimit});

  factory EventTypes.fromMap(Map<String, dynamic> map, int id) => EventTypes(
      id: id, name: map["name"], registrationLimit: map["registration_limit"]);

  Map<String, dynamic> toJson() => {
        'id':id,
        'name':name,
        'registration_limit': registrationLimit
      };
}
