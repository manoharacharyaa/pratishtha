import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/models/councilModel.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/ewalletModel.dart';
import 'package:pratishtha/models/infoModel.dart';
import 'package:pratishtha/models/sponsorshipsModel.dart';
import 'package:pratishtha/models/teamModel.dart';
import 'package:pratishtha/models/userModel.dart' as user;
import 'package:pratishtha/services/pointServices.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart' as sh;
import 'package:pratishtha/services/storageServices.dart';
import 'package:uuid/uuid.dart';

class DatabaseServices {
  final FirebaseAuth auth = FirebaseAuth.instance;

  StorageServices storageServices = StorageServices();

  final CollectionReference eventCollection =
      FirebaseFirestore.instance.collection('events');

  final CollectionReference festCollection =
      FirebaseFirestore.instance.collection('fests');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference walletCollection =
      FirebaseFirestore.instance.collection('e-wallet');

  final CollectionReference rolesCollection =
      FirebaseFirestore.instance.collection('roles');

  final CollectionReference featuresCollection =
      FirebaseFirestore.instance.collection('features');

  final CollectionReference eventTypesCollection =
      FirebaseFirestore.instance.collection('event_types');

  final CollectionReference councilCollection =
      FirebaseFirestore.instance.collection('council2425');

  final CollectionReference teamCollection =
      FirebaseFirestore.instance.collection('team');

  final CollectionReference infoCollection =
      FirebaseFirestore.instance.collection('info');

  final CollectionReference sponsorCollection =
      FirebaseFirestore.instance.collection('sponsorships'); //sponsorship

  final CollectionReference rulesCollection =
      FirebaseFirestore.instance.collection('rules');

  PointsServices pointsServices = PointsServices();

  //Add Event
  Future addEvent(Event data, String id) async {
    var doc = eventCollection.doc(id);
    await doc.set(eventToJson(data));
    // var fcm = FirebaseMessaging();
    // String IID_TOKEN =await .getToken();

    return doc;
  }

  //Add Event
  Future addFest(Event data, String id) async {
    var doc = festCollection.doc(id);
    await doc.set(festToJson(data));
    // var fcm = FirebaseMessaging();
    // String IID_TOKEN =await .getToken();

    return doc;
  }

  //Update Event
  Future updateEvent(Map<String, Object?> data, String id) async {
    return await eventCollection.doc(id).update(data);
  }

  //Update Fest
  Future updateFest(Map<String, Object?> data, String id) async {
    return await festCollection.doc(id).update(data);
  }

  Future updateChildEvent(String docid, String eventid) async {
    return await festCollection.doc(docid).update({
      "child_id": FieldValue.arrayUnion([eventid]),
    });
  }

  //Get Current User
  Future<user.User> getCurrentUser() async {
    var userdata = await userCollection.doc(auth.currentUser!.uid).get();
    user.User usr =
        user.userFromMap(userdata.data() as Map<String, dynamic>, userdata.id);
    sh.setUserFromPrefs(usr);
    sh.setValuesInPrefs(
        uid: usr.uid!,
        firstName: usr.firstName!,
        lastName: usr.lastName!,
        roleId: usr.role,
        email: usr.email!,
        phoneNo: usr.phone!);
    return usr;
  }

  //Get User
  Future<user.User> getUser(String id) async {
    var userdata = await userCollection.doc(id).get();
    user.User currentUser =
        user.userFromMap(userdata.data() as Map<String, dynamic>, userdata.id);
    return currentUser;
  }

  //Get single user
  Future<user.User> getSingleUser(String id) async {
    var userdata = await userCollection.doc(id).get();
    user.User currentUser =
        user.userFromMap(userdata.data() as Map<String, dynamic>, userdata.id);
    return currentUser;
  }

//Get Event
  Future updateUser(String id, Map<String, dynamic> data) async {
    await userCollection.doc(id).update(data);
  }

  //Get Event
  Future<Event> getEvent(String id) async {
    var eventData = await eventCollection.doc(id).get();
    return eventFromMap(eventData.data() as Map<String, dynamic>, eventData.id);
  }

