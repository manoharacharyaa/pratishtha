import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/screens/rules/changeParticipantsStatusRulesPage.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/searchServices.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/rulesCard.dart';
import 'package:pratishtha/widgets/userCard.dart';

class ChangeParticipantStatus extends StatefulWidget {
  ChangeParticipantStatus(
      {super.key, this.eventId, this.participantsList, this.event});
  String? eventId;
  Event? event;
  List<List>? participantsList;

  @override
  _ChangeParticipantStatusState createState() =>
      _ChangeParticipantStatusState();
}

class _ChangeParticipantStatusState extends State<ChangeParticipantStatus> {
  Event? event;
  TextEditingController? searchTextEditingController = TextEditingController();
  List<User>? allRegisteredParticipantsList = [];
  List<User>? allCompletedParticipantsList = [];

  List<int>? displayRegisteredParticipantsList = [];
  List<int>? displayCompletedParticipantsList = [];

  bool choosingWinner = false;
  bool choosingRunnerUp = false;

  bool search = false;

  DatabaseServices databaseServices = DatabaseServices();

  bool canChooseWinners() {
    if (DateTime.now().isAfter(event!.dateTo!) &&
        event!.registration!.isEmpty) {
      return true;
    } else {
      return false;
    }
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
  Widget build(BuildContext context) {
    // List<List>? registration = widget.participantsList?[0];

    event = widget.event;
    return checkConection(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Update Participant Status",
            ),
            actions: [
              rulesIconButton(
                  context: context,
                  popUpPage: ChangeParticipantStatusRulesPage())
            ],
          ),
          body: buildList(widget.participantsList!)),
    );
  }

  buildList(List<List>? participantsList) {
    allRegisteredParticipantsList = participantsList![0] as List<User>;
    allCompletedParticipantsList = participantsList[1] as List<User>;
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              (MediaQuery.of(context).padding.bottom +
                  MediaQuery.of(context).padding.top),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: dullGreyColor.withOpacity(0.2)),
                  child: TextFormField(
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
                      List<int>? registeredUsersSearchResults;
                      List<int>? completedUsersSearchResults;
                      if (participantsList[0] == null ? false : true) {
                        registeredUsersSearchResults = userSearchWithIndex(
                            query: searchTextEditingController!.text,
                            allUsersList: participantsList[0] as List<User>);
                      }
                      if (participantsList[1] == null ? false : true) {
                        completedUsersSearchResults = userSearchWithIndex(
                            query: searchTextEditingController!.text,
                            allUsersList: participantsList[1] as List<User>);
                      }
                      setState(() {
                        displayRegisteredParticipantsList =
                            registeredUsersSearchResults;
                        displayCompletedParticipantsList =
                            completedUsersSearchResults;
                        search = true;
                      });

                      // Fluttertoast.showToast(
                      //     msg: "No Registration yet",
                      //     toastLength: Toast.LENGTH_LONG,
                      //     gravity: ToastGravity.BOTTOM,
                      //     timeInSecForIosWeb: 1,
                      //     backgroundColor: Colors.grey[600],
                      //     textColor: Colors.red,
                      //     fontSize: 16.0);
                    },
                    icon: Icon(
                      FontAwesomeIcons.search,
                      color: primaryColor,
                    )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        search = false;
                        displayRegisteredParticipantsList = [];
                        displayRegisteredParticipantsList = [];
                        searchTextEditingController!.text = "";
                      });
                    },
                    icon: Icon(
                      FontAwesomeIcons.times,
                      color: primaryColor,
                    ))
              ],
            ),
            SizedBox(height: 10),
            Text(
              "Registered Participants",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            event!.registration!.isEmpty
                //event.registration==null||event.registration==[]
                ? Center(
                    child: Text("No registered participants yet"),
                  )
                : Container(
                    margin: EdgeInsets.only(
                        top: 20, bottom: 20, left: 10, right: 10),
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: search
                          ? displayRegisteredParticipantsList!.length
                          : event!.registration!.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: buildRegisteredListItem(
                            search
                                ? allRegisteredParticipantsList![
                                    displayRegisteredParticipantsList![index]]
                                : allRegisteredParticipantsList![index],
                            index,
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 10),
            Text(
              "Completed Participants",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            canChooseWinners()
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              choosingWinner = true;
                              choosingRunnerUp = false;
                            });
                          },
                          child: Text("Choose Winners")),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              choosingWinner = false;
                              choosingRunnerUp = true;
                            });
                          },
                          child: Text("Choose Runners-Up"))
                    ],
                  )
                : Container(),
            SizedBox(height: 5),
            event!.completed!.isEmpty
                ? Center(
                    child: Text("No completed participants yet"),
                  )
                : Container(
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      //todo: make unique
                      itemCount: search
                          ? displayCompletedParticipantsList!.length
                          : event!.completed!.toSet().length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: buildCompletedListItem(search
                              ? allCompletedParticipantsList![
                                  displayCompletedParticipantsList![index]]
                              : allCompletedParticipantsList![index]),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 10),
            choosingWinner || choosingRunnerUp
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        choosingWinner = false;
                        choosingRunnerUp = false;
                      });
                    },
                    child: Text("Done"))
                : Container()
          ],
        ),
      ),
    );
  }

  buildRegisteredListItem(User participant, int index) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: blackColor)),
      child: Column(
        children: [
          Container(
              //width: MediaQuery.of(context).size.width / 1.6,
              child: UserCard(user: participant)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () async {
                    await databaseServices.updateRegisteredParticipantStatus(
                        participant: participant, event: event!);

                    widget.event =
                        await databaseServices.getEvent(widget.eventId!);
                    widget.participantsList =
                        await databaseServices.getParticipants(widget.eventId!);
                    setState(() {});
                  },
                  icon: Icon(FontAwesomeIcons.check)),
              VerticalDivider(color: dullGreyColor),
              IconButton(
                  onPressed: () async {
                    if (await showWarning(context: context) == true) {
                      await databaseServices.cancelParticipantRegistration(
                          participant: participant, event: event!);
                      setState(() {});
                    }
                  },
                  icon: Icon(FontAwesomeIcons.times)),
            ],
          ),
        ],
      ),
    );
  }

  buildCompletedListItem(User participant) {
    return Container(
      child: Row(
        children: [
          Flexible(child: UserCard(user: participant)),
          choosingWinner
              ? Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          if (event!.winners![participant.uid] == null) {
                            if (await showWarning(context: context) == true) {
                              await databaseServices.setWinner(
                                  participant: participant, event: event!);
                              widget.event = await databaseServices
                                  .getEvent(widget.eventId!);
                              widget.participantsList = await databaseServices
                                  .getParticipants(widget.eventId!);
                              setState(() {});
                            }
                          }
                        },
                        icon: Icon(
                          FontAwesomeIcons.trophy,
                          color: event!.winners![participant.uid] != null
                              ? goldColor
                              : dullGreyColor,
                        )),
                    SizedBox(width: 10)
                  ],
                )
              : Container(),
          choosingRunnerUp
              ? Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          if (await showWarning(context: context) == true) {
                            await databaseServices.setRunnerUp(
                                participant: participant, event: event!);
                            widget.event = await databaseServices
                                .getEvent(widget.eventId!);
                            widget.participantsList = await databaseServices
                                .getParticipants(widget.eventId!);
                            setState(() {});
                          }
                        },
                        icon: Icon(
                          FontAwesomeIcons.medal,
                          color: event!.winners![participant.uid] != null
                              ? goldColor
                              : dullGreyColor,
                        )),
                    SizedBox(width: 10)
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
