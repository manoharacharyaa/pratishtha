import 'package:cloud_firestore/cloud_firestore.dart';

Points pointFromMap(Map<String, dynamic> data, String id) =>
    Points.fromMap(data, id);

Map pointToJson(Points data) => data.toJson();

class Points {
  Points(
      {this.id,
      this.value,
      this.date,
      this.reason,
      this.awardedby,
      this.awardedto,
      this.receipt});

  String? id;
  String? value;
  DateTime? date;
  String? reason;
  String? awardedby;
  String? awardedto;
  String? receipt;

  factory Points.fromMap(Map<String, dynamic> map, String id) => Points(
      id: id,
      value: map["value"].toString(),
      date: map["date"].toDate(),
      reason: map["reason"],
      awardedby: map["awarded_by"],
      awardedto: map["awarded_to"],
      receipt: map["recipt"]);

  Map<String, dynamic> toJson() => {
        'value': value,
        'date': Timestamp.fromDate(date!),
        'reason': reason,
        'awarded_by': awardedby,
        'awarded_to': awardedto,
        'receipt': receipt
      };
}