  //Get Event
  Future<Event> getFest(String id) async {
    var festData = await festCollection.doc(id).get();
    return eventFromMap(festData.data() as Map<String, dynamic>, festData.id);
  }

// change user Role for event
  void updateRoles(String id, Event event, List roleIds, int role) async {
    var currentUser = await this.getUser(id);
    int max_role = 0;

    String eventRolesString = currentUser.eventRoles!;
    List<String> eventRoles = [];
    List<String> currentSplit;
    bool isPresent = false;
    if (currentUser.eventRoles == "" || currentUser.eventRoles == null) {
      //print("is null");

      isPresent = true;
      eventRoles.add("${event.id}-${role}");
    } else {
      //Getting existing event roles
      eventRoles = eventRolesString.split(', ');

      //Checking if the role exist or not
      int length = eventRoles.length;
      for (int i = 0; i < length; i++) {
        //Updating old role
        currentSplit = eventRoles[i].split("-");

        //print(currentSplit[0]);

        if (currentSplit[0] == event.id) {
          isPresent = true;
          if (roleIds.isEmpty || !roleIds.contains(id)) {
            //print("here ${roleIds.isEmpty}");
            eventRoles.removeAt(i);
            // print("eh:");
            // print(eventRoles);
          } else if (!eventRoles[i].endsWith(role.toString())) {
            eventRoles[i] = "${currentSplit[0]}-${role}";
            break;
          }
        }
      }
    }
    if (!isPresent) {
      eventRoles.add("${event.id}-${role}");
    }

    //change roles field
    eventRoles.forEach((element) {
      if (int.parse(element.split("-")[1]) > max_role) {
        max_role = int.parse(element.split("-")[1]);
      }
    });
    currentUser.eventRoles = eventRoles.join(", ");
    //print(currentUser.eventRoles);
    if (currentUser.role < role && currentUser.role < max_role) {
      currentUser.role = max_role;
    }

    await userCollection.doc(id).update(
        {"event_roles": currentUser.eventRoles, "role": currentUser.role});
  }

  //Register for Event

  Future<String> registerEvent(String eventId) async {
    //Getting Data
    Event eventData = await getEvent(eventId);
    user.User userData = await getCurrentUser();
    var walletInfo = walletCollection.doc();

    Map registeredEvents = userData.registeredEvents!;
    Map<String, dynamic>? walledData;

    var uid = Uuid();
    String id = uid.v4() + "-" + DateTime.now().toString();

    String result = "";
    String reason;

    Map eventTypes = await sh.getEventTypesListFromPrefs();
    bool eventTypeCheck = false;
    for (var key in eventTypes.keys) {
      //print(key.runtimeType);
    }
    Map currentEvent = eventTypes[eventData.type.toString()];

    if (currentEvent['registration_limit'].toString() == 1.toString()) {
      eventTypeCheck = !registeredEvents.containsKey(eventId) ? true : false;
    } else {
      eventTypeCheck = true;
    }

    if (!userData.isVerified) {
      result = "To enable registration, please verify your Email Id";
      Fluttertoast.showToast(msg: result, toastLength: Toast.LENGTH_LONG);
    } else {
      if (!eventTypeCheck) {
        result = "You have already registered for this event.";
        Fluttertoast.showToast(msg: result, toastLength: Toast.LENGTH_LONG);
      } else {
        if (registeredEvents.containsKey(eventId)) {
          registeredEvents[eventId] += 1;
        } else {
          registeredEvents[eventId] = 1;
        }

        if (userData.wallet < eventData.price) {
          result =
              "You do not have enough money to register for this event. Please get some money added to your wallet and try again.";
          Fluttertoast.showToast(msg: result, toastLength: Toast.LENGTH_LONG);
        } else {
          if (eventData.participantsLimit != -1 &&
              (eventData.registration!.length + eventData.completed!.length) >=
                  eventData.participantsLimit) {
            result = "Sorry, registrations for this event have closed.";
            Fluttertoast.showToast(msg: result, toastLength: Toast.LENGTH_LONG);
          } else {
            if (eventData.registration!.contains(userData.uid)) {
              result = "You have already registered for this event.";
              Fluttertoast.showToast(
                  msg: result, toastLength: Toast.LENGTH_LONG);
            } else {
              String? reason = "";
              try {
                await eventCollection.doc(eventId).update({
                  "registration": FieldValue.arrayUnion([userData.uid]),
                  "total_collected": FieldValue.increment(eventData.price),
                });

                await userCollection.doc(userData.uid).update({
                  "registered_events": registeredEvents,
                  "wallet": FieldValue.increment(-eventData.price),
                  "wallet_history": FieldValue.arrayUnion([id]),
                });

                reason = "${userData.firstName! + " " + userData.lastName!} "
                    "Registered to ${eventData.name}";

                user.User currentuser = await sh.getUserFromPrefs();
                currentuser.registeredEvents = registeredEvents;
                sh.setUserFromPrefs(currentuser);

                result = "Successful";
              } catch (e) {
                //print(e);
                reason = "${userData.firstName! + " " + userData.lastName!} "
                    "tried registering to ${eventData.name} but could not because "
                    "${e}";

                result = "Unsuccessful";
              } finally {
                walledData = walletToJson(EWallet(
                  id: id,
                  value: '-${eventData.price}',
                  addedto: userData.uid,
                  addedby: eventId,
                  date: DateTime.now(),
                  reason: reason,
                )) as Map<String, dynamic>?;
                walletCollection.doc(id).set(walledData);

                return result;
              }
            }
          }
        }
      }
    }

    return result;
  }

