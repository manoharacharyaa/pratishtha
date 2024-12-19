// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/constants/keys.dart';

import '../../widgets/connectivityChecker.dart';

class updateFestTeam extends StatefulWidget {
  List<dynamic> eventIdList;
  String idString;
  updateFestTeam(this.idString, this.eventIdList, {super.key});

  @override
  State<updateFestTeam> createState() => _updateFestTeamState();
}

class _updateFestTeamState extends State<updateFestTeam> {
  Future<void> _onRefresh() async {
    setState(() {});
    return Future.delayed(Duration(seconds: 1));
  }

  final _formKeys = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: RefreshIndicator(
          onRefresh: _onRefresh,

          // child: FutureBuilder(
          //   future: FirebaseFirestore.instance
          //         .collection("fests")
          //         .doc(prevOlympusID)
          //         .collection('teams')
          //         .where('soft_delete', isEqualTo: false)
          //         .get(),
          //     builder:
          //         // ignore: missing_return
          // (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots)

          //     if (snapshots.hasError) {
          //   return Center(
          //     child: Text(
          //       'Something went wrong',
          //       style: TextStyle(
          //         color: Theme.of(context).primaryColorDark,
          //         fontSize: 15,
          //         fontWeight: FontWeight.w700,
          //       ),
          //     ),
          //   );
          // }

          // if (snapshots.connectionState == ConnectionState.waiting) {
          //   return const Center(
          //     child: CircularProgressIndicator(
          //       color: primaryColor,
          //     ),
          //   );
          // }
          // if (snapshots.data.docs.isEmpty) {
          //   return Center(
          //     child: Text(
          //       'No Teams Found',
          //       style: TextStyle(
          //         color: Theme.of(context).primaryColorDark,
          //         fontSize: 15,
          //         fontWeight: FontWeight.w700,
          //       ),
          //     ),
          //   );
          // }
          // try{
          // if (snapshots.hasData) {
          // List<DocumentSnapshot> documents = snapshots.data.docs;
          // debugPrint('------------------------' + documents.toString());

          child: Scaffold(
            appBar: AppBar(
              title: Text("Edit Match Name"),
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
                          key: _formKeys,
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
                            if (firstNameController.text == '') {
                              Fluttertoast.showToast(
                                  msg: "Team name cannot be empty",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else {
                              // List<String> eventIdList= this.widget.teamDocument['events'];
                              //update name of team in fest
                              debugPrint(widget.idString);
                              FirebaseFirestore.instance
                                  .collection('fests')
                                  .doc(prevOlympusID)
                                  .collection("teams")
                                  .doc(widget.idString)
                                  .update({
                                'name': firstNameController.text
                                    .trim()
                                    .toUpperCase(),
                              });
                              //get id of event array
                              debugPrint('${widget.eventIdList}');
                              widget.eventIdList.forEach(
                                (element) {
                                  FirebaseFirestore.instance
                                      .collection('events')
                                      .doc(element)
                                      .collection("teams")
                                      .doc(widget.idString)
                                      .update({
                                    'name': firstNameController.text
                                        .trim()
                                        .toUpperCase()
                                  });
                                },
                              );
                              _onRefresh();
                            }
                            ;
                            // debugPrint(firstNameController.text);
                          },
                          child: Text("Add Team"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )

          // }
          // }
          //   catch (e) {
          //   return Scaffold(
          //     body: Center(
          //       child: Text(
          //         'No Teams Found ${e.toString()}',
          //         style: TextStyle(
          //           color: Theme.of(context).primaryColorDark,
          //           fontSize: 15,
          //           fontWeight: FontWeight.w700,
          //         ),
          //       ),
          //     ),
          //   );
          // }

          // ),
          ),
    );
  }
}
