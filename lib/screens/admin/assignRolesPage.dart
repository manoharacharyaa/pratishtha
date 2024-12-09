import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/screens/rules/assignRolesRulesPage.dart';
import 'package:pratishtha/services/searchServices.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/rulesCard.dart';
import 'package:pratishtha/widgets/userCard.dart';

class AssignRoles extends StatefulWidget {
  const AssignRoles({super.key});

  @override
  _AssignRolesState createState() => _AssignRolesState();
}

class _AssignRolesState extends State<AssignRoles> {
  DatabaseServices databaseServices = DatabaseServices();
  TextEditingController searchTextEditingController = TextEditingController();

  List<User>? users;
  List<User>? displayUsersList;
  List<DocumentSnapshot>? rolesDoc;

  Map<int, String> roles = {};
  Map<String, int> reverseRoles = {};
  Map<int, int> updatedRoles = {};

  bool eventRoleUpdated = false;
  AsyncMemoizer? _memoizer;

  Future getPosts() async {
    try {
      users = await databaseServices.getUsers();
      users?.sort((a, b) => (a.firstName ?? '').compareTo(b.firstName ?? ''));
      displayUsersList = users;
      rolesDoc = await databaseServices.getRoles();
      return;
    } catch (e) {
      return e;
    }
  }

  Future<bool> saveUpdatedRoles() async {
    for (int key in updatedRoles.keys) {
      Map<String, int> data = {};
      //print('--------Ch 1');
      if (updatedRoles[key] == 0) {
        if (users![key].eventRoles != "") {
          List<String> roles = users![key].eventRoles!.split(', ');
          //print('--------');
          //print(roles);
          int highestRole = 1;
          for (String role in roles) {
            //print(role);
            if (role.split('-')[1] == '2') {
              //print('jere');
              highestRole = 2;
              break;
            }
          }
          data['role'] = highestRole;
        } else {
          data['role'] = updatedRoles[key]!;
        }
      } else {
        data['role'] = updatedRoles[key]!;
      }
      try {
        await databaseServices.updateUser(users![key].uid!, data);
      } catch (e) {
        //print(e.message);
        return false;
      }
    }
    return true;
  }

  Future<void> updateRoles() async {
    bool status = await saveUpdatedRoles();
    return ShowStatusPopup(status);
  }

  void changeRoles(int index, String value) {
    updatedRoles[index] = reverseRoles[value]!;
  }

  void initFunction() {
    for (DocumentSnapshot documentSnapshot in rolesDoc!) {
      if (documentSnapshot['id'] != 1 && documentSnapshot['id'] != 2) {
        roles[documentSnapshot['id']] = documentSnapshot['name'];
        reverseRoles[documentSnapshot['name']] = documentSnapshot['id'];
      }
    }
  }

  Future<void> _onRefresh() async {
    return;
  }

  Future<Future<bool?>> showWarning({BuildContext? context}) async {
    return showDialog<bool>(
      context: context!,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to do this?'),
                Text('You will not be able to reverse this change'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _memoizer = AsyncMemoizer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Assign Roles',
          ),
          actions: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: whiteColor,
                  border: Border.all(
                    color: whiteColor,
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
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () async {
                    if (await showWarning(context: context) == true) {
                      updateRoles();
                    }
                  },
                ),
              ),
            ),
            rulesIconButton(context: context, popUpPage: AssignRolesRulesPage())
          ],
        ),
        body: FutureBuilder(
          future: _memoizer?.runOnce(() async => await getPosts()),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loadingWidget();
            } else if (snapshot.hasError) {
              return CustomErrorWidget();
            } else {
              initFunction();
              return buildList();
            }
          },
        ),
      ),
    );
  }

  buildList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      displacement: 0,
      backgroundColor: blackColor,
      child: SingleChildScrollView(
        // physics: BouncingScrollPhysics(
        //   parent: AlwaysScrollableScrollPhysics(),
        // ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 15, right: 15, left: 15),
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: dullGreyColor.withOpacity(0.2)),
                  child: TextFormField(
                    onChanged: (value) {
                      handleSearch();
                    },
                    controller: searchTextEditingController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryColor)),
                      hintText: 'Search for Users',
                      hintStyle: TextStyle(
                        color: blackColor,
                      ),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      handleSearch();
                    },
                    icon: Icon(
                      FontAwesomeIcons.search,
                      color: primaryColor,
                    )),
                IconButton(
                    onPressed: () {
                      searchTextEditingController.text = "";
                      setState(() {
                        displayUsersList = users;
                      });
                    },
                    icon: Icon(
                      FontAwesomeIcons.times,
                      color: primaryColor,
                    ))
              ],
            ),
            SizedBox(height: 20),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: displayUsersList?.length,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: buildListItem(index),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  handleSearch() {
    List<User> tempList = userSearch(
        query: searchTextEditingController.text, allUsersList: users!);
    if (tempList.isNotEmpty) {
      setState(() {
        displayUsersList = tempList;
      });
    } else {
      displayUsersList = users;
    }
  }

  buildListItem(index) {
    return Card(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
      color: whiteColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: new BorderSide(
          color: blackColor,
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
            child: Column(
              children: [
                // Text(
                //   users[index].firstName + ' ' + users[index].lastName,
                // ),
                Container(
                    //width: MediaQuery.of(context).size.width / 1.8,
                    child: UserCard(user: displayUsersList![index])),
                SizedBox(height: 5),
                buildDropDownMenu(
                  displayUsersList?[index].role == 1 ||
                          displayUsersList?[index].role == 2
                      ? "Participant"
                      : roles[displayUsersList?[index].role] ?? "",
                  index,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildDropDownMenu(String dropdownValue, index) {
    return StatefulBuilder(
      builder: (context, stateChanged) {
        return DropdownButton<String>(
          value: dropdownValue,
          items: roles
              .map((key, value) => MapEntry(
                  key,
                  DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  )))
              .values
              .toList(),
          onChanged: (String? value) async {
            changeRoles(index, value!);
            dropdownValue = value;
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
        });
  }
}

class ShowEventRolePopup extends StatefulWidget {
  ShowEventRolePopup({
    super.key,
    this.dropDownValue,
    this.eventsMap,
  });

  String? dropDownValue;
  Map<String, String>? eventsMap;

  @override
  State<ShowEventRolePopup> createState() => _ShowEventRolePopupState();
}

class _ShowEventRolePopupState extends State<ShowEventRolePopup> {
  bool eventRoleUpdated = false;

  String eventKey = "-1";

  @override
  Widget build(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Event"),
          content: Container(
            height: 50,
            child: Center(
              child: DropdownButton<String>(
                value: widget.dropDownValue,
                items: widget.eventsMap
                    ?.map(
                      (key, value) => MapEntry(
                        key,
                        DropdownMenuItem<String>(
                          value: key,
                          child: Text(widget.eventsMap![key]!),
                        ),
                      ),
                    )
                    .values
                    .toList(),
                onChanged: (String? value) {
                  widget.dropDownValue = value;
                  setState(() {});
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                eventRoleUpdated = false;
                eventKey = '-1';
                Navigator.pop(context, [eventRoleUpdated, eventKey]);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                eventRoleUpdated = true;
                eventKey = widget.dropDownValue!;
                Navigator.pop(context, [eventRoleUpdated, eventKey]);
              },
              child: Text("Ok"),
            ),
          ],
        );
      },
    );
    return Container();
  }
}
