import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';

Widget MojiCustomize(BuildContext context){
  return Scaffold(
    body: Center(
      child: Container(
        padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height,
        child: Column(

          children: [
            FluttermojiCircleAvatar(radius: 100,),
            SizedBox(
              height: 50.0,
            ),
            FluttermojiCustomizer(),
          ],
        ),
      ),
    ),
  );
}
