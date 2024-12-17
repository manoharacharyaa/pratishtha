import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';

class PointsCard extends StatelessWidget {
  int? pointsValue;
  BuildContext? context;
  PointsCard({this.pointsValue, this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          color: primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Icon(
                          FontAwesomeIcons.trophy,
                          size: 40,
                          color: currencyColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "POINTS",
                          style: TextStyle(
                            fontSize: 14,
                            color: whiteColor,
                          ),
                        ),
                      ],
                    ),
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
                  Text(
                    pointsValue.toString(),
                    style: TextStyle(fontSize: 40.0, color: whiteColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
