import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:uuid/uuid.dart';

class addMatchFormPage extends StatefulWidget {
  const addMatchFormPage({
    required this.eventID,
  }) : super();
  final String eventID;

  @override
  _addMatchFormPageState createState() => _addMatchFormPageState();
}

class _addMatchFormPageState extends State<addMatchFormPage> {
  late String team1;
  late String team2;
  late String team1ID;
  late String team2ID;
  late Event eventData;
  var db = DatabaseServices();
  final addkey = GlobalKey<FormState>();
  bool isLoading = false;

  late Map<String, dynamic>? _selectedDocumentTeam1;
  late Map<String, dynamic>? _selectedDocumentTeam2;
  late List<DropdownMenuItem<Map<String, dynamic>>> _dropdownMenuItemsTeam1 =
      [];
  late List<DropdownMenuItem<Map<String, dynamic>>> _dropdownMenuItemsTeam2 =
      [];
  late List _documentsTeam1 = [];
  late List _documentsTeam2 = [];
  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _getDocuments().then((results) {
      setState(() {
        _documentsTeam1 = results;
        _documentsTeam2 = results;
        _dropdownMenuItemsTeam1 = buildDropdownMenuItems(_documentsTeam1);
        _dropdownMenuItemsTeam2 = buildDropdownMenuItems(_documentsTeam2);
        _selectedDocumentTeam1 = _dropdownMenuItemsTeam1.isNotEmpty
            ? _dropdownMenuItemsTeam1.first.value
            : null;
        _selectedDocumentTeam2 = _dropdownMenuItemsTeam2.isNotEmpty
            ? _dropdownMenuItemsTeam2.first.value
            : null;
      });
    });
  }

  Future<List> _getDocuments() async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore
        .collection("events")
        .doc(widget.eventID)
        .collection('teams')
        .get();
    return qn.docs;
  }

  List<DropdownMenuItem<Map<String, dynamic>>> buildDropdownMenuItems(
      List documents) {
    List<DropdownMenuItem<Map<String, dynamic>>> items = [];
    for (int i = 0; i < documents.length; i++) {
      DocumentSnapshot document = documents[i];
      if (documents[i]['soft_delete'] == false) {
        items.add(
          DropdownMenuItem<Map<String, dynamic>>(
            value: document.data() as Map<String, dynamic>,
            child: Text(document['name']),
          ),
        );
      }
    }
    return items;
  }

  void changedDropDownItemTeam1(Map<String, dynamic>? selectedDocument) {
    if (selectedDocument != null) {
      setState(() {
        _selectedDocumentTeam1 = selectedDocument;
        team1 = _selectedDocumentTeam1!['name'];
        team1ID = _selectedDocumentTeam1!['id'];
      });
    }
  }

  void changedDropDownItemTeam2(Map<String, dynamic>? selectedDocument) {
    if (selectedDocument != null) {
      setState(() {
        _selectedDocumentTeam2 = selectedDocument;
        team2 = _selectedDocumentTeam2!['name'];
        team2ID = _selectedDocumentTeam2!['id'];
      });
    }
  }

  void uploadMatch() async {
    String matchId = uuid.v4();
    if (addkey.currentState!.validate()) {
      addkey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> teams = {
        "matchId": matchId,
        "team01": team1,
        "team02": team2,
        "team01ID": team1ID,
        "team02ID": team2ID,
        "score01": "0",
        "score02": "0",
        'resultsdeclare': false,
        "result": 'No results'
      };

      FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventID)
          .update({
        "matches": FieldValue.arrayUnion([teams]),
      }).then((value) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Match Added Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Match"),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Form(
            key: addkey,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Select Team 1",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<Map<String, dynamic>>(
                  value: _selectedDocumentTeam1,
                  items: _dropdownMenuItemsTeam1,
                  onChanged: (Map<String, dynamic>? selectedDocument) {
                    changedDropDownItemTeam1(selectedDocument);
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Select Team 2",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<Map<String, dynamic>>(
                  value: _selectedDocumentTeam2,
                  items: _dropdownMenuItemsTeam2,
                  onChanged: (Map<String, dynamic>? selectedDocument) {
                    changedDropDownItemTeam2(selectedDocument);
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: isLoading
              ? null
              : () {
                  uploadMatch();
                },
          backgroundColor: Theme.of(context).primaryColor,
          child: isLoading
              ? LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple)
              : const Icon(
                  Icons.upload,
                ),
        ),
      ),
    );
  }

  String validateIsEmpty(value) {
    if (value.isEmpty) {
      return "Field Cannot be Empty";
    } else {
      return "";
    }
  }
}
