import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/screens/aboutUsPage.dart';
import 'package:pratishtha/screens/addCollege.dart';
import 'package:pratishtha/screens/admin/addEvent.dart';
import 'package:pratishtha/screens/admin/assignRolesPage.dart';
import 'package:pratishtha/screens/admin/editPoints.dart';
import 'package:pratishtha/screens/admin/editWallet.dart';
import 'package:pratishtha/screens/admin/manageSponsorship.dart';
import 'package:pratishtha/screens/gallery_screen.dart';
import 'package:pratishtha/screens/home/completedEvents.dart';
import 'package:pratishtha/screens/home/registeredEvents.dart';
import '../leaderBoard.dart';
import '../services/sharedPreferencesServices.dart' as sh;

class MyDrawer extends StatefulWidget {
  MyDrawer({Key? key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  Map? features;
  User? user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          buildStaticContent(),
          SizedBox(
            height: 5,
          ),
          buildDynamicContent(),
        ],
      ),
    );
  }

  buildStaticContent() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 40, bottom: 10),
          color: primaryColor,
          child: Image(
            fit: BoxFit.contain,
            image: AssetImage("assets/images/PratishthaLogo.png"),
          ),
        ),
      ],
    );
  }

  buildDynamicContent() {
    return Expanded(
      child: SingleChildScrollView(
        child: FutureBuilder<List>(
            future: Future.wait([
              sh.getFeatureListValuesFromPrefs(),
              sh.getUserFromPrefs(),
            ]),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                features = snapshot.data[0];
                user = snapshot.data[1];
                //print(features['1']['roles']);
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.height / 1.9,
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      !features?['1']['roles'].contains(user?.role)
                          ? Container()
                          : ListTile(
                              title: Text('Assign Roles'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AssignRoles(),
                                  ),
                                );
                              },
                            ),
                      // !features['7']['roles'].contains(user.role)
                      //     ? Container()
                      //     : ListTile(
                      //         title: Text('Assign Event Heads'),
                      //         onTap: () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder: (BuildContext context) =>
                      //                   AssignEventRoles(
                      //                 role: 2,
                      //               ),
                      //             ),
                      //           );
                      //         },
                      //       ),
                      // !features['8']['roles'].contains(user.role)
                      //     ? Container()
                      //     : ListTile(
                      //         title: Text('Assign Volunteers'),
                      //         onTap: () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder: (BuildContext context) =>
                      //                   AssignEventRoles(
                      //                 role: 1,
                      //               ),
                      //             ),
                      //           );
                      //         },
                      //       ),
                      !features?['0']['roles'].contains(user?.role)
                          ? Container()
                          : ListTile(
                              title: Text('Add Event'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AddEvent(),
                                  ),
                                );
                              },
                            ),
                      // !features?['3']['roles'].contains(user?.role)
                      //     ? Container()
                      //     : ListTile(
                      //         title: Text('Update Wallet'),
                      //         onTap: () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder: (BuildContext context) =>
                      //                   EditWallet(),
                      //             ),
                      //           );
                      //         },
                      //       ),
                      // !features?['9']['roles'].contains(user?.role)
                      //     ? Container()
                      //     : ListTile(
                      //         title: Text('Update Points'),
                      //         onTap: () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder: (BuildContext context) =>
                      //                   EditPoints(),
                      //             ),
                      //           );
                      //         },
                      //       ),
                      !features?['4']['roles'].contains(user?.role)
                          ? Container()
                          : ListTile(
                              title: Text('Manage Sponsorships'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ManageSponsorship(),
                                  ),
                                );
                              },
                            ),
                      !features?['5']['roles'].contains(user?.role)
                          ? Container()
                          : ListTile(
                              title: Text('Add/Update College'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AddCollege(),
                                  ),
                                );
                              },
                            ),
                      ListTile(
                        title: Text('LeaderBoard'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  LeaderBoard(),
                            ),
                          );
                        },
                      ),
                      // ListTile(
                      //   title: Text('Registered Events'),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (BuildContext context) =>
                      //             RegisteredEvents(),
                      //       ),
                      //     );
                      //   },
                      // ),
                      // ListTile(
                      //   title: Text('Completed Events'),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (BuildContext context) =>
                      //             CompletedEvents(),
                      //       ),
                      //     );
                      //   },
                      // ),
                      // ListTile(
                      //   title: Text('Gallery'),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (BuildContext context) =>
                      //             GalleryScreen(),
                      //       ),
                      //     );
                      //   },
                      // ),
                      ListTile(
                        title: Text('About Us'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => AboutUs(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                debugPrint("auth wrapper: ${snapshot.error}");
                return Text(
                    "Oops something seems to have gone wrong, please try again.");
              } else {
                return Center(
                    child: CircularProgressIndicator(color: primaryColor));
              }
            }),
      ),
    );
  }
}
