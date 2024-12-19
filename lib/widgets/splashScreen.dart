import 'dart:async';

import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/screens/authenticationWrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  _splashScreenState createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  initScreen(BuildContext context) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() async {
    var duration = Duration(seconds: 2);
    return new Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => AuthenticationWrapper()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: whiteColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Mahavir Education Trust's",
                textScaleFactor: 2,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplaySc(
                    textStyle: TextStyle(
                        fontSize: 10,
                        color: sakecColor,
                        fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            Container(
              child: Image.asset('assets/images/SakecLogo.png'),
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            Text('Shah And Anchor Kutchhi Engineering College',
                textScaleFactor: 2,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplaySc(
                    textStyle: TextStyle(
                        fontSize: 15,
                        color: sakecColor,
                        fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
