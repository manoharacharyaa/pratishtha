import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/searchServices.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/eventCard.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/noContentWidget.dart';
import 'package:pratishtha/widgets/userCard.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController titleSearchController = TextEditingController();
  List<Event> eventsSearchResultsList = [];
  List<Event> festsSearchResultsList = [];
  List<User> usersSearchResultsList = [];
  List<Widget> combinedSearchResultsList = [];
  List<Widget> displaySearchResults = [];
  User? currentUser;
  DatabaseServices databaseServices = DatabaseServices();

  @override
  void dispose() {
    //onClear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: FutureBuilder<List>(
        future: Future.wait([
          databaseServices.getEvents(),
          databaseServices.getFests(),
          databaseServices.getUsers(),
          databaseServices.getCurrentUser()
        ]),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData && !snapshot.hasError) {
            return Center(child: loadingWidget());
          } else if (snapshot.hasError) {
            //print("search snapshot error: ${snapshot.error}");
            return Center(child: CustomErrorWidget());
          } else {
            List<Event> eventsSnapshot = snapshot.data![0];
            List<Event> festsSnapshot = snapshot.data![1];
            List<User> usersSnapshot = snapshot.data![2];
            currentUser = snapshot.data![3];
            //User currentUserSnapshot = snapshot.data[3];

            List specialAllEventsList = eventsSnapshot + festsSnapshot;

            festsSnapshot.forEach((Event event) {
              if (event.isEvent) {
                eventsSnapshot.removeWhere(
                    (Event childEvent) => childEvent.id == event.childId![0]);
              }
            });

            List<Event> tempAllEventsList = [];

            if ([5, 3].contains(currentUser!.role)) {
              tempAllEventsList = eventsSnapshot + festsSnapshot;
            } else {
              eventsSnapshot.forEach((Event event) {
                if (event.goLive) {
                  if (event.forSakec) {
                    if (event.forFaculty) {
                      if (currentUser!.isFaculty!) {
                        tempAllEventsList.add(event);
                      }
                    } else if (currentUser!.institute == "SAKEC") {
                      tempAllEventsList.add(event);
                    }
                  } else {
                    tempAllEventsList.add(event);
                  }
                }
              });
              festsSnapshot.forEach((Event event) {
                if (event.goLive) {
                  tempAllEventsList.add(event);
                }
              });
            }
            return Column(
              children: [
                buildTitleSearchField(
                    context: context,
                    allEvents: tempAllEventsList,
                    allUsers: usersSnapshot),
                SizedBox(height: 10),
                Container(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      filterButton(
                          buttonText: "Events",
                          filterIcon: Icon(
                            Icons.event_outlined,
                            color: primaryColor,
                          ),
                          filterFunction: () {
                            setState(() {
                              displaySearchResults =
                                  filterByEvents(tempAllEventsList);
                            });
                          },
                          context: context),
                      SizedBox(
                        height: 40,
                        child: VerticalDivider(
                          color: dullGreyColor,
                          width: 0.5,
                        ),
                      ),
                      filterButton(
                          buttonText: "Fests",
                          filterIcon: Icon(
                            Icons.festival_outlined,
                            color: primaryColor,
                          ),
                          filterFunction: () {
                            setState(() {
                              displaySearchResults = filterByFests(
                                  tempAllEventsList,
                                  specialAllEventsList.cast<Event>());
                            });
                          },
                          context: context),
                      SizedBox(
                        height: 40,
                        child: VerticalDivider(
                          color: dullGreyColor,
                          width: 0.5,
                        ),
                      ),
                      filterButton(
                          buttonText: "Users",
                          filterIcon: Icon(
                            FontAwesomeIcons.userCircle,
                            color: primaryColor,
                          ),
                          filterFunction: () {
                            setState(() {
                              displaySearchResults =
                                  filterByUsers(usersSnapshot);
                            });
                          },
                          context: context)
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 2 * MediaQuery.of(context).size.height / 3,
                  child: combinedSearchResultsList.length == 0
                      ? buildNoContent()
                      : ListView(
                          children: displaySearchResults,
                        ),
                )
              ],
            );
          }
        },
      ),
    ));
  }

  onClear() {
    setState(() {
      displaySearchResults.clear();
      combinedSearchResultsList.clear();
      eventsSearchResultsList.clear();
      festsSearchResultsList.clear();
      usersSearchResultsList.clear();
      titleSearchController.clear();
    });
  }

  Widget filterButton({
    String? buttonText,
    Icon? filterIcon,
    VoidCallback? filterFunction,
    BuildContext? context,
  }) {
    return GestureDetector(
      onTap: filterFunction,
      child: TextButton.icon(
        onPressed: filterFunction,
        icon: filterIcon!,
        label: Text(
          buttonText!,
          style: TextStyle(color: primaryColor),
        ),
      ),
    );
  }

  List<Widget> filterByEvents(List<Event> allEventsList) {
    //print("filter by events called");
    List<Widget> displaySearchResultsList = [];
    for (int i = 0; i < eventsSearchResultsList.length; i++) {
      if (eventsSearchResultsList[i].parentId == "") {
        // displaySearchResultsList.add(EventCard(
        //     context: context,
        //     event: eventsSearchResultsList[i],
        //     allEventsList: allEventsList));
        continue;
      } else {
        displaySearchResultsList.add(EventCard(
            context: context,
            event: eventsSearchResultsList[i],
            isVerified: currentUser!.isVerified));
      }
    }

    return displaySearchResultsList;

    // setState(() {
    //   displaySearchResults = displaySearchResultsList;
    // });
  }

  List<Widget> filterByUsers(List<User> allUsers) {
    List<Widget> displaySearchResultsList = [];

    for (int i = 0; i < usersSearchResultsList.length; i++) {
      displaySearchResultsList.add(UserCard(user: usersSearchResultsList[i]));
    }

    return displaySearchResultsList;

    // setState(() {
    //   displaySearchResults = displaySearchResultsList;
    // });
  }

  List<Widget> filterByFests(
      List<Event>? allEventsList, List<Event>? specialAllEventsList) {
    List<Widget> displaySearchResultsList = [];

    for (int i = 0; i < eventsSearchResultsList.length; i++) {
      if (eventsSearchResultsList[i].parentId == "") {
        displaySearchResultsList.add(EventCard(
            context: context,
            event: eventsSearchResultsList[i],
            isVerified: currentUser!.isVerified,
            allEventsList: specialAllEventsList!));
      }
    }

    return displaySearchResultsList;

    // setState(() {
    //   displaySearchResults = displaySearchResultsList;
    // });
  }

  handleTitleSearch(
      {String? query, List<Event>? allEventsList, List<User>? allUsersList}) {
    List<User> userSearchResults =
        userSearch(query: query!, allUsersList: allUsersList!);
    List<Event> eventSearchResults =
        eventSearch(query: query, allEventsList: allEventsList!);
    List<Widget> combinedSearchResults = [];

    for (int i = 0; i < eventSearchResults.length; i++) {
      if (eventSearchResults[i].parentId == "") {
        combinedSearchResults.add(EventCard(
            context: context,
            event: eventSearchResults[i],
            isVerified: currentUser!.isVerified,
            allEventsList: allEventsList));
      } else {
        combinedSearchResults.add(EventCard(
            context: context,
            event: eventSearchResults[i],
            isVerified: currentUser!.isVerified));
      }
    }
    for (int i = 0; i < userSearchResults.length; i++) {
      combinedSearchResults.add(UserCard(user: userSearchResults[i]));
    }

    setState(() {
      displaySearchResults.clear();
      combinedSearchResultsList.clear();
      eventsSearchResultsList = eventSearchResults;
      usersSearchResultsList = userSearchResults;
      combinedSearchResultsList = combinedSearchResults;
      displaySearchResults = combinedSearchResults;
    });

    //print("combined search results: $combinedSearchResults");
  }

  Widget buildTitleSearchField(
      {BuildContext? context, List<Event>? allEvents, List<User>? allUsers}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: TextFormField(
          controller: titleSearchController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            hintText: "Search for a fest, event or profile",
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[300],
            prefixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                handleTitleSearch(
                  query: titleSearchController.text,
                  allEventsList: allEvents,
                  allUsersList: allUsers,
                );
              },
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                onClear();
              },
            ),
          ),
          onChanged: (value) {
            if (value != "") {
              handleTitleSearch(
                  query: value,
                  allEventsList: allEvents,
                  allUsersList: allUsers);
            } else {
              onClear();
            }
          },
        ),
      ),
    );
  }

  Widget buildTitleSearchResults() {
    return Container();
  }

  Widget buildNoContent() {
    return noContentWidget();
  }
}
