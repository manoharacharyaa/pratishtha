import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/screens/home/eventPage.dart';
import 'package:pratishtha/screens/home/festPage.dart';
import 'package:pratishtha/services/dateTimeServices.dart';
import 'package:pratishtha/styles/mainTheme.dart';
import 'package:pratishtha/widgets/comingSoonWidget.dart';
// import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:page_transition/page_transition.dart';

Widget EventCard(
    {BuildContext? context,
    Event? event,
    List<Event> allEventsList = const [],
    bool? isVerified}) {
  int noOfRegistrations = event!.registration!.length + event.completed!.length;
  bool isFest = (event.parentId == "") && !event.isEvent;

  return GestureDetector(
    onTap: () async {
      isVerified!
          ? await showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Verification Alert!"),
                  content: Text(
                    "Please verify your email to enable all features."
                    "If you have already verified yourself, please logout and log back in to the application, if not, you can request verification from the Profile tab",
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
            )
          : null;

      if (isFest) {
        Navigator.push(
            context,
            PageTransition(
                child: FestPage(
                  event: event,
                ),
                type: PageTransitionType.fade));
      } else if (event.isEvent) {
        Event? myChildEvent;
        for (int i = 0; i < allEventsList.length; i++) {
          Event childEvent = allEventsList[i];
          if (childEvent.parentId == event.id) {
            //print("child event exists");
            myChildEvent = childEvent;
            break;
          }
        }
        Navigator.push(
          context,
          PageTransition(
              child: EventPage(
                event: myChildEvent!,
              ),
              type: PageTransitionType.fade),
        );
      } else {
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>EventPage(event: event)));
        Navigator.push(
            context,
            PageTransition(
                child: EventPage(
                  event: event,
                ),
                type: PageTransitionType.fade));
      }
    },
    child: Container(
      decoration: BoxDecoration(
          boxShadow: [containerShadow],
          color: event.goLive ? whiteColor : greyColor,
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      margin: EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            height: MediaQuery.of(context!).size.height / 8,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  color: cardBackgroundColor,
                  padding: event.bannerUrl == ""
                      ? EdgeInsets.all(10)
                      : EdgeInsets.all(0),
                  child: event.bannerUrl == ""
                      ? ComingSoonWidget(
                          waveColor: primaryColor,
                          boxBackgroundColor: cardBackgroundColor,
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 50,
                              color: primaryColor))
                      : FittedBox(
                          fit: BoxFit.cover,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: event.bannerUrl,
                            placeholder: (context, url) => Image.asset(
                              "assets/images/PratishthaLogo.png",
                              fit: BoxFit.fitHeight,
                              height: MediaQuery.of(context).size.height / 8,
                              width: MediaQuery.of(context).size.width / 2.5,
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ComingSoonWidget(
                                    waveColor: primaryColor,
                                    boxBackgroundColor: cardBackgroundColor,
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 50,
                                        color: primaryColor)),
                              ),
                            ),
                            height: MediaQuery.of(context).size.height / 8,
                            width: MediaQuery.of(context).size.width / 2.5,
                          )),
                )),
            width: MediaQuery.of(context).size.width / 2.5,
            // color: Colors.yellow,
          ),
          SizedBox(
            width: 15.0,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 2.0, 2.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: AutoSizeText(
                    event.name!,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  noOfRegistrations < 4
                      ? (event.dateTo!.isBefore(DateTime.now()) ||
                                  event.closeEvent) &&
                              (!event.dateFrom!
                                  .isAtSameMomentAs(DateTime(1975, 12, 11)))
                          ? 'Event Closed'
                          : event.type == 2
                              ? 'Check it Out!'
                              : 'Register now!'
                      : '+$noOfRegistrations participants',
                  style: TextStyle(
                    color: primaryColor,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Icon(Icons.date_range),
                    SizedBox(
                      width: 1.0,
                    ),
                    SizedBox(
                      child: Text(
                        event.dateFrom == null ||
                                (event.dateFrom!
                                    .isAtSameMomentAs(DateTime(1975, 12, 11)))
                            ? "Coming Soon"
                            : getFormattedDate(event.dateFrom!),
                        //softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget ChildEventCard(
    {BuildContext? context,
    Event? event,
    List<Event> allEventsList = const [],
    bool? isVerified}) {
  int noOfRegistrations = event!.registration!.length + event.completed!.length;
  bool isFest = (event.parentId == "") && !event.isEvent;

  return GestureDetector(
    onTap: () async {
      !isVerified!
          ? await showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Verification Alert!"),
                  content: Text(
                    "Please verify your email to enable all features."
                    "If you have already verified yourself, please logout and log back in to the application, if not, you can request verification from the Profile tab",
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
            )
          : null;

      if (isFest) {
        Navigator.push(
            context,
            PageTransition(
                child: FestPage(
                  event: event,
                ),
                type: PageTransitionType.fade));
      } else if (event.isEvent) {
        Event? myChildEvent;
        for (int i = 0; i < allEventsList.length; i++) {
          Event childEvent = allEventsList[i];
          if (childEvent.parentId == event.id) {
            //print("child event exists");
            myChildEvent = childEvent;
            break;
          }
        }
        Navigator.push(
            context,
            PageTransition(
                child: EventPage(
                  event: myChildEvent!,
                ),
                type: PageTransitionType.fade));
      } else {
        // Navigator.push(context!!, MaterialPageRoute(builder: (context!!)=>EventPage(event: event)));
        Navigator.push(
            context,
            PageTransition(
                child: EventPage(
                  event: event,
                ),
                type: PageTransitionType.fade));
      }
    },
    child: Container(
      decoration: BoxDecoration(
          boxShadow: [containerShadow],
          color: event.goLive ? whiteColor : greyColor,
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      margin: EdgeInsets.all(7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context!).size.height / 8,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  color: cardBackgroundColor,
                  padding: event.bannerUrl == ""
                      ? EdgeInsets.all(10)
                      : EdgeInsets.all(0),
                  child: event.bannerUrl == ""
                      ? ComingSoonWidget(
                          waveColor: primaryColor,
                          boxBackgroundColor: cardBackgroundColor,
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 50,
                              color: primaryColor))
                      : FittedBox(
                          fit: BoxFit.cover,
                          child: Image(
                            image: NetworkImage(event.bannerUrl),
                          ),
                        ),
                )),
            width: MediaQuery.of(context).size.width / 2.5,
            // color: Colors.yellow,
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 2.0, 2.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: AutoSizeText(
                    event.name!,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  children: [
                    Icon(Icons.date_range),
                    SizedBox(
                      width: 1.0,
                    ),
                    SizedBox(
                      child: Text(
                        event.dateFrom == null
                            ? "Coming Soon"
                            : getFormattedDate(event.dateFrom!),
                        //softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
