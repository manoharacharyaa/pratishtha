import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart' as sh;

class AssignEventRoles extends StatefulWidget {
  const AssignEventRoles({
    super.key,
    this.role,
  });
  final int? role;

  @override
  _AssignEventRolesState createState() => _AssignEventRolesState();
}

class _AssignEventRolesState extends State<AssignEventRoles> {
  DatabaseServices databaseServices = DatabaseServices();

  User? currentUser;
  List<User>? users;
  List<Event>? events;

  Map<int, String> updatedEventRoles = {};
  Map<String, String> eventsMap = {};

  bool eventRoleUpdated = false;

  Future getPosts() async {
    try {
      currentUser = await sh.getUserFromPrefs();
      users = await databaseServices.getUsers();
      events = await databaseServices.getEvents();
      return;
    } catch (e) {
      return e;
    }
  }

  List<dynamic> saveUserChanges(User currentUser, Event currentEvent, int key) {
    bool userUpdated = false;
    List<String> currentSplit = updatedEventRoles[key]!.split('-');

    if (currentUser.eventRoles == "" || currentUser.eventRoles == null) {
      currentUser.eventRoles = updatedEventRoles[key];
      userUpdated = true;
    } else {
      //Getting existing event roles
      String? eventRolesString = currentUser.eventRoles;
      List<String> eventRoles = eventRolesString!.split(', ');
      //Checking if the role exist or not
      int length = eventRoles.length;

      if (widget.role == 2) {
        for (String str in eventRoles) {
          if (str.endsWith('2')) {
            String eventId = str.substring(0, str.indexOf('-'));
            Event roleEvent = events![getEventIndex(eventId)!];
            if (roleEvent.parentId == currentEvent.parentId) {
              return [currentUser, false];
            }
          }
        }
      }

      for (int i = 0; i < length; i++) {
        //Updating old role
        if (eventRoles[i].startsWith(currentSplit[0])) {
          if (!eventRoles[i].endsWith(currentSplit[1])) {
            eventRoles[i] = updatedEventRoles[key]!;
          }
          userUpdated = true;
          break;
        }
      }

      //Adding role if new
      if (!userUpdated) {
        eventRoles.add(updatedEventRoles[key]!);
        userUpdated = true;
      }
      currentUser.eventRoles = eventRoles.join(", ");
    }

    return [currentUser, userUpdated];
  }

  List<dynamic> saveEventChanges(
      User currentUser, Event currentEvent, int key) {
    bool eventUpdated = false;
    List? eventHeadList = currentEvent.eventHeads;
    List? volunteerList = currentEvent.volunteers;

    //if Event Head
    if (widget.role == 2) {
      //Check if already event head
      if (!eventHeadList!.contains(currentUser.uid)) {
        //check if volunteer
        if (volunteerList!.contains(currentUser.uid)) {
          volunteerList.remove(currentUser.uid);
        }

        //Add Event Head
        eventHeadList.add(currentUser.uid);
      }
      eventUpdated = true;
    } else {
      //Check if already volunteer
      if (!volunteerList!.contains(currentUser.uid)) {
        //check volunteer Limit
        if (currentEvent.volunteersLimit > volunteerList.length) {
          //check if event head
          if (eventHeadList!.contains(currentUser.uid)) {
            eventHeadList.remove(currentUser.uid);
          }

          //add volunteer
          volunteerList.add(currentUser.uid);
          //print(currentUser.firstName);
          //print(volunteerList);
          eventUpdated = true;
        } else {
          //print('V Limit Reached');
          //print('-' * 80);
        }
      } else {
        eventUpdated = true;
      }
    }

    currentEvent.volunteers = volunteerList;
    currentEvent.eventHeads = eventHeadList;

    //print(eventUpdated);

    return [currentEvent, eventUpdated];
  }