  //Get  all Events
  Future<List<Event>> getEvents() async {
    QuerySnapshot querySnapshot =
        await eventCollection.where("soft_delete", isEqualTo: false).get();

    return querySnapshot.docs.map((doc) {
      //print(doc.data());
      return eventFromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  //Get  all Fest
  Future<List<Event>> getFests() async {
    QuerySnapshot querySnapshot =
        await festCollection.where("thisyear", isEqualTo: true).get();

    return querySnapshot.docs
        .map((doc) => eventFromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<user.User>> getUsers() async {
    QuerySnapshot querySnapshot =
        await userCollection.where("soft_delete", isEqualTo: false).get();

    return querySnapshot.docs
        .map((doc) =>
            user.userFromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<user.User>> getSakecUsers() async {
    QuerySnapshot querySnapshot = await userCollection
        .where("soft_delete", isEqualTo: false)
        .where("institute", isEqualTo: "SAKEC")
        .get();

    return querySnapshot.docs
        .map((doc) =>
            user.userFromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Get all roles
  Future<List<DocumentSnapshot>> getRoles() async {
    QuerySnapshot querySnapshot = await rolesCollection.get();

    return querySnapshot.docs;
  }

  Future<Map?> checkGeneralFeatureAccess() async {
    try {
      QuerySnapshot querySnapshot = await featuresCollection.get();
      Map featureMap = {};

      querySnapshot.docs.forEach((doc) {
        featureMap[doc.id] = doc.data();
      });

      bool result = await sh.setFeatureListValuesInPrefs(featureMap);
      if (result) {
        return featureMap;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
Future<List<user.User>> getApprovedUser(eventId) async {
  List<user.User> approvedUsers = [];

  DocumentSnapshot eventDoc = await eventCollection.doc(eventId).get();

  if (eventDoc.exists) {
    List<dynamic> approvedUsersList = eventDoc.get('approved_users') ?? [];

    for (var userMap in approvedUsersList) {
      String userId = userMap.keys.first; // Get the user ID from the map

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        approvedUsers.add(user.userFromMap(userData, userDoc.id));
      }
    }
  }

  return approvedUsers;
}


Future<void> updateUserPoints( eventId,  userId, int newPoints) async {
  DocumentReference eventRef = eventCollection.doc(eventId);
  DocumentSnapshot eventDoc = await eventRef.get();

  if (eventDoc.exists) {
    List<dynamic> approvedUsersList = eventDoc.get('approved_users') ?? [];

    bool userFound = false;

    for (var userMap in approvedUsersList) {
      if (userMap.containsKey(userId)) {
        userMap[userId]['points'] = newPoints; // Update points
        userFound = true;
        break;
      }
    }
    if (!userFound) {
      approvedUsersList.add({
        userId: {'points': newPoints}
      });
    }

    // Update Firestore
    await eventRef.update({'approved_users': approvedUsersList});
  }
}


  
  Future<List<user.User>> getSpecificUsers(List idList) async {
    List<user.User> users = [];
    int length = idList.length;

    for (int i = 0; i < length; i += 10) {
      int j = length > i + 10 ? i + 10 : length;
      QuerySnapshot querySnapshot = await userCollection
          .where('uid', whereIn: idList.sublist(i, j))
          .get();

      users.addAll(
        querySnapshot.docs
            .map((doc) =>
                user.userFromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList(),
      );
    }

    return users;
  }

  Future<List<Event>> getSpecificEvents(List idList) async {
    List<Event> events = [];
    int length = idList.length;
    if (idList.isNotEmpty) {
      for (int i = 0; i < length; i += 10) {
        int j = length > i + 10 ? i + 10 : length;
        QuerySnapshot querySnapshot = await eventCollection
            .where('id', whereIn: idList.sublist(i, j))
            .get();

        events.addAll(
          querySnapshot.docs
              .map((doc) =>
                  eventFromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList(),
        );
      }

      //TODO: Implement remove where
      return events;
    } else
      return [];
  }

  Future<void> getEventTypes() async {
    QuerySnapshot querySnapshot = await eventTypesCollection.get();
    Map eventTypesMap = {};

    querySnapshot.docs.forEach((doc) {
      eventTypesMap[doc.id] = doc.data();
    });
    sh.setEventTypesListInPrefs(eventTypesMap);
  }

  Future<void> getRules() async {
    QuerySnapshot querySnapshot = await rulesCollection.get();
    Map rulesMap = {};

    querySnapshot.docs.forEach((doc) {
      rulesMap[doc.id] = doc.data();
    });
    sh.setRulesInPrefs(rulesMap);
  }

  Future<void> updateRegisteredParticipantStatus(
      {user.User? participant, Event? event}) async {
    PointsServices pointsServices = PointsServices();
    await pointsServices.addPoints(
        toUid: participant!.uid,
        value: event!.participationPoints.toString(),
        reason: 'Successfully participated in ${event.name}');
    Event latestEvent = await getEvent(event.id!);
    List latestCompleted = latestEvent.completed! + [participant.uid];
    await eventCollection.doc(event.id).update({
      "registration": FieldValue.arrayRemove([participant.uid]),
      //"completed": FieldValue.arrayUnion([participant.uid])
      "completed": latestCompleted
    });
    if (participant.completedEvents![event.id] != null) {
      await userCollection
          .doc(participant.uid)
          .update({"completed_events.${event.id}": FieldValue.increment(1)});
    } else {
      await userCollection
          .doc(participant.uid)
          .update({"completed_events.${event.id}": 1});
    }
    Fluttertoast.showToast(msg: "Status updated successfully");
  }

  Future<void> cancelParticipantRegistration(
      {user.User? participant, Event? event}) async {
    await pointsServices.addPoints(
        toUid: participant!.uid,
        value: '-${event!.participationPoints}',
        reason: 'Failed to participate in ${event.name} despite registering.');
    await eventCollection.doc(event.id).update({
      "registration": FieldValue.arrayRemove([participant.uid])
    });
    Fluttertoast.showToast(msg: "Status updated successfully");
  }

  Future<void> setWinner({user.User? participant, Event? event}) async {
    await userCollection
        .doc(participant!.uid)
        .update({"achievements.${event!.id}": "Winner"});
    await eventCollection
        .doc(event.id)
        .update({"winners.${participant.uid}": "Winner"});
    await pointsServices.addPoints(
        toUid: participant.uid,
        value: event.winnerPoints.toString(),
        reason: 'Congratulations! You won ${event.name}');
  }

  Future<void> setRunnerUp({user.User? participant, Event? event}) async {
    await userCollection
        .doc(participant!.uid)
        .update({"achievements.${event!.id}": "Runner-Up"});
    await eventCollection
        .doc(event.id)
        .update({"winners.${participant.uid}": "Runner-Up"});
    await pointsServices.addPoints(
        toUid: participant.uid,
        value: event.runnerUpPoints.toString(),
        reason: 'Congratulations! You were a Runner-Up in ${event.name}');
  }

  Future<List<Council>> getCouncilDetails() async {
    QuerySnapshot querySnapshot =
        await councilCollection.orderBy('index').get();

    return querySnapshot.docs
        .map((doc) => councilFromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Team>> getTeamDetails() async {
    QuerySnapshot querySnapshot = await teamCollection.orderBy('index').get();

    List<Team> temp = querySnapshot.docs
        .map((doc) => teamFromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return temp;
  }

  Future<List<Info>> getInfo() async {
    QuerySnapshot querySnapshot = await infoCollection.orderBy('index').get();

    List<Info> temp = querySnapshot.docs
        .map((doc) => infoFromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return temp;
  }

  updateSoftDeleteAndGoLiveStatusForEvents(
      {bool? goLive, bool? softDelete, bool? closeEvent, Event? event}) async {
    if (!event!.closeEvent && closeEvent!) {
      PointsServices pointsServices = PointsServices();
      if (event.eventHeads!.isNotEmpty) {
        event.eventHeads!.forEach((eventHeadId) async {
          await pointsServices.addPoints(
              toUid: eventHeadId,
              value: '${event.eventHeadPoints}',
              reason: "Event Head for ${event.name}");
        });
      }
      if (event.volunteers!.isNotEmpty) {
        event.volunteers!.forEach((volunteerId) async {
          await pointsServices.addPoints(
              toUid: volunteerId,
              value: '${event.volunteerPoints}',
              reason: "Volunteer for ${event.name}");
        });
      }
    }
    await eventCollection.doc(event.id).update({
      "go_live": goLive,
      "soft_delete": softDelete,
      "close_event": closeEvent
    });
    Fluttertoast.showToast(
        msg: "Event status updated", toastLength: Toast.LENGTH_LONG);
  }

  updateSoftDeleteAndGoLiveStatusForFests(
      {bool? goLive, bool? softDelete, Event? event}) async {
    await festCollection
        .doc(event!.id)
        .update({"go_live": goLive, "soft_delete": softDelete});
    Fluttertoast.showToast(
        msg: "Event status updated", toastLength: Toast.LENGTH_LONG);
  }

  Future<List<List>> getParticipants(String eventId) async {
    Event event = await getEvent(eventId);
    List<user.User>? registeredUsers;
    List<user.User>? completedUsers;
    if (event.registration!.isNotEmpty) {
      registeredUsers = await getSpecificUsers(event.registration!);
    }
    if (event.completed!.isNotEmpty) {
      completedUsers = await getSpecificUsers(event.completed!);
    }
    return [registeredUsers!, completedUsers!];
  }

  addSponsor(Sponsorship data, String id) async {
    return await sponsorCollection.doc(id).set(sponsorshipToJson(data));
  }

  updateSponsor(Map<String, dynamic> data, String id) async {
    return await sponsorCollection
      ..doc(id).update(data);
  }

  deleteSponsor(Sponsorship data) async {
    if (data.imgUrl.isNotEmpty) storageServices.deleteImage(data.imgUrl);
    if (data.logoUrl.isNotEmpty) storageServices.deleteImage(data.logoUrl);
    return await sponsorCollection.doc(data.id).delete();
  }

  Future<List<Sponsorship>> getSponsors() async {
    QuerySnapshot querySnapshot =
        await sponsorCollection.where("soft_delete", isEqualTo: false).get();

    return querySnapshot.docs
        .map((doc) =>
            sponsorshipFromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  updateAvatar({int? avatar, user.User? currentUser}) async {
    await userCollection.doc(currentUser!.uid).update({"avatar": avatar});
  }

  updateUserVerifiedStatus({user.User? user}) async {
    await userCollection.doc(user!.uid).update({"is_verified": true});
  }
}
