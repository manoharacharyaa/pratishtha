import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pratishtha/models/pointModel.dart';
import 'package:pratishtha/services/databaseServices.dart';

class PointsServices {
  final CollectionReference pointCollection =
      FirebaseFirestore.instance.collection('points');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  //Add Points
  Future addPoints({String? toUid, String? value, String? reason}) async {
    var userdata = await DatabaseServices().getCurrentUser();
    if (userdata.role >= 1) {
      var pointData = pointCollection.doc();
      await pointData.set(pointToJson(Points(
          value: value,
          awardedto: toUid,
          awardedby: userdata.uid,
          date: DateTime.now(),
          reason: reason)));

      return await userCollection.doc(toUid).update({
        "points": FieldValue.increment(int.parse(value!)),
        "points_history": FieldValue.arrayUnion([pointData.id])
      });
    } else {
      return false;
    }
  }

  //Get Points history
  Future<Points> getpointHist(String id) async {
    var pointdata = await pointCollection.doc(id).get();
    return pointFromMap(pointdata.data() as Map<String, dynamic>, pointdata.id);
  }
}
