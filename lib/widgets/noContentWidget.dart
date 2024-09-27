import 'package:flutter/material.dart';

Widget noContentWidget({String message = "No Content"}) {
  return Container(
    padding: EdgeInsets.all(10),
    alignment: Alignment.center,
    child: Column(
      children: [
        Image.asset('assets/images/resultnotFound.png'),
        Text(message, textAlign: TextAlign.center,)
      ],
    ),
  );
}
