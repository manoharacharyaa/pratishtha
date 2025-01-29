import 'dart:developer';

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/models/interCollege.dart';
import 'package:pratishtha/services/interCollegeServices.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  final List<Map<String, dynamic>> sportsTabs = [
    {'label': 'All', 'image': null, 'description': 'All Sports'},
    {
      'label': 'Cricket',
      'image': 'assets/images/InterCollegeSports/Cricket.png',
      'description': 'Cricket'
    },
    {
      'label': 'Football',
      'image': 'assets/images/InterCollegeSports/football.png',
      'description': 'Football'
    },
    {
      'label': 'Kabaddi',
      'image': 'assets/images/InterCollegeSports/Cricket.png',
      'description': 'Kabaddi'
    },
    {
      'label': 'Volleyball',
      'image': 'assets/images/InterCollegeSports/Cricket.png',
      'description': 'Volleyball'
    },
  ];

  int selectedIndex = 0;

  final List<String> sports = [
    "cricket",
    "football",
    "kabaddi",
    "volleyball_boys",
    "volleyball_girls"
  ];
  final Map<String, List<InterCollege>> sportsData = {};
  bool isLoading = true;

  var ic = InterCollegeServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAllCollegeSportsData();
  }

  Future<void> fetchAllCollegeSportsData() async {
    try {
      for (String sport in sports) {
        final colleges = await ic.fetchCollegesBySport(sport);
        sportsData[sport] = colleges;
      }
      print("${sportsData}");
    } catch (e) {
      print("Error fetching sports data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF784ED1),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 25,
        ),
        backgroundColor: Color.fromARGB(249, 34, 34, 50),
        foregroundColor:  Color.fromARGB(249, 34, 34, 50),
        title: Text(
          'LeaderBoard',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: isLoading
          ? loadingWidget()
          : SingleChildScrollView(
              child: Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: DefaultTabController(
                        length: sportsTabs.length,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ButtonsTabBar(
                                buttonMargin: EdgeInsets.symmetric(horizontal: 20.0),
                                radius: 50,
                                height: 50,
                                backgroundColor:
                                    Color.fromARGB(255, 247, 112, 67),
                                unselectedBackgroundColor: Color(0xFF222232),
                                unselectedLabelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                tabs: sportsTabs
                                    .map((sport) => Tab(
                                        child: sport['image'] == null
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                100))),
                                                height: 40,
                                                width: 40,
                                                child: Center(
                                                  child: Text(
                                                    sport['label'],
                                                    style: TextStyle(
                                                      color: selectedIndex == 0
                                                          ? Colors.white
                                                          : Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                width: selectedIndex ==
                                                        sportsTabs
                                                            .indexOf(sport)
                                                    ? 125.0
                                                    : 40.0,
                                                height: 40,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Image.asset(
                                                      width: 40,
                                                      height: 40,
                                                      sport['image'],
                                                    ),
                                                    if (selectedIndex ==
                                                        sportsTabs
                                                            .indexOf(sport))
                                                      Flexible(
                                                        child: AnimatedOpacity(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          opacity: 1.0,
                                                          child: Text(
                                                            sport['label'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              )))
                                    .toList(),
                                onTap: (index) {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ...sports.map((sport) {
                      final sportData = sportsData[sport] ?? [];
                      return buildSportsBoard(context, sport, sportData);
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildSportsBoard(
      BuildContext context, String sportName, List<InterCollege> colleges) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
            
                CircleAvatar(
                backgroundImage: AssetImage(
                  'assets/images/InterCollegeSports/${sportName}.png',
                ),
                radius: 25,
                backgroundColor: Colors.transparent,
                ),
              Text(sportName.toUpperCase(),
                  style: GoogleFonts.sourceSans3(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              color: const Color(0xFF222232),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Header Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 5),
                  child: Row(
                    children: [
                      // Team Header
                      Expanded(
                        flex: 2,
                        child: Text(
                          'TEAM',
                          style: GoogleFonts.sourceSans3(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Stat Headers
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children:  [
                            Text(
                              'MP',
                              style: GoogleFonts.sourceSans3(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'W',
                              style: GoogleFonts.sourceSans3(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'L',
                              style: GoogleFonts.sourceSans3(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'PTS',
                              style: GoogleFonts.sourceSans3(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white),
          
                // Leaderboard list
                Expanded(
                  child: ListView.builder(
                    itemCount: colleges.length,
                    itemBuilder: (context, index) {
                      final college = colleges[index];
                      final matchesPlayed = college.matchesPlayed![sportName] ?? 0;
                      final matchesWon = college.matchesWon![sportName] ?? 0;
                      final matchesLost = college.matchesLost![sportName] ?? 0;
          
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 14.0),
                            child: Row(
                              children: [
                                // College Name
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(college.imageUrl),
                                        radius: 15,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Tooltip(
                                          triggerMode: TooltipTriggerMode.tap,
                                          message: college
                                              .collegeName, // Full name as tooltip
                                          textStyle: GoogleFonts.sourceSans3(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .black, // Tooltip background color
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            // Extracting initials from the full name
                                            college.collegeName
                                                .split(' ')
                                                .map((word) => word.isNotEmpty
                                                    ? word[0]
                                                    : '') // First letter of each word
                                                .join(), // Join initials together
                                            style: GoogleFonts.sourceSans3(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Stats
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatValue(matchesPlayed),
                                      _buildStatValue(matchesWon),
                                      _buildStatValue(matchesLost),
                                      _buildStatValue(college.score,
                                          isPoints: true),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white54,
                            thickness: 1,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper method for stat values
  Widget _buildStatValue(int value, {bool isPoints = false}) {
    return Container(
      alignment: Alignment.center,
      width: 40, // Adjust width for responsiveness
      child: Text(
        value.toString(),
        style: TextStyle(
          color: isPoints? Colors.white : Colors.white70,
          fontWeight: isPoints ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
