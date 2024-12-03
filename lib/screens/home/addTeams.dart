import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/constants/keys.dart';
import '../../constants/colors.dart';
import '../../widgets/connectivityChecker.dart';

class addTeamPage extends StatefulWidget {
  const addTeamPage({required this.eventID});
  final String eventID;

  @override
  State<addTeamPage> createState() => _addTeamPageState();
}

class _addTeamPageState extends State<addTeamPage> {
  GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
  Map<String, Map<String, dynamic>> teams = {};
  Map<String, Map<String, dynamic>> teamsList = {};
  TextEditingController searchTextEditingController = TextEditingController();

  Future<void> updateEventForFestDocument(String id, String eventID) async {
    var docRef = FirebaseFirestore.instance
        .collection('fests')
        .doc(prevOlympusID)
        .collection('teams')
        .doc(id);

    docRef.update({
      'events': FieldValue.arrayUnion([eventID])
    });
  }

  @override
  void initState() {
    super.initState();
    // _fetchData();
  }

  addTeamForEvent(String id, dynamic team) {
    var db = FirebaseFirestore.instance;
    db
        .collection('events')
        .doc(id)
        .collection('teams')
        .doc(team['id'])
        .set(team);
    Fluttertoast.showToast(
      msg: "Team Added Successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  removeTeamForEvent(String id, dynamic team) {
    var db = FirebaseFirestore.instance;
    db
        .collection('events')
        .doc(id)
        .collection('teams')
        .doc(team['id'])
        .delete();
    Fluttertoast.showToast(
      msg: "Team Deleted Successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  removeEventId(String id, dynamic team) {
    var db = FirebaseFirestore.instance;
    db.collection('fests').doc(id).collection('teams').doc(team['id']).delete();
    Fluttertoast.showToast(
      msg: "Team Deleted Successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // @override
  // void initState() {
  //   _memoizer = AsyncMemoizer();
  //   super.initState();
  // }

  Future<void> _onRefresh() async {
    setState(() {});
    return Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Add Teams',
          ),
          centerTitle: true,
        ),
        body: buildList(),
      ),
    );
  }