  Future<bool> saveUpdatedEventRoles() async {
    //Going through updated Event Roles
    int i = 0;
    for (int key in updatedEventRoles.keys) {
      i++;
      bool userUpdated = false;
      bool eventUpdated = false;
      User currentUser = users![key];

      //Splitting updated Event Roles
      List<String> currentSplit = updatedEventRoles[key]!.split('-');

      Event currentEvent = events![getEventIndex(currentSplit[0])!];
      List<dynamic> userResult =
          saveUserChanges(currentUser, currentEvent, key);

      currentUser = userResult[0];
      userUpdated = userResult[1];

      if (!userUpdated) {
        return false;
      }

      List<dynamic> eventResult =
          saveEventChanges(currentUser, currentEvent, key);

      currentEvent = eventResult[0];
      eventUpdated = eventResult[1];

      Map<String, dynamic> userData = {};
      userData['event_roles'] = currentUser.eventRoles;
      if (currentUser.role == 0 || currentUser.role == 1) {
        userData['role'] = widget.role;
      }

      Map<String, dynamic> eventData = currentEvent.toJson();

      if (eventUpdated) {
        try {
          await databaseServices.updateEvent(eventData, currentEvent.id!);
          await databaseServices.updateUser(currentUser.uid!, userData);
        } catch (e) {
          //print(e);
          return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  Future<void> updateRoles() async {
    bool status = await saveUpdatedEventRoles();
    return ShowStatusPopup(status);
  }

  bool assignEventRoles(int index, String value) {
    if (!eventRoleUpdated || value == '-1') {
      return false;
    } else {
      updatedEventRoles[index] = "";
      updatedEventRoles[index] = value + "-" + widget.role.toString();
      return true;
    }
  }

  int? getEventIndex(String key) {
    int length = events!.length;
    for (int i = 0; i < length; i++) if (events![i].id == key) return i;
    return null;
  }

  void initFunction() {
    eventsMap['-1'] = "Select Event";
    if (currentUser?.role != 2) {
      for (Event event in events!) {
        eventsMap[event.id!] = event.name!;
      }
    } else {
      String? eventRoleString = currentUser?.eventRoles!;
      List<String> eventRoles = eventRoleString!.split(", ");
      for (String eventRole in eventRoles) {
        List<String> splitRole = eventRole.split('-');
        if (splitRole[1] == '2') {
          int? index = getEventIndex(splitRole[0]);
          //print('-' * 80);
          //print(events[index].name);
          eventsMap[events![index!].id!] = events![index].name!;
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    return;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.role != 2 ? "Assign Volunteers" : 'Assign Event Heads',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              ),
              child: TextButton(
                child: Container(
                  child: Row(
                    children: [
                      Text(
                        "Save",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                onPressed: updateRoles,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getPosts(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text(
                'Loading',
              ),
            );
          } else {
            initFunction();

            return buildList();
          }
        },
      ),
    );
  }

  buildList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      displacement: 0,
      backgroundColor: Colors.black,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: ListView.builder(
          itemCount: users!.length,
          shrinkWrap: true,
          itemBuilder: (_, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: buildListItem(index),
            );
          },
        ),
      ),
    );
  }

  buildListItem(index) {
    return Card(
      elevation: 0,
      color: whiteColor,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
      shape: RoundedRectangleBorder(
        side: new BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(
          8.0,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text(
                  users![index].firstName! + ' ' + users![index].lastName!,
                ),
                Spacer(),
                buildDropDownMenu(index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildDropDownMenu(index) {
    String dropdownValue = '-1';
    return StatefulBuilder(
      builder: (context, stateChanged) {
        return DropdownButton<String>(
          value: dropdownValue,
          items: eventsMap
              .map((key, value) => MapEntry(
                  key,
                  DropdownMenuItem<String>(
                    value: key,
                    child: Text(value),
                  )))
              .values
              .toList(),
          onChanged: (String? value) {
            eventRoleUpdated = true;
            bool result = assignEventRoles(index, value!);
            if (result) {
              dropdownValue = value;
            } else {
              ShowStatusPopup(false);
            }
            eventRoleUpdated = false;
            stateChanged(() {});
          },
        );
      },
    );
  }

  ShowStatusPopup(bool status) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status
              ? 'All roles updated Successfully'
              : "There was some issue, please try again"),
        );
      },
    );
  }
}
