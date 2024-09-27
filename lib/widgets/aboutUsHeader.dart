import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  Header({this.head, this.color});
  final String? head;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
            child: Divider(
              color: color,
              thickness: 2.0,
            ),
          ),
          Text(
            head!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,

              fontWeight: FontWeight.w900,
              fontSize: 40.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
            child: Divider(
              color: color,
              thickness: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}