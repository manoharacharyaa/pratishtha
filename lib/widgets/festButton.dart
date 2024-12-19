import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/constants/festIcons.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/screens/home/eventPage.dart';
import 'package:pratishtha/screens/home/festPage.dart';

Widget FestButton({
  Event? event,
  List<Event>? individualEventsList,
  BuildContext? context,
}) {
  Event? myChildEvent;
  if (event!.isEvent) {
    for (int i = 0; i < individualEventsList!.length; i++) {
      if (individualEventsList[i].parentId == event.id) {
        myChildEvent = individualEventsList[i];
        break;
      }
    }
  }

  return Container(
    child: Column(
      children: [
        GestureDetector(
          onTap: () {
            if (event.isEvent) {
              Navigator.push(
                context!,
                MaterialPageRoute(
                  builder: (context) => EventPage(event: myChildEvent!),
                ),
              );
            } else {
              Navigator.push(
                context!,
                MaterialPageRoute(
                  builder: (context) => FestPage(
                    event: event,
                  ),
                ),
              );
            }
          },
          child: Container(
            // color: Theme.of(context).primaryColor,
            width: 50,
            height: 50,
            // child: FaIcon(FaIconMapping['robot']),
            child: festIcons?[event.icon!],
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
            ),
          ),
        ),
        // Icon(
        //   Icons.ten_k,
        //   size: 50.0,
        //   color: Theme.of(context).primaryColor,
        // ),
        SizedBox(
          height: 10.0,
        ),
        Text(
          event.name!,
          style: TextStyle(
            fontSize: 15.0,
          ),
        )
      ],
    ),
  );
}
