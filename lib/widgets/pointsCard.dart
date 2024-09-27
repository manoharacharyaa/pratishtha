import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/styles/mainTheme.dart';

class PointsCard extends StatelessWidget {

  int? pointsValue;
  BuildContext? context;
  PointsCard({this.pointsValue, this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [containerShadow]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Icon(FontAwesomeIcons.trophy,size: 40,color: currencyColor),
            // child: Text('🥰',
            //   style: mainTheme.textTheme.headline3,
            // ),
          ),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(top: 10, bottom: 5),
          //       child: Text('Points',
          //           style: TextStyle(
          //               fontSize: 24.0,
          //               fontWeight: FontWeight.bold,
          //               color: blackColor),),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(top: 5, bottom: 5),
          //       child: Text(pointsValue.toString(),
          //           style: TextStyle(
          //               fontSize: 50.0,
          //               //fontWeight: FontWeight.bold,
          //               color: blackColor)),
          //     ),
          //   ],
          // ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "POINTS",
                  style: TextStyle(
                    fontSize: 14,
                    color: whiteColor,
                  ),
                ),
              ),
              Text(pointsValue.toString(),
                style: TextStyle(
                    fontSize: 40.0,
                    color: whiteColor),),
            ],
          ),
        ],
      ),
    );
  }
}