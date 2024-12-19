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

class RegisteredEvents extends StatefulWidget {
  const RegisteredEvents({super.key});

  @override
  _RegisteredEventsState createState() => _RegisteredEventsState();
}

class _RegisteredEventsState extends State<RegisteredEvents> {
  List<Event> registeredEvents = [];
  User? currentUser;
  DatabaseServices databaseServices = DatabaseServices();

  Future<List<Event>> getRegisteredEvents() async {
    currentUser = await sh.getUserFromPrefs();
    List<String> registeredEventIds = [];
    if (currentUser!.registeredEvents!.isEmpty) {
      return [];
    }
    for (String key in currentUser!.registeredEvents!.keys) {
      //print(key);
      if (currentUser!.completedEvents!.keys.contains(key)) {
        if (currentUser!.registeredEvents![key] -
                currentUser!.completedEvents![key] ==
            0) {
          continue;
        } else {
          registeredEventIds.add(key);
        }
      } else {
        registeredEventIds.add(key);
      }
      // print(key);
      // print('-' * 80);
    }

    //print(registeredEventIds);
    return await databaseServices.getSpecificEvents(registeredEventIds);
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Registered Events",
          ),
        ),
        body: FutureBuilder(
          future: getRegisteredEvents(),
          builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loadingWidget();
            } else if (snapshot.hasError) {
              debugPrint(
                  "registered events page snapshot error: ${snapshot.error}");
              return CustomErrorWidget();
            } else {
              if (snapshot.data!.isNotEmpty) {
                List<Event> tempList = [];
                if (currentUser!.role == 5 || currentUser!.role == 3) {
                  registeredEvents = snapshot.data!;
                } else {
                  snapshot.data!.forEach((event) {
                    if (event.goLive) {
                      tempList.add(event);
                    }
                  });
                  registeredEvents = tempList;
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
    return registeredEvents.isEmpty
        ? Center(
            child: noContentWidget(
                message:
                    "What are you waiting for? Go register for some events right now!"))
        : Container(
            height: MediaQuery.of(context).size.height - 30,
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            margin: MediaQuery.of(context).padding,
            child: ListView.builder(
              itemCount: registeredEvents.length,
              itemBuilder: (context, index) {
                return EventCard(
                    context: context,
                    event: registeredEvents[index],
                    isVerified: currentUser!.isVerified);
              },
            ),
          );
  }
}
