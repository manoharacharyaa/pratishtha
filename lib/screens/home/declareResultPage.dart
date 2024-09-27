import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/screens/home/eventPage.dart';
import '../../constants/colors.dart';
import '../../widgets/connectivityChecker.dart';

class declareResultPage extends StatefulWidget {
  const declareResultPage(
      {required this.eventID, this.matchList, required this.index, required this.event});
  final String eventID;
  final dynamic matchList;
  final int index;
  final Event event;

  @override
  State<declareResultPage> createState() => _declareResultPageState();
}

class _declareResultPageState extends State<declareResultPage> {
  Map<String, Map<String, dynamic>> teams = {};
  Map<String, Map<String, dynamic>> teamsList = {};
  TextEditingController searchTextEditingController = TextEditingController();

  updateScoreForFestDocument(String id) async {
    var docRef = FirebaseFirestore.instance
        .collection('fests')
        .doc('2a95253317c848e7bddfe4a99ec38f4a')
        .collection('teams')
        .doc(id);

    docRef.update({'score': FieldValue.increment(1)});
  }

  updateScoreForEventDocument(String id, String eventID) async {
    var docRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventID)
        .collection('teams')
        .doc(id);

    docRef.update({'score': FieldValue.increment(1)});
  }

  Future<void> updateArrayElement(
      int index, Map<String, dynamic> newValue) async {
    var docRef =
    FirebaseFirestore.instance.collection('events').doc(widget.eventID);
    var snapshot = await docRef.get();
    var array = snapshot.data()!['matches'] as List;
    array[index] = newValue;
    docRef.update({'matches': array});
  }

  updateResult(String name) {
    Map<String, dynamic> teams = {
      "team01": widget.matchList['team01'],
      "team02": widget.matchList['team02'],
      "team01ID": widget.matchList['team01ID'],
      "team02ID": widget.matchList['team02ID'],
      "score01": widget.matchList['score01'],
      "score02": widget.matchList['score02'],
      "result": "${name} Wins",
      "resultsdeclare": true
    };
    updateArrayElement(widget.index, teams);
    Fluttertoast.showToast(
        msg: "Result Declared",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: blackColor,
        textColor: whiteColor,
        fontSize: 16.0);
  }

  Future<void> _onRefresh() async {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(
              'Delcare Results',
            ),
            centerTitle: true,
          ),
          body: buildList()),
    );
  }

  buildList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      displacement: 0,
      backgroundColor: blackColor,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("fests")
            .doc('2a95253317c848e7bddfe4a99ec38f4a')
            .collection('teams')
            .where('id', whereIn: [
          widget.matchList['team01ID'],
          widget.matchList['team02ID']
        ]).snapshots(),
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
            return Scaffold(
              body: Center(
                child: Text(
                  'No Teams Found',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }
          try {
            if (snapshots.hasData) {
              List<DocumentSnapshot> documents = snapshots.data!.docs;

              return (documents.length == 0)
                  ? Scaffold(
                body: Center(
                  child: Text(
                    'No Teams Found',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
                  : Column(
                children: [
                  ListView.builder(
                    itemCount: documents.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    addAutomaticKeepAlives: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
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
                              ListTile(
                                title: Text(
                                  "Team  ${documents[index]['name']}",
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: widget.matchList[
                                'resultsdeclare'] ==
                                    true
                                    ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.grey[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          8.0),
                                    ),
                                  ),
                                  child: Text(
                                    "Declared",
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () {
                                    Fluttertoast.showToast(
                                      msg:
                                      "Result Declared Already",
                                      toastLength:
                                      Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  },
                                )
                                    : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          8.0),
                                    ),
                                  ),
                                  label: Text(
                                    "Winner",
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    updateResult(
                                        documents[index]['name']);
                                    updateScoreForFestDocument(
                                        documents[index]['id']);
                                    updateScoreForEventDocument(
                                        documents[index]['id'],
                                        widget.eventID);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) =>
                                            EventPage(
                                              event: widget.event, key: null,
                                            )),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(),
                  Center(
                    child: Text(
                      "Results : ${widget.matchList['result']}",
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
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
}