import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/constants/keys.dart';
import 'package:pratishtha/screens/home/updateFestTeam.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:uuid/uuid.dart';

class AddTeamToFest extends StatefulWidget {
  const AddTeamToFest({super.key});

  @override
  State<AddTeamToFest> createState() => _AddTeamToFestState();
}

class _AddTeamToFestState extends State<AddTeamToFest> {
  final _formKey = GlobalKey<FormState>();
  late String id;
  final TextEditingController firstNameController = TextEditingController();
  Future<void> addfestteam(String name) async {
    var subCollRef = FirebaseFirestore.instance
        .collection('fests')
        .doc(prevOlympusID)
        .collection('teams');

    var uid = Uuid();
    String id = uid.v4().split("-").join("");

    Map<String, dynamic> teamFest = {
      "name": name,
      "score": 0,
      "soft_delete": false,
      "events": [],
      "id": id
    };

    var docRef = subCollRef.doc(id);
    docRef.set(teamFest);
    Fluttertoast.showToast(
        msg: "Team Added Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Match"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0x0fffffff),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          controller: firstNameController,
                          keyboardType: TextInputType.name,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            // errorText: validateIsEmptyFest(firstNameController.text),
                            labelText: "Team Name",
                            floatingLabelStyle: const TextStyle(
                              color: purpleAccentColor,
                              fontWeight: FontWeight.w600,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                width: 2,
                                color: purpleAccentColor,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          onSaved: (value) {
                            firstNameController.text = value!;
                          },
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        (firstNameController.text == '')
                            ? Fluttertoast.showToast(
                                msg: "Team name cannot be empty",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0)
                            : {
                                addfestteam(firstNameController.text),
                                _onRefresh()
                              };
                        // debugPrint(firstNameController.text);
                      },
                      child: Text("Add Team"),
                    ),
                    buildList()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateIsEmptyFest(value) {
    if (value.isEmpty) {
      return "Field Cannot be Empty";
      return null;
    }
    return null;
  }

  Future<void> _onRefresh() async {
    setState(() {});
    return Future.delayed(Duration(seconds: 1));
  }

