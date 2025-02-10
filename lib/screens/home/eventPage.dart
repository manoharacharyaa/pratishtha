// ignore_for_file: must_be_immutable, unused_local_variable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pratishtha/services/databaseServices.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/avatars.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/constants/keys.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/screens/admin/editEvent.dart';
import 'package:pratishtha/screens/home/addMatchFormPage.dart';
import 'package:pratishtha/screens/home/addPointsAurum.dart';
import 'package:pratishtha/screens/home/addTeams.dart';
import 'package:pratishtha/screens/home/eventPointsCard.dart';
import 'package:pratishtha/screens/home/matches_details_page.dart';
import 'package:pratishtha/screens/home/registration_page.dart';
import 'package:pratishtha/services/dateTimeServices.dart';
import 'package:pratishtha/services/eventServices.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/utils/fonts.dart';
import 'package:pratishtha/widgets/comingSoonWidget.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart' as sh;
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/inAppWebView.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/noContentWidget.dart';
import 'package:pratishtha/widgets/userCard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'editMatchPage.dart';

class EventPage extends StatefulWidget {
  Event event;
  EventPage({super.key, required this.event});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> with TickerProviderStateMixin {
  DatabaseServices databaseServices = DatabaseServices();
  late User currentUser;
  late bool goLive;
  bool softDelete = false;
  late bool closeEvent;
  late TabController _tabController;
  GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
  late String registrationUrl = widget.event.registrationUrl;

  List<String> winnerBadgeAssets = [
    'assets/images/gold.png',
    'assets/images/silver.png',
    'assets/images/bronze.png',
  ];

  bool enableRegistration() {
    bool check1 = DateTime.now().isBefore(widget.event.dateTo as DateTime);
    bool check2 = !widget.event.registration!.contains(currentUser.uid);
    bool check3 =
        widget.event.eventHeads!.contains(currentUser.uid) ? false : true;
    bool check4 =
        widget.event.volunteers!.contains(currentUser.uid) ? false : true;
    bool check5 = !widget.event.closeEvent;
    bool check6 = widget.event.type == 2 ? false : true;
    bool check7 = ((widget.event.type == 1) &&
            (widget.event.completed!.contains(currentUser.uid)))
        ? false
        : true;

    if (check1 && check2 && check3 && check4 && check5 && check6 && check7)
      return true;
    else
      return false;
  }

  Future<bool> registerForEvent() async {
    try {
      String result =
          await databaseServices.registerEvent(widget.event.id.toString());
      //print(result);
      return true;
    } catch (e) {
      //print(e);
      return false;
    }
  }

  bool enableEditEvent() {
    if ([5, 3].contains(currentUser.role) ||
        this.widget.event.eventHeads!.contains(currentUser.uid)) {
      return true;
    } else {
      return false;
    }
  }

  bool enableMatchManage() {
    if ([5, 3, 7].contains(currentUser.role)) {
      return true;
    } else {
      return false;
    }
  }
  bool enableAddPoints() {
    if ([5,3].contains(currentUser.role)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool?> showWarning({required BuildContext context}) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to do this?'),
                Text('You will not be able to reverse this action'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    goLive = this.widget.event.goLive;
    closeEvent = this.widget.event.closeEvent;
    _tabController = new TabController(
        vsync: this, length: this.widget.event.type == 2 ? 2 : 4);
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: RefreshIndicator(
        key: _refresh,
        onRefresh: () async {
          widget.event =
              await databaseServices.getEvent(widget.event.id.toString());
          setState(() {});
          return Future.delayed(Duration(seconds: 1));
        },
        child: FutureBuilder(
            future: sh.getUserFromPrefs(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                currentUser = snapshot.data;
                return Scaffold(
                  floatingActionButton: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      enableEditEvent()
                          ? ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          secondaryColor)),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditEvent(
                                            event: this.widget.event)));
                              },
                              label: Text("Edit Event"),
                              icon: Icon(FontAwesomeIcons.penToSquare),
                            )
                          : Container(),

                    if (widget.event.parentId == Olympus2024ID && enableMatchManage())

                          ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          secondaryColor)),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => addMatchFormPage(
                                              eventID: this
                                                  .widget
                                                  .event
                                                  .id
                                                  .toString(),
                                            )));
                              },
                              label: Text("Matches"),
                              icon: Icon(FontAwesomeIcons.plus),
                            ),
                          
                      if (widget.event.parentId == Olympus2024ID && enableMatchManage())

                          ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          secondaryColor)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => addTeamPage(
                                      eventID: this.widget.event.id.toString(),
                                    ),
                                  ),
                                );
                              },
                              label: Text("Teams"),
                              icon: Icon(FontAwesomeIcons.plus),
                            )
                          ,
                        
                      ElevatedButton(
                        onPressed: () async {
                          //URL Redirecting to browser
                          // final url = widget.event.registrationUrl;
                          // if (await canLaunch(url)) {
                          //   await launch(url);
                          // } else {
                          //   throw 'Could not launch $url';
                          // }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (contexr) => RegistrationPage(
                                event: widget.event,
                              ),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          fixedSize: WidgetStateProperty.all(Size.infinite),
                          backgroundColor:
                              WidgetStateProperty.all(secondaryColor),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        expandedHeight: MediaQuery.of(context).size.height / 4,
                        flexibleSpace: this.widget.event.bannerUrl == ""
                            ? ComingSoonWidget(
                                waveColor: secondaryColor,
                                boxBackgroundColor: primaryColor,
                                textStyle: TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: secondaryColor,
                                    fontFamily: 'Agne'))
                            : Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Image(
                                    image: NetworkImage(
                                      this.widget.event.bannerUrl,
                                    ),
                                  ),
                                ),
                              ),
                        floating: true,
                        backgroundColor: primaryColor,
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            TabBar(
                                unselectedLabelColor: dullGreyColor,
                                controller: _tabController,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicator: BubbleTabIndicator(
                                  indicatorHeight: 40.0,
                                  indicatorColor: secondaryColor,
                                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                                ),
                                tabs: this.widget.event.type == 2
                                    ? <Widget>[
                                        Tab(
                                          text: "Details",
                                        ),
                                        Tab(
                                          text: "Coordinators",
                                        ),
                                      ]
                                    : widget.event.parentId == Olympus2024ID
                                        ? <Widget>[
                                            Tab(
                                              text: "Details",
                                            ),
                                            Tab(
                                              text: "Coordinators",
                                            ),
                                            Tab(
                                              text: "Leaderboard",
                                            ),
                                            Tab(
                                              text: "Matches",
                                            )
                                          ]
                                        : widget.event.parentId == Aurum2024ID?[
                                          Tab(
                                            text: "Details",
                                          ),
                                          Tab(
                                            text: "Participants",
                                          ),
                                          Tab(
                                            text: "Leaderboard",
                                          ),
                                        ] :<Widget>[
                                            Tab(
                                              text: "Details",
                                            ),
                                            Tab(
                                              text: "Coordinators",
                                            ),
                                            Tab(
                                              text: "Leaderboard",
                                            ),
                                          ]),
                                          //Aurum work todo
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 1.6,
                              child: TabBarView(
                                controller: _tabController,
                                children: this.widget.event.type == 2
                                    ? [
                                        detailsView(),
                                        coordinatorsView(),
                                      ]
                                    : widget.event.parentId == Olympus2024ID
                                        ? [
                                            detailsView(),
                                            coordinatorsView(),
                                            widget.event.parentId ==
                                                    Olympus2024ID
                                                ? olympusLeaderView()
                                                : leaderboardView(),
                                            matchesboardView()
                                          ]
                                        : widget.event.parentId == Aurum2024ID ? [
                                          detailsView(),
                                          participantsView(),
                                          aurumLeaderboardView(),
                                        ]:[
                                            detailsView(),
                                            coordinatorsView(),
                                            widget.event.parentId ==
                                                    Olympus2024ID
                                                ? olympusLeaderView()
                                                : leaderboardView(),
                                          ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                //print('event page snapshot error: ${snapshot.error}');
                return CustomErrorWidget();
              } else {
                return loadingWidget();
              }
            }),
      ),
    );
  }

  olympusLeaderView() {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('events')
            .doc(this.widget.event.id)
            .collection('teams')
            .where('score')
            .orderBy('score', descending: true)
            // .limit(3)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
          if (snapshots.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }
          if (snapshots.data!.docs.isEmpty) {
            return Scaffold(
              body: Center(
                child: Text(
                  'No Winners Yet',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }
          try {
            if (snapshots.hasData) {
              List<DocumentSnapshot> documents = snapshots.data!.docs;
              return (documents.length == 0)
                  ? Center(
                      child: Text(
                        'No Winners Found',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        ListView.builder(
                          itemCount: documents.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          addAutomaticKeepAlives: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Card(
                                    margin: EdgeInsets.only(
                                        left: 10, right: 20, bottom: 5),
                                    color: whiteColor,
                                    elevation: 0,
                                    // shape: RoundedRectangleBorder(
                                    //   side: new BorderSide(
                                    //     color: blackColor,
                                    //     width: 1.0,
                                    //   ),
                                    //   borderRadius: BorderRadius.circular(
                                    //     8.0,
                                    //   ),
                                    // ),
                                    child: Column(
                                      children: [
                                        // ListTile(
                                        //   title: Text(
                                        //     "Team  ${documents[index]['name']}",
                                        //     style: TextStyle(
                                        //       color: blackColor,
                                        //       fontSize: 16,
                                        //       fontWeight: FontWeight.w600,
                                        //     ),
                                        //   ),
                                        //   leading: CircleAvatar(
                                        //     radius: 25,
                                        //     backgroundColor: Colors.transparent,
                                        //     child: Image.asset(
                                        //       winnerBadgeAssets[index],
                                        //     ),
                                        //   ),
                                        // ),
                                        ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${documents[index]['name']}"
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              // SizedBox(
                                              //   width: 20,
                                              // ),
                                              Text(
                                                "Score : ${documents[index]['score']}",
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                // textAlign: TextAlign.right,
                                              )
                                            ],
                                          ),
                                          // leading: CircleAvatar(
                                          //   radius: 25,
                                          //   backgroundColor: Colors.transparent,
                                          //   child: Image.asset(
                                          //     winnerBadgeAssets[index],
                                          //   ),
                                          // ),
                                          leading: CircleAvatar(
                                            radius: 25,
                                            backgroundColor: primaryColor,

                                            backgroundImage: (index == 0 ||
                                                    index == 1 ||
                                                    index == 2)
                                                ? AssetImage((index == 0)
                                                    ? "assets/gifs/trophy_burst_animation.gif"
                                                    : "assets/gifs/medallion_burst_animation.gif")
                                                : null,

                                            // child: Icon(FontAwesomeIcons.medal),
                                            child: (index == 0 ||
                                                    index == 1 ||
                                                    index == 2)
                                                ? null
                                                : Text(
                                                    "${index + 1}",
                                                    style: TextStyle(
                                                        color: whiteColor),
                                                  ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Divider(),
                      ],
                    );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          } catch (e) {
            return Scaffold(
              body: Center(
                child: Text(
                  'No Winners Yet',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

Future<List<Map<String, dynamic>>> fetchApprovedUsers(eventId) async {
    List<Map<String, dynamic>> approvedUsers = [];

    DocumentSnapshot eventDoc =
        await databaseServices.eventCollection.doc(eventId).get();

    if (eventDoc.exists) {
      List<dynamic> approvedUsersList =
          eventDoc.get('approved_users') ?? [];

      for (var userMap in approvedUsersList) {
        String userId = userMap.keys.first; // Extract userId
        int points = userMap[userId]['points'] ?? 0; // Extract points

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          String username = userDoc.get('first_name'); // Fetch username

          // Add username & points to list
          approvedUsers.add({
            'userId': userId,
            'username': username,
            'points': points,
          });
        }
      }
    }

    return approvedUsers;
  }

aurumLeaderboardView() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: fetchApprovedUsers(this.widget.event.id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('No Users registered yet'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text("No approved users found."));
      }

      // Get the approved users and sort them by points (descending).
      List<Map<String, dynamic>> approvedUsers = snapshot.data!;
      approvedUsers.sort((a, b) => b['points'].compareTo(a['points']));

      // Build the list of leaderboard items.
      List<Widget> leaderboardItems = [];
      for (int i = 0; i < approvedUsers.length; i++) {
        final user = approvedUsers[i];

        // Determine medal color based on rank.
        Color medalColor;
        if (i == 0) {
          medalColor = goldColor;
        } else if (i == 1) {
          medalColor = Colors.grey.shade700;
        } else if (i == 2) {
          medalColor = const Color.fromARGB(255, 156, 83, 57);
        } else {
          medalColor = dullGreyColor;
        }

        leaderboardItems.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                // Medal Icon based on rank.
                Icon(
                  FontAwesomeIcons.medal,
                  size: 40,
                  color: medalColor,
                ),
                SizedBox(width: 10),
                // User information.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['username'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${user['points']} points',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Ranking number.
                Text(
                  '#${i + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 25.0, 10.0, 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: leaderboardItems,
              ),
            ],
          ),
        ),
      );
    },
  );
}

  leaderboardView() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(10.0, 25.0, 5.0, 10.0),
        child: Column(
          children: [
            this.widget.event.winners!.isEmpty
                ? Center(
                    child: noContentWidget(message: "No winners appointed yet"),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Winners and Runners Up',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          child: ((() {
                            if (this.widget.event.winners!.isEmpty) {
                              return Text("Everyone's a winner for this one");
                            }
                            return FutureBuilder(
                                future: databaseServices.getSpecificUsers(
                                    this.widget.event.winners!.keys.toList()),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<User>> snapshot) {
                                  if (snapshot.hasData) {
                                    List<UserCard> winnersList =
                                        getListOfUserCards(snapshot.data!);
                                    List<Widget> displayWinners = [];
                                    winnersList.forEach((winner) {
                                      displayWinners.add(Container(
                                        margin: EdgeInsets.only(left: 5),
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.medal,
                                              size: 40,
                                              color: this.widget.event.winners![
                                                          winner.user!.uid] ==
                                                      "Winner"
                                                  ? goldColor
                                                  : dullGreyColor,
                                            ),
                                            SizedBox(width: 5),
                                            Expanded(child: winner)
                                          ],
                                        ),
                                      ));
                                    });
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: displayWinners,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(child: CustomErrorWidget());
                                  } else {
                                    return Center(child: loadingWidget());
                                  }
                                });
                          })()),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
 participantsView() {
  return SingleChildScrollView(
    child: Container(
      padding: EdgeInsets.fromLTRB(10.0, 25.0, 5.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
             enableAddPoints()
                          ? ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          secondaryColor)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPointsAurum(eventId: this.widget.event.id!),
                                      
                                  ),
                                );
                              },
                              label: Text("Add Points"),
                              icon: Icon(FontAwesomeIcons.plus),
                            ): Container(),
          this.widget.event.approved_users!.isEmpty
              ? Center(
                  child: noContentWidget(
                    message: "No participants registered yet",
                  ),
                )
              : Column(
                  children: [
                    Text(
                      'Participants',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        child: FutureBuilder<List<User>>(
                          future: databaseServices.getApprovedUser(this.widget.event.id),
                          builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: loadingWidget());
                            } else if (snapshot.hasError) {
                              return Center(child: CustomErrorWidget());
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: noContentWidget(message: "No participants registered yet"));
                            } else {
                              // Here, snapshot.data contains the detailed user info (including username)
                              // Create user cards based on the detailed user information.
                              List<UserCard> userCards = getListOfUserCards(snapshot.data!);
                              List<Widget> displayUserCards = userCards.map((userCard) {
                                return Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Row(
                                    children: [
                                      Expanded(child: userCard),
                                      SizedBox(width: 5),
                                      IconButton(
                                        onPressed: () {
                                          // Implement phone call or any other action here
                                        },
                                        icon: Icon(
                                          FontAwesomeIcons.phone,
                                          size: 40,
                                          color: dullGreyColor,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                );
                              }).toList();
                              return Column(
                                children: displayUserCards,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                  ],
                ),
        ],
      ),
    ),
  );
}

  coordinatorsView() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(10.0, 25.0, 5.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            this.widget.event.eventHeads!.isEmpty
                ? Center(
                    child: noContentWidget(
                        message: "No event co-ordinators appointed yet"),
                  )
                : Column(
                    children: [
                      Text(
                        'Event Heads',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                            child: FutureBuilder(
                                future: databaseServices.getSpecificUsers(
                                    this.widget.event.eventHeads!),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<User>> snapshot) {
                                  if (snapshot.hasData) {
                                    List<UserCard> eventHeadsList =
                                        getListOfUserCards(snapshot.data!);
                                    List<Widget> displayEventHeads = [];
                                    eventHeadsList.forEach((eventHead) {
                                      displayEventHeads.add(Container(
                                        margin: EdgeInsets.only(left: 5),
                                        child: Row(
                                          children: [
                                            Expanded(child: eventHead),
                                            SizedBox(width: 5),
                                            IconButton(
                                                onPressed: () {
                                                  launch(
                                                    ('tel: +91${eventHead.user!.phone}'),
                                                  );
                                                },
                                                icon: Icon(
                                                  FontAwesomeIcons.phone,
                                                  size: 40,
                                                  color: dullGreyColor,
                                                )),
                                            SizedBox(width: 10),
                                          ],
                                        ),
                                      ));
                                    });
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: displayEventHeads,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(child: CustomErrorWidget());
                                  } else {
                                    return Center(child: loadingWidget());
                                  }
                                })),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
            this.widget.event.volunteers!.isEmpty
                ? Container()
                : Column(
                    children: [
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'Volunteers',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          child: ((() {
                            if (this.widget.event.volunteers!.isEmpty) {
                              return Text("Coming Soon");
                            }
                            return FutureBuilder(
                                future: databaseServices.getSpecificUsers(
                                    this.widget.event.volunteers!),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<User>> snapshot) {
                                  if (snapshot.hasData) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children:
                                            getListOfUserCards(snapshot.data!),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    debugPrint(
                                        "volunteer snapshot error: ${snapshot.error}");
                                    return Center(child: CustomErrorWidget());
                                  } else {
                                    return Center(child: loadingWidget());
                                  }
                                });
                          })()),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  detailsView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 25.0, 5.0, 10.0),
          // margin: MediaQuery.of(context).padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      this.widget.event.name!.isEmpty
                          ? "Coming Soon"
                          : this.widget.event.name!,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  [5, 3].contains(currentUser.role)
                      ? IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                ),
                                builder: (context) {
                                  return StatefulBuilder(
                                      builder: (context, setState) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height / 3,
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Go Live",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Spacer(),
                                              Switch(
                                                  value: goLive,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      goLive = val;
                                                    });
                                                  }),
                                            ],
                                          ),
                                          !this.widget.event.closeEvent
                                              ? Row(
                                                  children: [
                                                    Text(
                                                      "Close Event",
                                                      style:
                                                          TextStyle(fontSize: 16),
                                                    ),
                                                    Spacer(),
                                                    Switch(
                                                        value: closeEvent,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            closeEvent = val;
                                                          });
                                                        }),
                                                  ],
                                                )
                                              : Container(),
                                          Row(
                                            children: [
                                              Text(
                                                "Delete",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Spacer(),
                                              Switch(
                                                  value: softDelete,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      softDelete = val;
                                                    });
                                                  }),
                                            ],
                                          ),
                                          ElevatedButton(
                                              onPressed: () async {
                                                if (this.widget.event.goLive !=
                                                        goLive ||
                                                    this
                                                            .widget
                                                            .event
                                                            .softDelete !=
                                                        softDelete ||
                                                    this
                                                            .widget
                                                            .event
                                                            .closeEvent !=
                                                        closeEvent) {
                                                  if (softDelete || closeEvent) {
                                                    showDialog<bool>(
                                                      context: context,
                                                      barrierDismissible:
                                                          false, // user must tap button!
                                                      builder:
                                                          (BuildContext context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Warning'),
                                                          content:
                                                              SingleChildScrollView(
                                                            child: ListBody(
                                                              children: const <Widget>[
                                                                Text(
                                                                    'Are you sure you want to delete this event?'),
                                                                Text(
                                                                    'You will not be able to reverse this change'),
                                                              ],
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: const Text(
                                                                  'Yes'),
                                                              onPressed:
                                                                  () async {
                                                                await databaseServices.updateSoftDeleteAndGoLiveStatusForEvents(
                                                                    goLive:
                                                                        goLive,
                                                                    softDelete:
                                                                        softDelete,
                                                                    closeEvent:
                                                                        closeEvent,
                                                                    event: this
                                                                        .widget
                                                                        .event);
        
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'No'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    await databaseServices
                                                        .updateSoftDeleteAndGoLiveStatusForEvents(
                                                            goLive: goLive,
                                                            softDelete:
                                                                softDelete,
                                                            closeEvent:
                                                                closeEvent,
                                                            event: this
                                                                .widget
                                                                .event);
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  }
                                                }
                                              },
                                              child: Text("Save"))
                                        ],
                                      ),
                                    );
                                  });
                                });
                          },
                          icon: Icon(Icons.menu, color: primaryColor))
                      : Container()
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              this.widget.event.closeEvent
                  ? Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "You have not registered yet",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    )
                  : this.widget.event.registration!.contains(currentUser.uid)
                      ? Column(
                          children: [
                            Text(
                              "You have registered for this event!",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            this.widget.event.registrationUrl.isEmpty
                                ? Container()
                                : TextButton(
                                    onPressed: () {
                                      inAppBrowser(widget.event.registrationUrl);
                                    },
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          text: "Please finish your ",
                                          style: TextStyle(color: blackColor),
                                          children: [
                                            TextSpan(
                                                text: "Registration ",
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.bold)),
                                            TextSpan(
                                                text:
                                                    "to participate in this event, if you haven't already done so.")
                                          ]),
                                    )),
                            this.widget.event.registrationUrl.isEmpty
                                ? Container()
                                : SizedBox(
                                    height: 15.0,
                                  ),
                          ],
                        )
                      : this.widget.event.completed!.contains(currentUser.uid)
                          ? Column(
                              children: [
                                Text(
                                  "You have completed this event!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                this.widget.event.feedbackUrl.isEmpty
                                    ? Container()
                                    : TextButton(
                                        onPressed: () {
                                          // call feedback url
                                          inAppBrowser(widget.event.feedbackUrl);
                                        },
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                              text: "Please give us your ",
                                              style: TextStyle(color: blackColor),
                                              children: [
                                                TextSpan(
                                                    text: "Feedback",
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(text: " for this event!")
                                              ]),
                                        )),
                                this.widget.event.feedbackUrl.isEmpty
                                    ? Container()
                                    : SizedBox(
                                        height: 15.0,
                                      ),
                              ],
                            )
                          // : this.widget.event.dateTo!.isBefore(DateTime.now())
                          //     ? Center(
                          //         child: Column(
                          //           crossAxisAlignment: CrossAxisAlignment.center,
                          //           children: [
                          //             Text(
                          //               "This event is now closed",
                          //               textAlign: TextAlign.center,
                          //               style: TextStyle(
                          //                   fontSize: 15,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //             SizedBox(
                          //               height: 15,
                          //             )
                          //           ],
                          //         ),
                          //       )
                              : Container(),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  ((() {
                    if (this.widget.event.description.isEmpty) {
                      return "Coming Soon";
                    }
                    return this.widget.event.description.replaceAll("\\n", "\n");
                  })()),
                  style: TextStyle(color: dullGreyColor, fontSize: 16),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              this.widget.event.type == 2 && this.widget.event.price == 0
                  ? Container()
                  : displayPrice(),
              this.widget.event.type == 2 && this.widget.event.price == 0
                  ? Container()
                  : SizedBox(
                      height: 10,
                    ),
              displayDate(),
              SizedBox(
                height: 15.0,
              ),
              displayTimeLocation(),
              SizedBox(
                height: 20,
              ),
              ((this.widget.event.registration!.length +
                              this.widget.event.completed!.length) >
                          4 &&
                      this.widget.event.type != 2)
                  ? displayRegistrations()
                  : Container(),
              ((this.widget.event.registration!.length +
                              this.widget.event.completed!.length) >
                          4 &&
                      this.widget.event.type != 2)
                  ? SizedBox(
                      height: 30.0,
                    )
                  : Container(),
              // this.widget.event.type == 2 ? Container() : displayPoints(),
              this.widget.event.type == 2
                  ? Container()
                  : SizedBox(
                      height: 30.0,
                    ),
              this.widget.event.type == 2 && this.widget.event.rules!.isEmpty
                  ? Container()
                  : displayRules(),
              // [5, 3].contains(currentUser.role) ||
              //         this.widget.event.eventHeads.contains(currentUser.uid) ||
              //         this.widget.event.volunteers.contains(currentUser.uid)
              //     ? TextButton(
              //         onPressed: () async {
              //           List<List> participantList = await databaseServices
              //               .getParticipants(this.widget.event.id);
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                   builder: (context) => ChangeParticipantStatus(
              //                         eventId: this.widget.event.id,
              //                         participantsList: participantList,
              //                         event: widget.event,
              //                       )));
              //         },
              //         child: Text("View Participants"))
              //     : Container(),
            ],
          ),
        ),
      ),
    );
  }

  showVerificationPopup() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Please verify your email to enable all features. "
            "You can request verification email through the profile Tab. "
            "If Already verified, restart the application",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  displayPoints() {
    return Column(
      children: [
        Text(
          'Points Awarded',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            EventPointsCard(
                forWinner: true,
                title: "Winners",
                points: this.widget.event.winnerPoints,
                context: context),
            EventPointsCard(
                forWinner: false,
                title: "Runner Ups",
                points: this.widget.event.runnerUpPoints,
                context: context),
            EventPointsCard(
                forWinner: false,
                title: "Participation",
                points: this.widget.event.participationPoints,
                context: context)
          ],
        ),
      ],
    );
  }

  displayPrice() {
    return Row(
      children: [
        Icon(
          FontAwesomeIcons.rupeeSign,
          size: 16,
        ),
        SizedBox(
          width: 5.0,
        ),
        Text(
          'Price: ${this.widget.event.price}',
          style: TextStyle(
              //fontSize: 16.0,
              ),
        ),
      ],
    );
  }

  displayDate() {
    return Row(
      children: [
        Icon(
          FontAwesomeIcons.calendar,
          size: 16,
        ),
        SizedBox(
          width: 5.0,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 3.5,
          child: Text(((() {
            if (this.widget.event.dateFrom!.toLocal().toString().isEmpty) {
              return "Coming Soon";
            } else if (daysBetween(this.widget.event.dateFrom as DateTime,
                    this.widget.event.dateTo as DateTime) ==
                0) {
              return getFormattedDate(this.widget.event.dateFrom as DateTime);
            }
            return getFormattedDateRange(
                dateFrom: this.widget.event.dateFrom,
                dateTo: this.widget.event.dateTo);
          })())),
        ),
      ],
    );
  }

  displayTimeLocation() {
    return Row(
      children: [
        SizedBox(
          width: 5,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 7),
          height: 40,
          decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: kElevationToShadow[1]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.clock,
                size: 20,
                color: whiteColor,
              ),
              SizedBox(
                width: 5.0,
              ),
              AutoSizeText(
                ((() {
                  if (this.widget.event.dateFrom.toString().isEmpty) {
                    return "Coming Soon";
                  }
                  // return this.widget.event.startTime.toString();
                  return getFormattedTimeRange(
                      dateFrom: this.widget.event.dateFrom,
                      dateTo: this.widget.event.dateTo);
                })()),
                overflow: TextOverflow.clip,
                style: TextStyle(fontSize: 14, color: whiteColor),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Flexible(
          child: Container(
            height: 40,
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: kElevationToShadow[1]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.mapMarkerAlt,
                  size: 20,
                  color: whiteColor,
                ),
                SizedBox(
                  width: 5.0,
                ),
                this.widget.event.location.isEmpty
                    ? Text(
                        "Coming Soon",
                        style: TextStyle(color: whiteColor),
                      )
                    : this.widget.event.locationType.isEmpty
                        ? Flexible(
                            child: Text(
                              this.widget.event.location,
                              maxLines: 4,
                              style: TextStyle(color: whiteColor),
                            ),
                          )
                        : this.widget.event.locationType == "Online"
                            ? Flexible(
                                child: InkWell(
                                  onTap: this.widget.event.meetLink == ""
                                      ? () {}
                                      : () =>
                                          launch(this.widget.event.meetLink),
                                  child: Text(
                                    this.widget.event.meetLink == ""
                                        ? this.widget.event.location
                                        : "${this.widget.event.location} - Meet Link",
                                    maxLines: 4,
                                    style: TextStyle(
                                        fontWeight:
                                            this.widget.event.meetLink == ""
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                        color: whiteColor),
                                  ),
                                ),
                              )
                            : this.widget.event.locationType == "Offline"
                                ? Flexible(
                                    child: InkWell(
                                      onTap: this.widget.event.meetLink == ""
                                          ? () {}
                                          : () => launch(
                                              this.widget.event.meetLink),
                                      child: Text(
                                        this.widget.event.location,
                                        maxLines: 4,
                                        style: TextStyle(
                                            color: whiteColor, fontSize: 16),
                                      ),
                                    ),
                                  )
                                : Flexible(
                                    child: InkWell(
                                      onTap: this.widget.event.meetLink == ""
                                          ? () {}
                                          : () => launch(
                                              this.widget.event.meetLink),
                                      child: Text(
                                        this.widget.event.meetLink == ""
                                            ? "Offline - ${this.widget.event.location}"
                                            : "Offline - ${this.widget.event.location}\nOnline - Meet Link",
                                        maxLines: 4,
                                        style: TextStyle(
                                            fontWeight:
                                                this.widget.event.meetLink == ""
                                                    ? FontWeight.normal
                                                    : FontWeight.bold,
                                            color: whiteColor,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),
                SizedBox(
                  width: 15.0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  displayRules() {
    return Column(
      children: [
        Text(
          'Rules',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: this.widget.event.rules!.isEmpty
              ? Text(
                  "Coming Soon",
                  overflow: TextOverflow.clip,
                )
              : Container(
                  // height:
                  //     this.widget.event.rules.length * 50 / 1,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: this.widget.event.rules!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(left: 5, bottom: 5, right: 5),
                          padding: EdgeInsets.all(5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${index + 1}.'),
                              SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  this.widget.event.rules![index],
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                ),
        ),
      ],
    );
  }

  displayRegistrations() {
    return Container(
        child: Row(
      children: [
        Container(
          width: 110,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              CircleAvatar(
                backgroundColor: secondaryColor,
                radius: 20,
                child: Container(
                    height: 25,
                    child: SvgPicture.asset(avatarMap[Random().nextInt(8)]!)),
              ),
              Positioned(
                left: 20,
                child: CircleAvatar(
                  backgroundColor: blackColor,
                  radius: 20,
                  child: Container(
                      height: 25,
                      child: SvgPicture.asset(avatarMap[Random().nextInt(8)]!)),
                ),
              ),
              Positioned(
                left: 40,
                child: CircleAvatar(
                  backgroundColor: secondaryColor,
                  radius: 20,
                  child: Container(
                      height: 25,
                      child: SvgPicture.asset(avatarMap[Random().nextInt(8)]!)),
                ),
              ),
              Positioned(
                left: 60,
                child: CircleAvatar(
                  backgroundColor: blackColor,
                  radius: 20,
                  child: Container(
                      height: 25,
                      child: SvgPicture.asset(avatarMap[Random().nextInt(8)]!)),
                ),
              ),
            ],
          ),
        ),
        Text(
            '+${this.widget.event.registration!.length + this.widget.event.completed!.length} Participants')
      ],
    ));
  }

  matchesboardView() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection("events")
          .doc(this.widget.event.id)
          .get(),
      builder: (context, snapshots) {
        if (snapshots.hasError) {
          return const Center(
            child: Text("No data"),
          );
        }
        try {
          if (snapshots.hasData) {
            final docData = snapshots.data;
            final matchesList = docData!["matches"] ?? [];

            return (matchesList.length == 0)
                ? Center(
                    child: Text(
                      'No Matches Found',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: matchesList.length,
                    addAutomaticKeepAlives: true,
                    itemBuilder: (BuildContext context, int index) {
                      final match = matchesList[index];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Material(
                          elevation: 1,
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MatchesDetailsPage(
                                        match: match,
                                        team1Name: matchesList[index]['team01'],
                                        team2Name: matchesList[index]['team02'],
                                        eventId: widget.event.id!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.all(30),
                                  height: 147,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 15.0,
                                        color: Colors.yellow,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 100,
                                            width: 100,
                                            margin: EdgeInsets.only(bottom: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.asset(
                                              'assets/images/codesandbx_transparent.png',
                                            ),
                                          ),
                                          Text(
                                            '${matchesList[index]['team01']}',
                                            style: AppFonts.poppins(
                                                weight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${matchesList[index]['score01']} . ${matchesList[index]['score02']}',
                                        style: TextStyle(
                                          fontSize: 33,
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 100,
                                            width: 100,
                                            margin: EdgeInsets.only(bottom: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.asset(
                                              'assets/images/globe_transparent.png',
                                            ),
                                          ),
                                          Text(
                                            '${matchesList[index]['team02']}',
                                            style: AppFonts.poppins(
                                                weight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              enableMatchManage()
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, bottom: 17),
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      editMatchPage(
                                                    event: this.widget.event,
                                                    matchList:
                                                        matchesList[index],
                                                    index: index,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: Icon(Icons.edit),
                                            label: Text('Edit'),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          ElevatedButton.icon(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all<
                                                      Color>(
                                                Colors.red,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                // Map<String,dynamic> delName;
                                                String delName =
                                                    matchesList[index]
                                                        ['result'];
                                                String deleteId;
                                                int decrementScore;
                                                String deleteScore;
                                                (delName == "No results")
                                                    ? {
                                                        // FirebaseFirestore.instance.collection("events").doc(widget.event.id).update({"teams":})
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "events")
                                                            .doc(
                                                                widget.event.id)
                                                            .update({
                                                          "matches": FieldValue
                                                              .arrayRemove([
                                                            matchesList[index]
                                                          ])
                                                        }).whenComplete(() {
                                                          debugPrint(
                                                              'Field Deleted');
                                                          debugPrint(
                                                              "${delName}");
                                                        })
                                                      }
                                                    : {
                                                        delName =
                                                            delName.substring(
                                                                0,
                                                                delName.length -
                                                                    5),

                                                        (matchesList[index][
                                                                    'team01'] ==
                                                                delName)
                                                            ? deleteId =
                                                                matchesList[
                                                                        index]
                                                                    ['team01ID']
                                                            : deleteId =
                                                                matchesList[
                                                                        index][
                                                                    'team02ID'],

                                                        debugPrint(deleteId),
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "events")
                                                            .doc(
                                                                widget.event.id)
                                                            .update({
                                                          "matches": FieldValue
                                                              .arrayRemove([
                                                            matchesList[index]
                                                          ])
                                                        }).whenComplete(() {
                                                          debugPrint(
                                                              'Field Deleted');
                                                          debugPrint(
                                                              "${delName}");
                                                        }),

                                                        //now decrement the score with id deleteId from event and fest both

                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "events")
                                                            .doc(
                                                                widget.event.id)
                                                            .collection("teams")
                                                            .doc(deleteId)
                                                            .update({
                                                          "score": FieldValue
                                                              .increment(-1),
                                                        }),

                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("fests")
                                                            .doc(prevOlympusID)
                                                            .collection("teams")
                                                            .doc(deleteId)
                                                            .update({
                                                          "score": FieldValue
                                                              .increment(-1),
                                                        })
                                                      };
                                              });
                                            },
                                            icon: Icon(Icons.delete_forever),
                                            label: Text('Delete'),
                                          ),
                                        ],
                                      ))
                                  : Container(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        } catch (e) {
          return Scaffold(
            body: Center(
              child: Text(
                'No Matches Found',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
