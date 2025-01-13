import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';

class MatchesDetailsPage extends StatefulWidget {
  const MatchesDetailsPage({
    super.key,
    required this.match,
    required this.eventId,
  });

  final Map<String, dynamic> match;
  final String eventId;

  @override
  State<MatchesDetailsPage> createState() => _MatchesDetailsPageState();
}

class _MatchesDetailsPageState extends State<MatchesDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> team1Users = [];
  List<Map<String, dynamic>> team2Users = [];

  Future<void> fetchTeamDetails() async {
    List<String> team1IDs = List<String>.from(widget.match['team1'] ?? []);
    List<String> team2IDs = List<String>.from(widget.match['team2'] ?? []);

    print('RCB $team1IDs');

    QuerySnapshot team1Snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: team1IDs)
        .get();

    QuerySnapshot team2Snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: team2IDs)
        .get();

    List<Map<String, dynamic>> team1Data = team1Snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {'firstName': data['first_name'], 'lastName': data['last_name']};
    }).toList();

    print(team1Data);

    List<Map<String, dynamic>> team2Data = team2Snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {'firstName': data['first_name'], 'lastName': data['last_name']};
    }).toList();

    setState(() {
      team1Users = team1Data;
      team2Users = team2Data;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    print(widget.match);
    fetchTeamDetails();
    print(team1Users);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text('Match Details'),
              floating: true,
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
              bottom: TabBar(
                controller: _tabController,
                labelColor: secondaryColor,
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                indicatorColor: Colors.transparent,
                tabs: [
                  Tab(text: 'Team 01'),
                  Tab(text: 'Team 02'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            team1Users.isEmpty
                ? Center(
                    child: Text(
                      'No Users Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: team1Users.length,
                    itemBuilder: (context, index) {
                      final users = team1Users[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor: secondaryColor,
                          title: Text(
                            '${users['firstName']} ${users['lastName']}',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
            team2Users.isEmpty
                ? Center(
                    child: Text(
                      'No Users Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: team2Users.length,
                    itemBuilder: (context, index) {
                      final users = team2Users[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor: secondaryColor,
                          title: Text(
                              '${users['firstName']} ${users['lastName']}'),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
