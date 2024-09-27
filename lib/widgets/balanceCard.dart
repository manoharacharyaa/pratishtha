import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/styles/mainTheme.dart';

class BalanceCard extends StatelessWidget {

  int? balValue;
  BuildContext? context;
  BalanceCard({this.balValue, this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      width: MediaQuery.of(context).size.width,
      //height: MediaQuery.of(context).size.height/7,
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
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
            child: Icon(FontAwesomeIcons.rupeeSign, color: currencyColor, size: 50,)
          ),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     // Padding(
          //     //   padding: const EdgeInsets.only(top: 10, bottom: 5),
          //     //   child: Text('Balance',
          //     //       style: TextStyle(
          //     //         fontSize: 24.0,
          //     //         fontWeight: FontWeight.bold,
          //     //         color: blackColor),
          //     //   ),
          //     // ),
          //     Padding(
          //       padding: const EdgeInsets.only(top: 0, bottom: 5),
          //       child: Text(balValue.toString(),
          //           style: TextStyle(
          //               fontSize: 60.0,
          //               color: blackColor),),
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
                  "BALANCE",
                  style: TextStyle(
                    fontSize: 14,
                    color: whiteColor,
                  ),
                ),
              ),
              Text(balValue.toString(),
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