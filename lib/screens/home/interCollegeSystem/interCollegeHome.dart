import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/leaderBoard.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/adminInterCollegePage.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeCricketHome.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeFootballHome.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeKabaddiHome.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeTugofWarHome.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeVolleyballHome.dart';
import 'package:pratishtha/widgets/interCollegeSportsButton.dart';

class InterCollegeHome extends StatefulWidget {
  final int userRole;
  const InterCollegeHome({
    super.key,
    required this.userRole,
  });

  @override
  State<InterCollegeHome> createState() => _InterCollegeHomeState();
}

class _InterCollegeHomeState extends State<InterCollegeHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 30,
        ),
        backgroundColor: Color.fromRGBO(120, 78, 209, 1),
        centerTitle: true,
        title: Text(
          "Inter College",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.userRole == 8)
            CircleAvatar(
              backgroundColor: secondaryColor,
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AdminInterCollegePage()));
                },
              ),
            ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaderBoard()),
              );
            },
            child: Container(
              padding: EdgeInsets.only(right: 15),
              child: Image.asset(
                'assets/gifs/leaderboard_intercollege.gif',
                height: 50,
                // width: 45,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            color: Color.fromRGBO(120, 78, 209, 1),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.28,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      children: [
                        InterCollegeSportsButton(
                          context: context,
                          sportsIcon: Image.asset(
                              "assets/images/InterCollegeSports/cricket_logo_intercollege.png"),
                          sportsName: "Cricket",
                          navigator: MaterialPageRoute(
                              builder: (context) => InterCollegeCricketHome()),
                        ),
                        InterCollegeSportsButton(
                            context: context,
                            sportsIcon: Image.asset(
                                "assets/images/InterCollegeSports/football_icon_intercollege.jpg"),
                            sportsName: "Football",
                            navigator: MaterialPageRoute(
                                builder: (context) =>
                                    InterCollegeFootballHome())),
                        InterCollegeSportsButton(
                            context: context,
                            sportsIcon: Image.asset(
                                "assets/images/InterCollegeSports/volleyball_logo_intercollege.jpg"),
                            sportsName: "Volleyball",
                            navigator: MaterialPageRoute(
                                builder: (context) =>
                                    InterCollegeVolleyballHome())),
                        InterCollegeSportsButton(
                            context: context,
                            sportsIcon: Image.asset(
                                "assets/images/InterCollegeSports/kabaddi_logo_intercollege.svg"),
                            sportsName: "Kabaddi",
                            navigator: MaterialPageRoute(
                                builder: (context) =>
                                    InterCollegeKabaddiHome())),
                        InterCollegeSportsButton(
                            context: context,
                            sportsIcon: Image.asset(
                                "assets/images/InterCollegeSports/tugofwar_logo_intecollege.jpeg"),
                            sportsName: "Tug of War",
                            navigator: MaterialPageRoute(
                                builder: (context) =>
                                    InterCollegeTugofWarHome())),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
