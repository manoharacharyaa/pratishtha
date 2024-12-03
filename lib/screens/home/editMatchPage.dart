// ignore_for_file: missing_return

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:pratishtha/screens/home/declareResultPage.dart';
import '../../models/eventModel.dart';
import '../../services/databaseServices.dart';
import '../../widgets/connectivityChecker.dart';
import '../../widgets/customTextField.dart';

class editMatchPage extends StatefulWidget {
  const editMatchPage({
    required this.event,
    this.matchList,
    required this.index,
  }) : super();
  final Event event;
  final dynamic matchList;
  final int index;

  @override
  State<editMatchPage> createState() => _editMatchPageState();
}

class _editMatchPageState extends State<editMatchPage> {
  final TextEditingController score01 = TextEditingController();
  final TextEditingController score02 = TextEditingController();

  @override
  void initState() {
    score01.text = widget.matchList['score01'] ?? '';
    score02.text = widget.matchList['score02'] ?? '';
    super.initState();
  }

  Future<void> updateArrayElement(
      int index, Map<String, dynamic> newValue) async {
    var docRef =
        FirebaseFirestore.instance.collection('events').doc(widget.event.id);

    var snapshot = await docRef.get();
    var array = snapshot.data()!['matches'] as List;

    array[index] = newValue;
    docRef.update({'matches': array});
  }

  updateData() {
    Map<String, dynamic> teams = {
      "team01": widget.matchList['team01'],
      "team02": widget.matchList['team02'],
      "score01": score01.text,
      "score02": score02.text,
      "team01ID": widget.matchList['team01ID'],
      "team02ID": widget.matchList['team02ID'],
      'result': widget.matchList['result'],
      "resultsdeclare": widget.matchList['resultsdeclare'],
    };
    updateArrayElement(widget.index, teams);
  }

  late Event eventData;
  var db = DatabaseServices();
  final addkey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Match"),
          centerTitle: true,
        ),
        body: widget.matchList['resultsdeclare'] == true
            ? Center(
                child: Text(
                  'Results Already Declared',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Form(
                  key: addkey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      CustomTextField1(
                        controller: score01,
                        hintText:
                            'Enter Team ${widget.matchList['team01']} Score',
                        labelText: 'Team ${widget.matchList['team01']} Score',
                        validator: validateIsEmpty,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      CustomTextField1(
                        controller: score02,
                        hintText:
                            'Enter Team ${widget.matchList['team02']} Score',
                        labelText: 'Team ${widget.matchList['team02']} Score',
                        validator: validateIsEmpty,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      Divider(),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => declareResultPage(
                                matchList: widget.matchList,
                                eventID: widget.event.id.toString(),
                                index: widget.index,
                                event: widget.event,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Declare Resuls',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        floatingActionButton: widget.matchList['resultsdeclare'] == true
            ? Container()
            : FloatingActionButton(
                onPressed: () {},
                backgroundColor: Theme.of(context).primaryColor,
                child: IconButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          updateData();
                        },
                  icon: isLoading
                      ? LoadingIndicator(
                          indicatorType: Indicator.ballClipRotateMultiple)
                      : const Icon(
                          Icons.upload,
                        ),
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
