import 'package:flutter/material.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart' as sh;
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/eventCard.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/noContentWidget.dart';

class CompletedEvents extends StatefulWidget {
  const CompletedEvents({super.key});

  @override
  _CompletedEventsState createState() => _CompletedEventsState();
}

class _CompletedEventsState extends State<CompletedEvents> {
  List<Event> completedEvents = [];
  User? currentUser;
  DatabaseServices databaseServices = DatabaseServices();

  Future<List<Event>> getCompletedEvents() async {
    currentUser = await sh.getUserFromPrefs();
    List<String> completedEventIds = [];
    if (currentUser!.completedEvents!.isEmpty) {
      return [];
    }
    for (String key in currentUser!.completedEvents!.keys) {
      completedEventIds.add(key);
      // print(key);
      // print('-' * 80);
    }

    //print(completedEventIds);
    return await databaseServices.getSpecificEvents(completedEventIds);
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Completed Events",
          ),
        ),
        body: FutureBuilder(
          future: getCompletedEvents(),
          builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loadingWidget();
            } else if (snapshot.hasError) {
              //print("Completed events page snapshot error: ${snapshot.error}");
              return CustomErrorWidget();
            } else {
              if (snapshot.data!.isNotEmpty) {
                List<Event> tempList = [];
                if (currentUser!.role == 5 || currentUser!.role == 3) {
                  completedEvents = snapshot.data!;
                } else {
                  snapshot.data!.forEach((event) {
                    if (event.goLive) {
                      tempList.add(event);
                    }
                  });
                  completedEvents = tempList;
                }
              }
              return buildList();
            }
          },
        ),
      ),
    );
  }

  buildList() {
    return completedEvents.isEmpty
        ? Center(
            child: noContentWidget(
                message: "You do not have any finished events yet."))
        : Container(
            height: MediaQuery.of(context).size.height - 30,
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            margin: MediaQuery.of(context).padding,
            child: ListView.builder(
              itemCount: completedEvents.length,
              itemBuilder: (context, index) {
                return EventCard(
                    context: context,
                    event: completedEvents[index],
                    isVerified: currentUser!.isVerified);
              },
            ),
          );
  }
}
