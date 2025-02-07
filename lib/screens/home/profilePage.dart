import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pratishtha/constants/avatars.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart' as user;
import 'package:pratishtha/screens/home/editProfile.dart';
import 'package:pratishtha/screens/home/eventPage.dart';
import 'package:pratishtha/screens/home/event_matches_page.dart';
import 'package:pratishtha/screens/home/pointsPage.dart';
import 'package:pratishtha/screens/home/walletPage.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart';
import 'package:pratishtha/utils/fonts.dart';
import 'package:pratishtha/widgets/avatarPicker.dart';
import 'package:pratishtha/widgets/balanceCard.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:provider/provider.dart';
import 'package:pratishtha/widgets/pointsCard.dart';
import 'package:pratishtha/widgets/achievementsWidget.dart';
import 'package:pratishtha/widgets/eventCard.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  user.User? selectedUser;
  Event? event;
  ProfilePage({super.key, this.selectedUser});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DatabaseServices databaseServices = DatabaseServices();
  bool isLoading = false;

  Map? featureMap;
  user.User? currentUser;
  List<Event> eventHeadList = [];
  List<Event> volunteerList = [];
  List<Event> registeredEvents = [];

  Future<List<Event>> getAssignedEvents(String eventRoles) async {
    List<String> eventRolesList = eventRoles.split(', ');
    List<String> eventIds = [];
    int i = 0;

    //print('checkpoint 1, inside 1st for');
    for (String eventRole in eventRolesList) {
      List<String> currentEvent = eventRole.split('-');
      eventIds.add(currentEvent[0]);
      //print(i.toString() + " : " + currentEvent[0]);
      i++;
    }

    //print('-' * 80);
    //print(eventIds);
    return await databaseServices.getSpecificEvents(eventIds);
  }

  Future<List<Event>> getEvents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('created_by', isEqualTo: currentUser!.uid)
        .get();
    List<Event> currentUserEvents = snapshot.docs.map((doc) {
      return Event.fromMap(doc as Map<String, dynamic>, '');
    }).toList();

    return currentUserEvents;
  }

  List<Event> eventByCouncilMember = [];

  Future<List<Event>> getEventCreatedByCouncilMember() async {
    final currentuuid = FirebaseAuth.instance.currentUser!.uid;
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('created_by', isEqualTo: currentuuid)
        .get();

    eventByCouncilMember = snapshot.docs
        .map((doc) => eventFromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return eventByCouncilMember;
  }

  Future<void> getMyRegisteredEvents() async {
    if (currentUser == null) return;

    try {
      setState(() {
        isLoading = true;
      });

      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('approved_users', arrayContains: currentUser!.uid)
          .get();

      if (mounted) {
        // Add mounted check
        setState(() {
          registeredEvents = eventsSnapshot.docs
              .map((doc) => Event.fromMap(doc.data(), doc.id))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching registered events: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getEventCreatedByCouncilMember();
    getMyRegisteredEvents();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getMyRegisteredEvents,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () {
              setState(() {});
              return Future.delayed(
                Duration(seconds: 1),
              );
            },
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: Future.wait([
                  databaseServices.getCurrentUser(),
                  getFeatureListValuesFromPrefs()
                ]),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasData) {
                    currentUser = snapshot.data![0];
                    featureMap = snapshot.data![1];
                    if (widget.selectedUser!.uid! == currentUser!.uid!) {
                      widget.selectedUser = currentUser;
                    }
                    return Center(
                      child: Container(
                          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          child: Column(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height / 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(avatarMap[
                                    currentUser?.uid ==
                                            this.widget.selectedUser!.uid
                                        ? currentUser!.avatar
                                        : this.widget.selectedUser!.avatar]!),
                                //child: Image.asset('assets/images/Asset 1.png'),
                                // child: Text("P"),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              currentUser!.uid == this.widget.selectedUser!.uid
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          height: 50,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                      primaryColor),
                                              shape: WidgetStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AvatarPicker(
                                                            currentUser:
                                                                currentUser)),
                                              );
                                            },
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text(
                                                'Customize',
                                                style: TextStyle(
                                                  color: Colors
                                                      .white, // Set your desired color here
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        currentUser!.isVerified
                                            ? SizedBox()
                                            : SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    12,
                                              ),
                                        currentUser!.isVerified
                                            ? SizedBox()
                                            : Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4,
                                                height: 50,
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStateProperty.all(
                                                            primaryColor),
                                                    shape:
                                                        WidgetStateProperty.all(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    final firebaseUser =
                                                        context.watch<User>();
                                                    if (firebaseUser
                                                        .emailVerified) {
                                                      currentUser!.isVerified =
                                                          true;
                                                      await databaseServices
                                                          .updateUserVerifiedStatus(
                                                              user:
                                                                  currentUser!);
                                                      setState(() {});
                                                    }
                                                    firebaseUser
                                                        .sendEmailVerification();
                                                  },
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Text(
                                                      'Verify',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(
                                height: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.user,
                                        size: 30,
                                        color: cardBackgroundColor,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        '${this.widget.selectedUser!.firstName! + ' ' + this.widget.selectedUser!.lastName!}',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(width: 5),
                                      this.widget.selectedUser!.isVerified
                                          ? [3, 5, 6].contains(this
                                                  .widget
                                                  .selectedUser!
                                                  .role)
                                              ? Icon(Icons.verified,
                                                  color: primaryColor)
                                              : Container()
                                          : Icon(Icons.warning,
                                              color: secondaryColor)
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  currentUser!.uid !=
                                          this.widget.selectedUser!.uid
                                      ? Container()
                                      : Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.envelopesBulk,
                                              size: 30,
                                              color: cardBackgroundColor,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Text(
                                                  this
                                                              .widget
                                                              .selectedUser
                                                              ?.email !=
                                                          null
                                                      ? this
                                                          .widget
                                                          .selectedUser!
                                                          .email!
                                                      : this
                                                          .widget
                                                          .selectedUser!
                                                          .sakecId,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  currentUser!.uid !=
                                          this.widget.selectedUser!.uid
                                      ? Container()
                                      : SizedBox(
                                          height: 15.0,
                                        ),
                                  currentUser!.uid !=
                                          this.widget.selectedUser!.uid
                                      ? Container()
                                      : Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.phoneFlip,
                                              size: 30,
                                              color: cardBackgroundColor,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              this.widget.selectedUser!.phone!,
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                  currentUser!.uid !=
                                          this.widget.selectedUser!.uid
                                      ? Container()
                                      : SizedBox(
                                          height: 15.0,
                                        ),
                                  this.widget.selectedUser!.institute ==
                                              "SAKEC" &&
                                          this
                                              .widget
                                              .selectedUser!
                                              .branch
                                              .isNotEmpty &&
                                          this
                                              .widget
                                              .selectedUser!
                                              .year
                                              .isNotEmpty
                                      ? Column(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.codeBranch,
                                                  size: 30,
                                                  color: cardBackgroundColor,
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  this
                                                      .widget
                                                      .selectedUser!
                                                      .branch,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 15.0,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons
                                                      .calendarCheck,
                                                  size: 30,
                                                  color: cardBackgroundColor,
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  this
                                                      .widget
                                                      .selectedUser!
                                                      .year,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 15.0,
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.buildingColumns,
                                        size: 30,
                                        color: cardBackgroundColor,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Flexible(
                                        child: Text(
                                          this.widget.selectedUser!.institute!,
                                          style: TextStyle(fontSize: 20),
                                          overflow: TextOverflow.clip,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  widget.selectedUser!.uid == currentUser!.uid
                                      ? Center(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            height: 50,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStateProperty.all(
                                                        primaryColor),
                                                shape: WidgetStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfile(),
                                                  ),
                                                );
                                              },
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: Text(
                                                  'Edit details',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                  this
                                          .widget
                                          .selectedUser!
                                          .achievements!
                                          .isEmpty
                                      ? Container()
                                      : FutureBuilder(
                                          future: databaseServices
                                              .getSpecificEvents(this
                                                  .widget
                                                  .selectedUser!
                                                  .achievements!
                                                  .keys
                                                  .toList()),
                                          builder: (context,
                                              AsyncSnapshot<List<Event>>
                                                  snapshot) {
                                            if (snapshot.hasData) {
                                              //print("printing snapshot data: ${this.widget.selectedUser.achievements.keys.toList()}");
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                    height: 30.0,
                                                  ),
                                                  Text(
                                                    'Achievements',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20.0,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            6,
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                      10.0,
                                                      0.0,
                                                      10.0,
                                                      0.0,
                                                    ),
                                                    margin:
                                                        MediaQuery.of(context)
                                                            .padding,
                                                    child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount: snapshot
                                                            .data!.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return AchievementsWidget(
                                                              context: context,
                                                              event: snapshot
                                                                  .data![index],
                                                              position: this
                                                                      .widget
                                                                      .selectedUser!
                                                                      .achievements![
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .id]);
                                                        }),
                                                  ),
                                                ],
                                              );
                                            } else if (snapshot.hasError) {
                                              //print("achievements error: ${snapshot.error}");
                                              return CustomErrorWidget();
                                            } else {
                                              return loadingWidget();
                                            }
                                          }),
                                  this.widget.selectedUser!.eventRoles!.isEmpty
                                      ? Container()
                                      : buildEventsList(this
                                          .widget
                                          .selectedUser!
                                          .eventRoles!),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              this.widget.selectedUser!.role == 2 ||
                                      this.widget.selectedUser!.role == 3
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 5, 10, 0),
                                          child: Text(
                                            "My Events",
                                            style: AppFonts.poppins(
                                              size: 20,
                                              color: secondaryColor,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 300,
                                          width: double.infinity,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(10)
                                                    .copyWith(
                                                        topLeft: Radius.zero),
                                          ),
                                          child: ListView.builder(
                                            itemCount:
                                                eventByCouncilMember.length,
                                            itemBuilder: (context, index) {
                                              final event =
                                                  eventByCouncilMember[index];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: SizedBox(
                                                  height: 80,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EventMatchesPage(
                                                            event: event,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Card(
                                                      color: secondaryColor,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              child: event.bannerUrl ==
                                                                      ""
                                                                  ? Image.asset(
                                                                      'assets/images/pageNotFound1.png')
                                                                  : Image.network(
                                                                      event
                                                                          .bannerUrl),
                                                            ),
                                                          ),
                                                          Text(
                                                            event.name!,
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              this.widget.selectedUser!.role == 0
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 30),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 5, 10, 0),
                                          child: Text(
                                            "Registered Events",
                                            style: AppFonts.poppins(
                                              size: 20,
                                              color: secondaryColor,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 300,
                                          width: double.infinity,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(10)
                                                    .copyWith(
                                                        topLeft: Radius.zero),
                                          ),
                                          child: registeredEvents.isEmpty
                                              ? IconButton(
                                                  onPressed:
                                                      getMyRegisteredEvents,
                                                  icon: Icon(
                                                    Icons.refresh_rounded,
                                                    size: 70,
                                                    color: secondaryColor,
                                                  ),
                                                )
                                              : ListView.builder(
                                                  itemCount:
                                                      registeredEvents.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final event =
                                                        registeredEvents[index];
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      child: SizedBox(
                                                        height: 80,
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        EventPage(
                                                                  event: event,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Card(
                                                            color:
                                                                secondaryColor,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                    child: event.bannerUrl ==
                                                                            ""
                                                                        ? Image.asset(
                                                                            'assets/images/pageNotFound1.png')
                                                                        : Image
                                                                            .network(
                                                                            event.bannerUrl,
                                                                          ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  event.name!,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              GestureDetector(
                                onTap: () {
                                  if ((currentUser!.uid ==
                                          this.widget.selectedUser!.uid) ||
                                      ([5, 3].contains(currentUser!.role) ||
                                          featureMap!['9']['roles']
                                              .contains(currentUser!.role))) {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        child: PointsPage(
                                          userId: this.widget.selectedUser!.uid,
                                        ),
                                        childCurrent: this.widget,
                                        type: PageTransitionType.leftToRightPop,
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: PointsCard(
                                    pointsValue:
                                        this.widget.selectedUser!.points,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 18.0,
                              ),
                              (currentUser!.uid !=
                                          this.widget.selectedUser!.uid) &&
                                      ([5, 3].contains(currentUser!.role) ||
                                          featureMap!['3']['roles']
                                              .contains(currentUser!.role))
                                  ? GestureDetector(
                                      onTap: () {
                                        if ((currentUser!.uid ==
                                                this
                                                    .widget
                                                    .selectedUser!
                                                    .uid) ||
                                            [5, 4, 3]
                                                .contains(currentUser!.role)) {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                                child: WalletPage(
                                                  userId: this
                                                      .widget
                                                      .selectedUser!
                                                      .uid!,
                                                ),
                                                type: PageTransitionType
                                                    .leftToRightPop),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(
                                            10.0, 15.0, 10.0, 0.0),
                                        margin: MediaQuery.of(context).padding,
                                        child: BalanceCard(
                                          balValue:
                                              this.widget.selectedUser!.wallet,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              (currentUser!.uid !=
                                          this.widget.selectedUser!.uid) &&
                                      ([5, 3].contains(currentUser!.role) ||
                                          featureMap!['3']['roles']
                                              .contains(currentUser!.role))
                                  ? SizedBox(
                                      height: 18.0,
                                    )
                                  : Container(),
                            ],
                          )),
                    );
                  } else if (snapshot.hasError) {
                    debugPrint("profilePage snapshot error: ${snapshot.error}");
                    return CustomErrorWidget();
                  } else {
                    return Center(child: loadingWidget());
                  }
                },
              ),
            ),
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: getMyRegisteredEvents,
        // ),
      ),
    );
  }

  buildEventsList(String eventRoles) {
    return FutureBuilder(
      future: getAssignedEvents(eventRoles),
      builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
        eventHeadList = [];
        volunteerList = [];
        if (snapshot.hasData) {
          for (Event event in snapshot.data!) {
            if (!event.softDelete) {
              if ([5, 3].contains(currentUser!.role)) {
                //print(event.id + " : " + event.name);
                if (event.eventHeads!.contains(this.widget.selectedUser!.uid)) {
                  eventHeadList.add(event);
                } else {
                  volunteerList.add(event);
                }
              } else {
                //print(event.id + " : " + event.name);
                if (event.goLive) {
                  if (event.eventHeads!
                      .contains(this.widget.selectedUser!.uid)) {
                    eventHeadList.add(event);
                  } else {
                    volunteerList.add(event);
                  }
                }
              }
            }
          }

          return Column(
            children: [
              eventHeadList.length < 1
                  ? Container()
                  : buildEventRoleList(eventHeadList, 'Event Head'),
              volunteerList.length < 1
                  ? Container()
                  : buildEventRoleList(volunteerList, 'Volunteer'),
            ],
          );
        } else if (snapshot.hasError) {
          //print("profile page snapshot error: ${snapshot.error}");
          return CustomErrorWidget();
        } else {
          return loadingWidget();
        }
      },
    );
  }

  buildEventRoleList(List<Event> eventList, String title) {
    return Column(
      children: [
        SizedBox(
          height: 30.0,
        ),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height / 5.2,
          //margin: MediaQuery.of(context).padding,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: eventList.length,
            itemBuilder: (context, index) {
              return EventCard(
                  context: context,
                  event: eventList[index],
                  isVerified: this.widget.selectedUser!.isVerified);
            },
          ),
        ),
      ],
    );
  }
}