  buildList() {
    return Container(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        displacement: 0,
        backgroundColor: blackColor,
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
                        physics: NeverScrollableScrollPhysics(),
                        addAutomaticKeepAlives: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Divider(),
                                Card(
                                  margin: EdgeInsets.only(
                                      left: 20, right: 20, bottom: 5),
                                  color: whiteColor,
                                  elevation: 0,
                                  // shape: RoundedRectangleBorder(
                                  //   side: new BorderSide(
                                  //     color: blackColor,
                                  //     width: 1.0,
                                  //   ),
                                  //   borderRadius: BorderRadius.circular(
                                  //     8.0,
                                  //   ),
                                  // ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${documents[index]['name']}",
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: redColor,
                                              alignment: Alignment.center,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            child: Text(
                                              "Remove",
                                              style: TextStyle(
                                                color: whiteColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                // alignment: Alignment.center,
                                                // backgroundColor: greyColor,
                                              ),
                                            ),
                                            onPressed: () {
                                              // Fluttertoast.showToast(
                                              //   msg: "Team Already Added",
                                              //   toastLength: Toast.LENGTH_SHORT,
                                              //   gravity: ToastGravity.BOTTOM,
                                              //   timeInSecForIosWeb: 1,
                                              //   backgroundColor: Colors.grey,
                                              //   textColor: Colors.white,
                                              //   fontSize: 16.0,
                                              // );
                                              (documents[index]['score'] == 0 &&
                                                      documents[index]['events']
                                                              .length ==
                                                          0)
                                                  ? {
                                                      // FirebaseFirestore.instance
                                                      //     .collection("fests")
                                                      //     .doc(prevOlympusID)
                                                      //     .collection("teams")
                                                      //     .doc(documents[index]["id"])
                                                      //     .update({
                                                      //       "events": FieldValue.arrayRemove([this.widget.eventID])
                                                      //     }),

                                                      FirebaseFirestore.instance
                                                          .collection('fests')
                                                          .doc(prevOlympusID)
                                                          .collection("teams")
                                                          .doc(documents[index]
                                                              ['id'])
                                                          .update({
                                                        'soft_delete': true,
                                                      })
                                                    }
                                                  : Fluttertoast.showToast(
                                                      msg: "Cannot delete team",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          Colors.grey,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0,
                                                    );
                                              _onRefresh();
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(FontAwesomeIcons.edit),
                                            onPressed: () {
                                              String idname =
                                                  documents[index]['id'];
                                              debugPrint("inside on press");
                                              debugPrint('${idname}');
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        // updateFestTeam(idname)
                                                        updateFestTeam(
                                                            documents[index]
                                                                ['id'],
                                                            documents[index]
                                                                ['events'])),
                                              );
                                            },
                                          ),
                                        ],
                                      ),

                                      // ListTile(

                                      //   title:

                                      //   Text(
                                      //     "${documents[index]['name']}",
                                      //     style: TextStyle(
                                      //       color: blackColor,
                                      //       fontSize: 16,
                                      //       fontWeight: FontWeight.w600,
                                      //     ),
                                      //   ),

                                      //   trailing:
                                      //   //  documents[index]['fests']
                                      //   // //         .contains(prevOlympusID) &&
                                      //   //         documents[index]['soft_delete']==false

                                      //        Column(
                                      //         mainAxisAlignment: MainAxisAlignment.center,
                                      //         crossAxisAlignment: CrossAxisAlignment.center,
                                      //         children: [
                                      //           ElevatedButton(

                                      //               style: ElevatedButton.styleFrom(
                                      //                 backgroundColor: redColor,
                                      //                 alignment: Alignment.center,

                                      //                 shape: RoundedRectangleBorder(
                                      //                   borderRadius:
                                      //                       BorderRadius.circular(8.0),

                                      //                 ),
                                      //               ),
                                      //               child: Text(
                                      //                 "Remove",

                                      //                 style: TextStyle(
                                      //                   color: whiteColor,
                                      //                   fontSize: 14,
                                      //                   fontWeight: FontWeight.w600,
                                      //                   // alignment: Alignment.center,
                                      //                   // backgroundColor: greyColor,
                                      //                 ),
                                      //               ),
                                      //               onPressed: () {
                                      //                 // Fluttertoast.showToast(
                                      //                 //   msg: "Team Already Added",
                                      //                 //   toastLength: Toast.LENGTH_SHORT,
                                      //                 //   gravity: ToastGravity.BOTTOM,
                                      //                 //   timeInSecForIosWeb: 1,
                                      //                 //   backgroundColor: Colors.grey,
                                      //                 //   textColor: Colors.white,
                                      //                 //   fontSize: 16.0,
                                      //                 // );
                                      //                 (documents[index]['score']==0 && documents[index]['events'].length==0)?
                                      //                 {
                                      //                 // FirebaseFirestore.instance
                                      //                 //     .collection("fests")
                                      //                 //     .doc(prevOlympusID)
                                      //                 //     .collection("teams")
                                      //                 //     .doc(documents[index]["id"])
                                      //                 //     .update({
                                      //                 //       "events": FieldValue.arrayRemove([this.widget.eventID])
                                      //                 //     }),

                                      //                 FirebaseFirestore.instance
                                      //                     .collection('fests')
                                      //                     .doc(prevOlympusID)
                                      //                     .collection("teams")
                                      //                     .doc(documents[index]['id'])

                                      //                     .update({
                                      //                       'soft_delete': true,
                                      //                     })
                                      //                     }: Fluttertoast.showToast(
                                      //                       msg: "Cannot delete team",
                                      //                       toastLength: Toast.LENGTH_SHORT,
                                      //                       gravity: ToastGravity.BOTTOM,
                                      //                       timeInSecForIosWeb: 1,
                                      //                       backgroundColor: Colors.grey,
                                      //                       textColor: Colors.white,
                                      //                       fontSize: 16.0,
                                      //                     );
                                      //                     _onRefresh();
                                      //               },
                                      //             ),
                                      //           // (documents[index]['soft_delete'])
                                      //           // ElevatedButton(
                                      //           //     style: ElevatedButton.styleFrom(
                                      //           //       backgroundColor: redColor,
                                      //           //       shape: RoundedRectangleBorder(
                                      //           //         borderRadius:
                                      //           //             BorderRadius.circular(8.0),
                                      //           //       ),
                                      //           //     ),
                                      //           //     child: Text(
                                      //           //       "Remove",
                                      //           //       style: TextStyle(
                                      //           //         color: whiteColor,
                                      //           //         fontSize: 14,
                                      //           //         fontWeight: FontWeight.w600,
                                      //           //       ),
                                      //           //     ),
                                      //           //     onPressed: () {
                                      //           //       // Fluttertoast.showToast(
                                      //           //       //   msg: "Team Already Added",
                                      //           //       //   toastLength: Toast.LENGTH_SHORT,
                                      //           //       //   gravity: ToastGravity.BOTTOM,
                                      //           //       //   timeInSecForIosWeb: 1,
                                      //           //       //   backgroundColor: Colors.red,
                                      //           //       //   textColor: Colors.white,
                                      //           //       //   fontSize: 16.0,
                                      //           //       // );
                                      //           //       Map<String, dynamic> team = {
                                      //           //     'name': documents[index]['name'],
                                      //           //     'id': documents[index]['id'],
                                      //           //     'score': 0,
                                      //           //         // documents[index]['score'],
                                      //           //     'events': documents[index]
                                      //           //         ['events'],
                                      //           //   };
                                      //           //   // documents[index]['soft_delete']=true;
                                      //           //       // removeTeamForEvent(this.widget.eventID, team);
                                      //           //       // removeEventId(this.widget.eventID, team);
                                      //           //     },
                                      //           //   ),
                                      //         ],
                                      //       ),
                                      // ),

                                      // :null,
                                      //SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  buildListItem(documents) {
    return;
  }

  updateFestTeamName(document, documents) {
    return Container(child: Text('hello'));
  }
}
