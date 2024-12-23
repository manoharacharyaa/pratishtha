import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';

Widget InterCollegeSportsButton({
  required BuildContext context,
  required Icon sportsIcon,
  required String sportsName,
  required MaterialPageRoute navigator,
}) {
  return Container(
    child: Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(navigator);
          },
          child: Container(
            // color: Theme.of(context).primaryColor,
            width: 50,
            height: 50,
            // child: FaIcon(FaIconMapping['robot']),
            child: sportsIcon,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
            ),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(
          sportsName,
          style: TextStyle(
            fontSize: 15.0,
          ),
        )
      ],
    ),
  );
}