  buildList() {
    return RefreshIndicator(
      key: _refresh,
      onRefresh: _onRefresh,
      displacement: 0,
      child: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("fests")
            .doc(prevOlympusID)
            .collection('teams')
            .where('soft_delete', isEqualTo: false)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
          if (snapshots.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }
          if (snapshots.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Teams Found',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }
          try {
            if (snapshots.hasData) {
              List<DocumentSnapshot> documents = snapshots.data!.docs;
              debugPrint('------------------------' + documents.toString());

              return (documents.length == 0)
                  ? Center(
                      child: Text(
                        'No Teams Found',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: documents.length,
                      shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      addAutomaticKeepAlives: true,
                      itemBuilder: (BuildContext context, int index) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Card(
                              margin: EdgeInsets.only(
                                  left: 20, right: 20, bottom: 5),
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
                                  // (documents[index]['soft_delete']==false)?
                                  ListTile(
                                    title: Text(
                                      "${documents[index]['name']}",
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: documents[index]['events']
                                            .contains(this.widget.eventID)
                                        ? Column(
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: redColor,
                                                  alignment: Alignment.center,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                child: Text(
                                                  "Remove",
                                                  style: TextStyle(
                                                    color: whiteColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    // backgroundColor: greyColor,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  // Fluttertoast.showToast(
                                                  //   msg: "Team Already Added",
                                                  //   toastLength: Toast.LENGTH_SHORT,
                                                  //   gravity: ToastGravity.BOTTOM,
                                                  //   timeInSecForIosWeb: 1,
                                                  //   backgroundColor: Colors.grey,
                                                  //   textColor: Colors.white,
                                                  //   fontSize: 16.0,
                                                  // );

                                                  debugPrint("ON PRESSED");
                                                  await removeTeamPossible(
                                                          teamId:
                                                              documents[index]
                                                                  ['id'])
                                                      ? {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "fests")
                                                              .doc(
                                                                  prevOlympusID)
                                                              .collection(
                                                                  "teams")
                                                              .doc(documents[
                                                                  index]["id"])
                                                              .update({
                                                            "events": FieldValue
                                                                .arrayRemove([
                                                              this
                                                                  .widget
                                                                  .eventID
                                                            ])
                                                          }),

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'events')
                                                              .doc(this
                                                                  .widget
                                                                  .eventID)
                                                              .collection(
                                                                  "teams")
                                                              .doc(documents[
                                                                  index]['id'])
                                                              .delete()
                                                          // .update({
                                                          //   "soft_delete": true,
                                                          // })
                                                        }
                                                      : Fluttertoast.showToast(
                                                          msg:
                                                              "Cannot delete team",
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: ToastGravity
                                                              .BOTTOM,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor:
                                                              Colors.grey,
                                                          textColor:
                                                              Colors.white,
                                                          fontSize: 16.0,
                                                        );
                                                  _onRefresh();
                                                },
                                              ),
                                              // (documents[index]['soft_delete'])
                                              // ElevatedButton(
                                              //     style: ElevatedButton.styleFrom(
                                              //       backgroundColor: redColor,
                                              //       shape: RoundedRectangleBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(8.0),
                                              //       ),
                                              //     ),
                                              //     child: Text(
                                              //       "Remove",
                                              //       style: TextStyle(
                                              //         color: whiteColor,
                                              //         fontSize: 14,
                                              //         fontWeight: FontWeight.w600,
                                              //       ),
                                              //     ),
                                              //     onPressed: () {
                                              //       // Fluttertoast.showToast(
                                              //       //   msg: "Team Already Added",
                                              //       //   toastLength: Toast.LENGTH_SHORT,
                                              //       //   gravity: ToastGravity.BOTTOM,
                                              //       //   timeInSecForIosWeb: 1,
                                              //       //   backgroundColor: Colors.red,
                                              //       //   textColor: Colors.white,
                                              //       //   fontSize: 16.0,
                                              //       // );
                                              //       Map<String, dynamic> team = {
                                              //     'name': documents[index]['name'],
                                              //     'id': documents[index]['id'],
                                              //     'score': 0,
                                              //         // documents[index]['score'],
                                              //     'events': documents[index]
                                              //         ['events'],
                                              //   };
                                              //   // documents[index]['soft_delete']=true;
                                              //       // removeTeamForEvent(this.widget.eventID, team);
                                              //       // removeEventId(this.widget.eventID, team);
                                              //     },
                                              //   ),
                                            ],
                                          )
                                        : ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            label: Text(
                                              "Add",
                                              style: TextStyle(
                                                color: whiteColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              Map<String, dynamic> team = {
                                                'name': documents[index]
                                                    ['name'],
                                                'id': documents[index]['id'],
                                                'score': 0,
                                                // documents[index]['score'],
                                                'events': documents[index]
                                                    ['events'],
                                                'soft_delete': documents[index]
                                                    ['soft_delete'],
                                              };
                                              addTeamForEvent(
                                                  this.widget.eventID, team);
                                              updateEventForFestDocument(
                                                  documents[index]['id'],
                                                  this.widget.eventID);
                                              _onRefresh();
                                            },
                                          ),
                                  ),
                                  // :null,
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          } catch (e) {
            return Scaffold(
              body: Center(
                child: Text(
                  'No Teams Found ${e.toString()}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  buildListItem(documents) {
    return;
  }

  Future<bool> removeTeamPossible({required String teamId}) async {
    debugPrint("can we remove the team?");
    DocumentSnapshot eventTeamDetailsDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(this.widget.eventID)
        .collection('teams')
        .doc(teamId)
        .get();

    debugPrint("eventTeamDetailsDoc: ${eventTeamDetailsDoc}");

    Map? eventTeamDetails = eventTeamDetailsDoc.data() as Map?;

    debugPrint("eventTeamDetails: ${eventTeamDetails}");

    if (eventTeamDetails!['score'] == 0) {
      return true;
    } else {
      return false;
    }
  }
}
