import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/eventModel.dart';

Widget AchievementsWidget({BuildContext? context, Event? event, String? position}) {
  return Container(
    margin: EdgeInsets.only(right: 10),
    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
    // width: MediaQuery.of(context).size.width/7,
    width: MediaQuery.of(context!).size.width / 3,
    height: MediaQuery.of(context).size.width / 2,

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: primaryColor,
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
              radius: 33,
              backgroundImage: AssetImage(
                  position=="Winner" ? "assets/gifs/trophy_burst_animation.gif" : "assets/gifs/medallion_burst_animation.gif"
              )
          ),
          SizedBox(
            height: 10,
          ),
          AutoSizeText(
            "$position in ${event?.name}",
            maxFontSize: 14,
            minFontSize: 10,
            style: TextStyle(
              color: whiteColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
