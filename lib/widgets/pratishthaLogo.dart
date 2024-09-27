import 'package:flutter/material.dart';

Widget pratishthaTextLogo({BuildContext? context}) {

  return SizedBox(
    height: kToolbarHeight / 1.2,
    // width: MediaQuery.of(context).size.width,
    child: Container(
      width: MediaQuery.of(context!).size.width/2,
      child: Image.asset(
        'assets/images/PratishthaLogoText.png',
        fit: BoxFit.fitWidth,
      ),
    ),
  );

}