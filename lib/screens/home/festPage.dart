import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/constants/keys.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/screens/admin/editEvent.dart';
import 'package:pratishtha/screens/home/addTeamsToFest.dart';
import 'package:pratishtha/screens/home/olympusLeaderboardPage.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/dateTimeServices.dart';
import 'package:pratishtha/services/eventServices.dart';
import 'package:pratishtha/widgets/comingSoonWidget.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/eventCard.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';

class FestPage extends StatefulWidget {
  Event event;
  // List<Event> childEvents;

  FestPage({super.key, required this.event});

  @override
  _FestPageState createState() => _FestPageState();
}

class _FestPageState extends State<FestPage> {
  late Map featureMap;
  DatabaseServices databaseServices = DatabaseServices();
  late User currentUser;
  late bool goLive;
  bool softDelete = false;
  List childEvents = [];

  bool enableMatchManage() {
    if ([5, 3, 7].contains(currentUser.role)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    goLive = widget.event.goLive;
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: () async {
            widget.event = await databaseServices.getFest(widget.event.id!);
            setState(() {});
            return Future.delayed(Duration(seconds: 1));
          },
          child: FutureBuilder(
              future: Future.wait([
                getFeatureListValuesFromPrefs(),
                getUserFromPrefs(),
                databaseServices.getSpecificEvents(this.widget.event.childId!),
              ]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  featureMap = snapshot.data![0] as Map<dynamic, dynamic>;
                  currentUser = snapshot.data![1] as User;
                  childEvents =
                      (snapshot.data![2] as List<dynamic>).cast<Event>();
        
                  childEvents.removeWhere((event) => event.softDelete);
        
                  return Scaffold(
                    floatingActionButton: enableMatchManage()
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              (this.widget.event.id == Olympus2024ID ||
                                      this.widget.event.id == Aurum2024ID ||
                                      this.widget.event.id == Verve2024ID)
                                  ? Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: FloatingActionButton(
                                            heroTag: 'button1',
                                            child: Text('Add Teams',
                                                textAlign: TextAlign.center),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          AddTeamToFest(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(
                                width: 10,
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: FloatingActionButton(
                                  heroTag: 'button2',
                                  child: Icon(Icons.app_registration),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            EditEvent(event: widget.event),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
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
                                    fit: BoxFit.fill,
                                    child: Image(
                                      image: NetworkImage(
                                          this.widget.event.bannerUrl),
                                      // image: NetworkImage(this.widget.event.bannerUrl),
                                    ),
                                  ),
                                ),
                          floating: true,
                          backgroundColor: primaryColor,
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
                            margin: MediaQuery.of(context).padding,
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Center(
                                        child: Text(
                                          this.widget.event.name!.isEmpty
                                              ? "Coming Soon"
                                              : this.widget.event.name!,
                                          style: TextStyle(
                                            fontSize: 28,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      [5, 3].contains(currentUser.role)
                                          ? IconButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    elevation: 10,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                        top: Radius.circular(10),
                                                      ),
                                                    ),
                                                    builder: (context) {
                                                      return StatefulBuilder(
                                                          builder: (context,
                                                              setState) {
                                                        return Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              3,
                                                          padding:
                                                              EdgeInsets.all(20),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    "Go Live",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                  Spacer(),
                                                                  Switch(
                                                                      value:
                                                                          goLive,
                                                                      onChanged:
                                                                          (val) {
                                                                        setState(
                                                                            () {
                                                                          goLive =
                                                                              val;
                                                                        });
                                                                      }),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    "Delete",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                  Spacer(),
                                                                  Switch(
                                                                      value:
                                                                          softDelete,
                                                                      onChanged:
                                                                          (val) {
                                                                        setState(
                                                                            () {
                                                                          softDelete =
                                                                              val;
                                                                        });
                                                                      }),
                                                                ],
                                                              ),
                                                              ElevatedButton(
                                                                  onPressed: () {
                                                                    if (this.widget.event.goLive !=
                                                                            goLive ||
                                                                        this.widget.event.softDelete !=
                                                                            softDelete) {
                                                                      if (softDelete) {
                                                                        showDialog<
                                                                            bool>(
                                                                          context:
                                                                              context,
                                                                          barrierDismissible:
                                                                              false, // user must tap button!
                                                                          builder:
                                                                              (BuildContext
                                                                                  context) {
                                                                            return AlertDialog(
                                                                              title:
                                                                                  const Text('Warning'),
                                                                              content:
                                                                                  SingleChildScrollView(
                                                                                child: ListBody(
                                                                                  children: const <Widget>[
                                                                                    Text('Are you sure you want to delete this event?'),
                                                                                    Text('You will not be able to reverse this change'),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              actions: <Widget>[
                                                                                TextButton(
                                                                                  child: const Text('Yes'),
                                                                                  onPressed: () {
                                                                                    databaseServices.updateSoftDeleteAndGoLiveStatusForFests(
                                                                                      goLive: goLive,
                                                                                      softDelete: softDelete,
                                                                                      event: this.widget.event,
                                                                                    );
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
                                                                      } else {
                                                                        databaseServices.updateSoftDeleteAndGoLiveStatusForFests(
                                                                            goLive:
                                                                                goLive,
                                                                            softDelete:
                                                                                softDelete,
                                                                            event: this
                                                                                .widget
                                                                                .event);
                                                                      }
                                                                    }
                                                                  },
                                                                  child: Text(
                                                                      "Save"))
                                                            ],
                                                          ),
                                                        );
                                                      });
                                                    });
                                              },
                                              icon: Icon(Icons.menu,
                                                  color: primaryColor),
                                            )
                                          : Container(),
                                      this.widget.event.id == Olympus2024ID
                                          // 'RrmhEXrMQR5HyI4mdddc'
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(100),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        olympusLeaderboardPage(),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                'Leaderboard',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  // this
                                  //             .widget
                                  //             .event
                                  //             .dateTo!
                                  //             .isBefore(DateTime.now()) &&
                                  //         !this
                                  //             .widget
                                  //             .event
                                  //             .dateFrom!
                                  //             .isAtSameMomentAs(
                                  //                 DateTime(1975, 12, 11))
                                  //     ? Center(
                                  //         child: Column(
                                  //           crossAxisAlignment:
                                  //               CrossAxisAlignment.center,
                                  //           children: [
                                  //             Text(
                                  //               "This fest is now over",
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
                                  //     : Container(),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      ((() {
                                        if (this
                                            .widget
                                            .event
                                            .description
                                            .isEmpty) {
                                          return "Coming Soon";
                                        }
                                        return this
                                            .widget
                                            .event
                                            .description
                                            .replaceAll("\\n", "\n");
                                      })()),
                                      style: TextStyle(
                                          color: dullGreyColor, fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  displayTimeLocation(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  this.widget.event.rules!.isEmpty
                                      ? Container()
                                      : Text(
                                          'Rules',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                          ),
                                        ),
                                  this.widget.event.rules!.isEmpty
                                      ? Container()
                                      : SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: this.widget.event.rules!.isEmpty
                                              ? Text(
                                                  "Coming Soon",
                                                  overflow: TextOverflow.clip,
                                                )
                                              : Container(
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemCount: this
                                                          .widget
                                                          .event
                                                          .rules!
                                                          .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Container(
                                                          margin: EdgeInsets.only(
                                                              left: 5,
                                                              bottom: 5,
                                                              right: 5),
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  '${index + 1}.'),
                                                              SizedBox(width: 5),
                                                              Flexible(
                                                                child: Text(
                                                                  this
                                                                          .widget
                                                                          .event
                                                                          .rules![
                                                                      index],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                ),
                                        ),
                                  this.widget.event.rules!.isEmpty
                                      ? Container()
                                      : SizedBox(
                                          height: 20,
                                        ),
                                  this.widget.event.eventHeads!.isEmpty
                                      ? Container()
                                      : Column(
                                          children: [
                                            SizedBox(
                                              height: 30.0,
                                            ),
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
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Container(
                                                child: ((() {
                                                  if (this
                                                      .widget
                                                      .event
                                                      .eventHeads!
                                                      .isEmpty) {
                                                    return Text("Coming Soon");
                                                  }
                                                  return FutureBuilder(
                                                      future: databaseServices
                                                          .getSpecificUsers(this
                                                              .widget
                                                              .event
                                                              .eventHeads!),
                                                      builder:
                                                          (BuildContext context,
                                                              AsyncSnapshot<
                                                                      List<User>>
                                                                  snapshot) {
                                                        if (snapshot.hasData) {
                                                          return Container(
                                                            width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            child: Column(
                                                              children:
                                                                  getListOfUserCards(
                                                                      snapshot
                                                                          .data!),
                                                            ),
                                                          );
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Center(
                                                              child:
                                                                  CustomErrorWidget());
                                                        } else {
                                                          return Center(
                                                              child:
                                                                  loadingWidget());
                                                        }
                                                      });
                                                })()),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15.0,
                                            ),
                                          ],
                                        ),
                                  this.widget.event.volunteers!.isEmpty
                                      ? Container()
                                      : Column(
                                          children: [
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
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Container(
                                                child: ((() {
                                                  if (this
                                                      .widget
                                                      .event
                                                      .eventHeads!
                                                      .isEmpty) {
                                                    return Text("Coming Soon");
                                                  }
                                                  return FutureBuilder(
                                                      future: databaseServices
                                                          .getSpecificUsers(this
                                                              .widget
                                                              .event
                                                              .volunteers!),
                                                      builder:
                                                          (BuildContext context,
                                                              AsyncSnapshot<
                                                                      List<User>>
                                                                  snapshot) {
                                                        if (snapshot.hasData) {
                                                          return Container(
                                                            width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            child: Column(
                                                              children:
                                                                  getListOfUserCards(
                                                                      snapshot
                                                                          .data!),
                                                            ),
                                                          );
                                                        } else if (snapshot
                                                            .hasError) {
                                                          debugPrint(
                                                              "volunteer snapshot error: ${snapshot.error}");
                                                          return Center(
                                                              child:
                                                                  CustomErrorWidget());
                                                        } else {
                                                          return Center(
                                                              child:
                                                                  loadingWidget());
                                                        }
                                                      });
                                                })()),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15.0,
                                            ),
                                          ],
                                        ),
                                  childEvents.isEmpty
                                      ? Container()
                                      : Container(
                                          //height: (MediaQuery.of(context).size.height / 4)*childEvents.length,
                                          child: GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      childAspectRatio: 0.9),
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: childEvents.length,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  child: ChildEventCard(
                                                      context: context,
                                                      event: childEvents[index],
                                                      isVerified:
                                                          currentUser.isVerified),
                                                );
                                              }),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  //print("fest page snapshot error: ${snapshot.error}");
                  return CustomErrorWidget();
                } else {
                  return Center(child: loadingWidget());
                }
              }),
        ),
      ),
    );
  }

  displayTimeLocation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 7),
          height: 40,
          width: MediaQuery.of(context).size.width / 1.2,
          decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: kElevationToShadow[1]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.calendar,
                size: 20,
                color: whiteColor,
              ),
              SizedBox(
                width: 5.0,
              ),
              AutoSizeText(
                (((() {
                  if (this
                          .widget
                          .event
                          .dateFrom!
                          .toLocal()
                          .toString()
                          .isEmpty ||
                      (this
                          .widget
                          .event
                          .dateFrom!
                          .isAtSameMomentAs(DateTime(1975, 12, 11)))) {
                    return "Coming Soon";
                  } else if (daysBetween(this.widget.event.dateFrom as DateTime,
                          this.widget.event.dateTo as DateTime) ==
                      0) {
                    return getFullFormattedDate(
                        this.widget.event.dateFrom as DateTime);
                  }
                  return getFullFormattedDateRange(
                      dateFrom: this.widget.event.dateFrom,
                      dateTo: this.widget.event.dateTo);
                })())),
                overflow: TextOverflow.clip,
                style: TextStyle(fontSize: 14, color: whiteColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
