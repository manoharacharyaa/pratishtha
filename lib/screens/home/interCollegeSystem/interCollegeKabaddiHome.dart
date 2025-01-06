import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pratishtha/models/kabaddiInterCollege.dart';
import 'package:pratishtha/services/interCollegeServices.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';

class InterCollegeKabaddiHome extends StatefulWidget {
  final String currentAcademicYear;
  const InterCollegeKabaddiHome({required this.currentAcademicYear, super.key});

  @override
  State<InterCollegeKabaddiHome> createState() =>
      _InterCollegeKabaddiHomeState();
}

class _InterCollegeKabaddiHomeState extends State<InterCollegeKabaddiHome> {
  late Future<List<InterCollegeKabaddiMatch>> allKabaddiMatches;
  bool isExtended = false;

  @override
  void initState() {
    super.initState();
    allKabaddiMatches = InterCollegeServices()
        .getAllInterCollegeKabaddiMatches(widget.currentAcademicYear);
    print(allKabaddiMatches);
  }

  List<String> splitScore(String score) {
    final regex = RegExp(r'^(.*?)(\s*\(.*\))?$');
    final match = regex.firstMatch(score);
    if (match != null) {
      return [match.group(1) ?? '', match.group(2)?.trim() ?? ''];
    }
    return [score];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          FutureBuilder<List<InterCollegeKabaddiMatch>>(
            future: allKabaddiMatches,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: loadingWidget());
              }

              if (snapshot.hasError) {
                print("Error: ${snapshot.error}");
                return Center(
                    child: Text(
                        'Error in loading Kabaddi Matches, Try after some time'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                print("No Kabaddi Matches Available");
                return Center(child: Text('No Kabaddi Matches Available'));
              }

              List<InterCollegeKabaddiMatch> matches = snapshot.data!;

              return Expanded(
                child: ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    InterCollegeKabaddiMatch match = matches[index];

                

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFA8F7E3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: isExtended
                            ? 320
                            : 250,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Match Info Row (Match Type, Date, Time, Stadium)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      match.matchType,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      match.matchDayDate,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 16, color: Colors.black),
                                        SizedBox(width: 10),
                                        Text(match.matchTime,
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.stadium,
                                            size: 16,
                                            color:
                                                Colors.black.withOpacity(0.8)),
                                        SizedBox(width: 10),
                                        Text(match.matchLocation,
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius:
                                          MediaQuery.of(context).size.width /
                                              15,
                                      child: Icon(Icons.sports_kabaddi),
                                    ),
                                    SizedBox(height: 8),
                                    Text(match.teamAName,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          match.teamAPoints.toString(),
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          color: Color(0xFF02DB70),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                        child: Text(
                                          'VS',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                        match.teamBPoints.toString(),
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CircleAvatar(
                                      radius:
                                          MediaQuery.of(context).size.width /
                                              15,
                                      child: Icon(Icons.sports_kabaddi),
                                    ),
                                    SizedBox(height: 8),
                                    Text(match.teamBName,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: Text(match.result,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isExtended = !isExtended;
                                    });
                                  },
                                  child: Icon(
                                    isExtended
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            if (isExtended)
                              Column(
                                children: [
                                  Text("Top Performances",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17)),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(match.teamATopRaider!,
                                              style: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FontWeight.normal)),
                                          SizedBox(height: 4),
                                                Text(
                                              match
                                                  .teamATopDefender.toString(),
                                              style: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FontWeight.normal)),
                            
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(match.teamBTopRaider.toString(),
                                              style: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FontWeight.normal)),
                                          SizedBox(height: 4),
                                          Text(match.teamBTopDefender
                                          .toString(),
                                              style: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FontWeight.normal)),
                                         
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
