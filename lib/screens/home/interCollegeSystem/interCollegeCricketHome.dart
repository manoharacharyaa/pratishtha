import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:pratishtha/models/cricketInterCollege.dart';
import 'package:pratishtha/services/interCollegeServices.dart';

class InterCollegeCricketHome extends StatefulWidget {
  final String currentAcademicYear;
  const InterCollegeCricketHome({required this.currentAcademicYear, super.key});

  @override
  State<InterCollegeCricketHome> createState() =>
      _InterCollegeCricketHomeState();
}

class _InterCollegeCricketHomeState extends State<InterCollegeCricketHome> {
  late Future<List<InterCollegeCricketMatch>> allCricketMatches;
  bool isExtended = false;

  @override
  void initState() {
    super.initState();
    allCricketMatches = InterCollegeServices()
        .getAllInterCollegeCricketMatches(widget.currentAcademicYear);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Cricket ${widget.currentAcademicYear}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple.shade500,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/cricket_screen.png"),
              fit: BoxFit.cover,
              opacity: 0.9),
        ),
        child: SafeArea(
          child: FutureBuilder<List<InterCollegeCricketMatch>>(
            future: allCricketMatches,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorWidget();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyWidget();
              }

              return _buildMatchList(snapshot.data!);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error loading matches',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                allCricketMatches = InterCollegeServices()
                    .getAllInterCollegeCricketMatches(
                        widget.currentAcademicYear);
              });
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_cricket, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No matches available',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(InterCollegeCricketMatch match) {
    final parts = splitScore(match.teamBattingFirstScore);
    final parts2 = splitScore(match.teamBattingSecondScore);

    return LayoutBuilder(builder: (context, constraints) {
      return IntrinsicHeight(
        child: RepaintBoundary  (
          child: GlassmorphicContainer(
            margin: EdgeInsets.only(bottom: 16),
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            borderRadius: 16,
            blur: 10,
            border: 2,
            linearGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0),
                Colors.white.withOpacity(0),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMatchHeader(match),
                      SizedBox(height: 15),
                      _buildTeamsSection(match, parts, parts2),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                _buildResultSection(match),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 400),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    );
                  },
                  switchInCurve: Curves.linear,
                  switchOutCurve: Curves.linear,
                  child: isExtended
                      ? _buildTopPerformances(match)
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

// Update the ListView builder as well
  Widget _buildMatchList(List<InterCollegeCricketMatch> matches) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return _buildMatchCard(matches[index]);
      },
    );
  }

  Widget _buildMatchHeader(InterCollegeCricketMatch match) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.matchType,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Text(
              match.matchDayDate,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.white70),
                SizedBox(width: 4),
                Text(
                  match.matchTime,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.stadium, size: 16, color: Colors.white70),
                SizedBox(width: 4),
                Text(
                  match.matchLocation,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamsSection(
      InterCollegeCricketMatch match, List<String> parts, List<String> parts2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Team A
        _buildTeamA(
          image: match.teamBattingFirstLogoUrl,
          team: match.teamBattingFirst,
          score: parts[0],
          overs: parts.length > 1 ? parts[1] : '',
        ),

        // VS Container
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // color: Color.fromARGB(255, 35, 104, 253),
              color: Colors.deepPurple.shade500,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'VS',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),

        // Team B
        _buildTeamB(
          image: match.teamBattingSecondLogoUrl,
          team: match.teamBattingSecond,
          score: parts2[0],
          overs: parts2.length > 1 ? parts2[1] : '',
        ),
      ],
    );
  }

  Widget _buildTeamA({
    required String team,
    required String score,
    required String overs,
    required String image,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Team Info (Left)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: 80,
              child: Text(
                team,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Score Info (Right)
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              score,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            if (overs.isNotEmpty)
              Text(
                overs,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamB({
    required String team,
    required String score,
    required String overs,
    required String image,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Score Info (Left)
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              score,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            if (overs.isNotEmpty)
              Text(
                overs,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
          ],
        ),

        // Team Info (Right)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: ClipOval(
                  child:
                      CachedNetworkImage(imageUrl: image, fit: BoxFit.cover)),
            ),
            SizedBox(height: 8),
            Container(
              width: 80,
              child: Text(
                team,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultSection(InterCollegeCricketMatch match) {
    return GestureDetector(
      onTap: () => setState(() {
        isExtended = !isExtended;
      }),
      child: Container(
        padding: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
        ),
        child: Column(
          children: [
            Text(
              match.result,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                !isExtended
                    ? Icon(
                        Icons.expand_more,
                        color: Colors.white70,
                        size: 25,
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformances(InterCollegeCricketMatch match) {
    return GestureDetector(
      onTap: () => setState(() {
        isExtended = !isExtended;
      }),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                GestureDetector(
                  onTap: () => setState(() {
                    isExtended =!isExtended;
                  }),
      
                  child: Text(
                    "Top Performances",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isExtended
                        ? Icon(
                            Icons.expand_less,
                            color: Colors.white70,
                            size: 25,
                          )
                        : Container(),
                  ],
                )
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.teamBattingFirstTopBatter,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      match.teamBattingFirstTopBowlerPerformance,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      match.teamBattingSecondTopBatter,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      match.teamBattingSecondTopBowlerPerformance,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
