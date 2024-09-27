import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';

Widget EventPointsCard({bool? forWinner, String? title, int? points, BuildContext? context}){
  return Container(
    height: MediaQuery.of(context!).size.width/3.5,
    width: MediaQuery.of(context).size.width/3.5,
    margin: EdgeInsets.all(5),
    padding: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 2),
    decoration: BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.circular(10)
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 33,
          backgroundImage: AssetImage(
              forWinner! ? "assets/gifs/trophy_burst_animation.gif" : "assets/gifs/medallion_burst_animation.gif"
          )
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              points.toString(),
              style: TextStyle(
                fontSize: 22,
                color: whiteColor,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(width: 4),
            Text(
              title!,
              style: TextStyle(
                fontSize: 10,
                color: whiteColor
              ),
            )
          ],
        )
      ],
    ),
  );
}