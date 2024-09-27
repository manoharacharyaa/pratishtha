import 'package:cloud_firestore/cloud_firestore.dart';

EWallet walletFromMap(Map<String, dynamic> data, String id) =>
    EWallet.fromMap(data, id);

Map walletToJson(EWallet data) => data.toJson();

class EWallet {
  EWallet(
      {this.id,
      this.value,
      this.date,
      this.reason,
      this.addedby,
      this.addedto,
      this.receipt});

  String? id;
  String? value;
  DateTime? date;
  String? reason;
  String? addedby;
  String? addedto;
  String? receipt;

  factory EWallet.fromMap(Map<String, dynamic> map, String id) => EWallet(
      id: id,
      value: map['value']!=null ? map["value"].toString() : '0',
      date: map["date"].toDate(),
      reason: map["reason"] ?? "",
      addedby: map["added_by"] ?? "",
      addedto: map["added_to"] ?? "",
      receipt: map["receipt"] ?? ""
  );

  Map<String, dynamic> toJson() => {
        'value': value,
        'date': Timestamp.fromDate(date!),
        'reason': reason,
        'added_by': addedby,
        'added_to': addedto,
        'receipt': receipt
      };
}
