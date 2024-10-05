import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/sponsorshipsModel.dart';
import 'package:pratishtha/screens/admin/addEvent.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/widgets/comingSoonWidget.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/festButton.dart';
import 'package:pratishtha/widgets/eventCard.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/noContentWidget.dart';
import 'package:pratishtha/widgets/sponsorCard.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/models/eventModel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentSponsorCardIndex = 0;
  final CarouselController _sponsorCardController = CarouselController();
  DatabaseServices databaseServices = DatabaseServices();

  User? currentUser;
  bool showEvent(Event event) {
    if (currentUser!.role == 5 || currentUser!.role == 3) {
      return true;
    } else {
      if (event.forSakec) {
        if (event.forFaculty) {
          if (currentUser!.isFaculty!) {
            return true;
          } else {
            return false;
          }
        } else {
          if (currentUser!.institute == "SAKEC") {
            return true;
          } else {
            return false;
          }
        }
      } else {
        return true;
      }
    }
  }

  // bool showEvent(Event event) {
  //   return true;
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("tempEventsList length: ${tempEventsList.length}");
    //return isInternet() != true ? NoConnectionScreen() :
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        return Future.delayed(
          Duration(seconds: 1),
        );
      },
      child: Scaffold(
        body: SingleChildScrollView(
          // scrollDirection: Axis.vertical,

          child: Center(
            child: Container(
              padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
              margin: MediaQuery.of(context).padding,
              child: Column(
                children: [
                  //        Text(
                  //          'SPONSORS',
                  //          style: GoogleFonts.sacramento(fontWeight: FontWeight.bold),
                  //        ),
                  FutureBuilder(
                    future: Future.wait([
                      databaseServices.getEvents(),
                      databaseServices.getFests(),
                      databaseServices.getCurrentUser()
                    ]),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        currentUser = snapshot.data[2];

                        List<Event> events = [];
                        if (currentUser!.role == 5 || currentUser!.role == 3) {
                          events = [...snapshot.data[0], ...snapshot.data[1]];
                        } else {
                          events = [
                            ...snapshot.data[0]
                                .where((Event event) => event.goLive),
                            ...snapshot.data[1]
                                .where((Event event) => event.goLive)
                          ];
                        }
                        List<Event> individualEventsList = [];
                        List<Event> festsList = [];
                        List<String> extraEventsToRemove = [];
                        List<Event> extraEvents = [];

                        events.forEach((event) {
                          if (event.parentId == "") {
                            festsList.add(event);
                            if (event.isEvent) {
                              extraEventsToRemove.add(event.childId![0]);
                            }
                          } else {
                            individualEventsList.add(event);
                          }
                        });

                        individualEventsList.removeWhere((Event event) {
                          if (extraEventsToRemove.contains(event.id)) {
                            extraEvents.add(event);
                            return true;
                          } else {
                            return false;
                          }
                        });

                        festsList
                            .sort((a, b) => a.dateFrom!.compareTo(b.dateFrom!));
                        individualEventsList
                            .sort((a, b) => a.dateFrom!.compareTo(b.dateFrom!));
                        individualEventsList =
                            individualEventsList.reversed.toList();
                        // return CustomErrorWidget();
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                                future: databaseServices.getSponsors(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Sponsorship>> snapshot) {
                                  if (snapshot.hasData) {
                                    List<SponsorCard> sponsorCardsList = [];
                                    List<Sponsorship> data = snapshot.data!
                                        .where((element) =>
                                            element.imgUrl.isNotEmpty)
                                        .toList();
                                    snapshot.data!.forEach((sponsor) {
                                      if (sponsor.imgUrl.isNotEmpty) {
                                        // print("hello " + sponsor.imgUrl);
                                        sponsorCardsList.add(SponsorCard(
                                            context: context,
                                            sponsorship: sponsor));
                                      }
                                    });
                                    return snapshot.data!.isEmpty
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                bottom: 10),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4,
                                            decoration: BoxDecoration(
                                                //    border: Border.all(color: Colors.black, width: 4),
                                                color: blackColor,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: ComingSoonWidget(
                                                waveColor: primaryColor,
                                                boxBackgroundColor: blackColor,
                                                textStyle: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 60,
                                                    color: secondaryColor,
                                                    fontFamily:
                                                        'Times New Roman')),
                                          )
                                        : Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3,
                                            child: sponsorCardsList.length > 1
                                                ? CarouselSlider(
                                                    items: sponsorCardsList,
                                                    carouselController:
                                                        _sponsorCardController,
                                                    options: CarouselOptions(
                                                        autoPlay: true,
                                                        enlargeCenterPage: true,
                                                        aspectRatio: 16 / 9,
                                                        onPageChanged:
                                                            (index, reason) {
                                                          setState(() {
                                                            _currentSponsorCardIndex =
                                                                index;
                                                          });
                                                        }),
                                                  )
                                                : ListView.builder(

                                                    //shrinkWrap: true,
                                                    physics:
                                                        AlwaysScrollableScrollPhysics(
                                                            parent:
                                                                BouncingScrollPhysics()),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: data.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Container(
                                                          //width: MediaQuery.of(context).size.width,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: SponsorCard(
                                                            context: context,
                                                            sponsorship:
                                                                data[index],
                                                          ));
                                                    }));
                                  } else if (snapshot.hasError) {
                                    //print("sponsorships error : ${snapshot.error}");
                                    return CustomErrorWidget();
                                  } else {
                                    return loadingWidget();
                                  }
                                }),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Container(
                              height: 100,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  itemCount: festsList.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          FestButton(
                                            event: festsList[index],
                                            individualEventsList: extraEvents,
                                            context: context,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              child: Text(
                                'Upcoming Events',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            individualEventsList.length == 0
                                ? Center(
                                    child: noContentWidget(
                                        message: "Coming Soon!"),
                                  )
                                : Container(
                                    //height: MediaQuery.of(context).size.height/2.5,
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: individualEventsList.length,
                                        itemBuilder: (context, index) {
                                          return !showEvent(
                                                  individualEventsList[index])
                                              ? SizedBox()
                                              : Container(
                                                  child: Column(
                                                    children: [
                                                      EventCard(
                                                        context: context,
                                                        event:
                                                            individualEventsList[
                                                                index],
                                                        isVerified: currentUser!
                                                            .isVerified,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                        }),
                                  ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        //print("homepage snapshot error: ${snapshot.error}");
                        return CustomErrorWidget();
                        // return Center(
                        //   child: Text("Oops, something seems to have gone wrong, please try again"),);
                      }
                      return Center(child: loadingWidget());
                    },
                  ),
                ],
              ),
            ),
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
            "Please verify your email to enable all features",
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
}


// YUVA  fire
// Olympus robot
// Nucleus water drop
// Verve  guitar