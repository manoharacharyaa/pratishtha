import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/utils/fonts.dart';

class MatchesDetailsPage extends StatefulWidget {
  const MatchesDetailsPage({
    super.key,
    required this.match,
    required this.eventId,
    this.team1Name,
    this.team2Name,
  });

  final Map<String, dynamic> match;
  final String eventId;
  final String? team1Name;
  final String? team2Name;

  @override
  State<MatchesDetailsPage> createState() => _MatchesDetailsPageState();
}

class _MatchesDetailsPageState extends State<MatchesDetailsPage>
    with SingleTickerProviderStateMixin {
  List<String> team1Users = [];
  List<String> team2Users = [];
  ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  Future<void> fetchTeamDetails() async {
    List<String> team1IDs = List<String>.from(widget.match['team1'] ?? []);
    List<String> team2IDs = List<String>.from(widget.match['team2'] ?? []);

    QuerySnapshot team1Snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: team1IDs)
        .get();

    QuerySnapshot team2Snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: team2IDs)
        .get();

    List<String> team1Data = team1Snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['first_name'] as String;
    }).toList();

    List<String> team2Data = team2Snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['first_name'] as String;
    }).toList();

    setState(() {
      team1Users = team1Data;
      team2Users = team2Data;
    });
  }

  @override
  void initState() {
    fetchTeamDetails();
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.hasClients &&
            _scrollController.offset > (200 - kToolbarHeight);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchTeamDetails,
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: Text(
                  'Match Details',
                  style: AppFonts.poppins(
                    color: _isScrolled ? Colors.black : Colors.white,
                  ),
                ),
                iconTheme: IconThemeData(
                  color: _isScrolled ? Colors.black : Colors.white,
                ),
                floating: true,
                pinned: true,
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      child: Image.asset(
                                        'assets/images/codesandbx_transparent.png',
                                      ),
                                    ),
                                    Text(
                                      widget.match['score01'],
                                      style: TextStyle(
                                        fontSize: 38,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'VS',
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      widget.match['score02'],
                                      style: TextStyle(
                                        fontSize: 38,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      height: 100,
                                      width: 100,
                                      child: Image.asset(
                                        'assets/images/globe_transparent.png',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayersList(
                  heding: widget.team1Name,
                  firstNameList: team1Users,
                ),
                Center(
                  child: VerticalDivider(
                    color: Colors.black,
                  ),
                ),
                PlayersList(
                  heding: widget.team2Name,
                  firstNameList: team2Users,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlayersList extends StatelessWidget {
  const PlayersList({
    super.key,
    this.heding,
    required this.firstNameList,
  });

  final String? heding;

  final List<String> firstNameList;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        Container(
          height: 45,
          width: size.width * 0.45,
          margin: EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              heding ?? '',
              style: AppFonts.poppins(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: SizedBox(
            width: size.width * 0.45,
            child: firstNameList.isEmpty
                ? Center(
                    child: Text(
                      'No users found',
                      style: AppFonts.poppins(
                        size: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: firstNameList.length,
                    itemBuilder: (context, index) {
                      final name = firstNameList[index];
                      return Container(
                        height: 45,
                        width: size.width * 0.45,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            name,
                            style: AppFonts.poppins(
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
