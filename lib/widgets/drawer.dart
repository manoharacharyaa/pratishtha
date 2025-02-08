import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/userModel.dart' as app;
import 'package:pratishtha/screens/aboutUsPage.dart';
import 'package:pratishtha/screens/addCollege.dart';
import 'package:pratishtha/screens/addCouncil.dart';
import 'package:pratishtha/screens/admin/addEvent.dart';
import 'package:pratishtha/screens/admin/event_approval/registration_list_page.dart';
import 'package:pratishtha/screens/admin/assignRolesPage.dart';
import 'package:pratishtha/screens/admin/attendanceSystem/attendance.dart';
import 'package:pratishtha/screens/admin/attendanceSystem/viewAttendance.dart';
import 'package:pratishtha/screens/admin/manageSponsorship.dart';
import 'package:pratishtha/utils/fonts.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeHome.dart';
import '../leaderBoard.dart';
import '../services/sharedPreferencesServices.dart' as sh;

class MyDrawer extends StatefulWidget {
  MyDrawer({super.key});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  Map? features;
  app.User? user;
  User? currentUser;
  bool _isAnApprovedUser = false;

  List<app.User> approvalAccess = [];
  Future<bool> checkFieldExists() async {
    try {
      // Get the document
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      // Check if the document exists
      if (docSnapshot.exists) {
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;
        return data?.containsKey("isDeptHead2024_25") ?? false;
      }
      return false; // Document does not exist
    } catch (e) {
      print("Error checking field in document: $e");
      return false;
    }
  }

  bool? isEventHead24_25;
  Future<void> getCurrentUID() async {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> getCurrentUsersSAKECEmail() async {
    print('getCurrentUsersSAKECEmail called');
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (!userSnapshot.exists) return;

    Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;

    String email = data['email'];
    String sakecEmail = data['sakec_id'];

    print(email);
    print(sakecEmail);

    if (currentUser != null) {
      if (emails.contains(email) || emails.contains(sakecEmail)) {
        print('--Approved User 🔥😄');
        setState(() {
          _isAnApprovedUser = true;
        });
      } else {
        print('--Not an Approved User 😢');
      }
    }
  }

  List<String> emails = [
    'umang.jain16823@sakec.ac.in',
    'yashkumar.jain16659@sakec.ac.in',
    'diya.17365@sakec.ac.in',
    'manoharacharya63@gmail.com',
    'manohar.acharya16602@sakec.ac.in'
        'pradneshssr.45@gmail.com'
        'pradnesh.revadekar17644@sakec.ac.in',
  ];

  @override
  void initState() {
    getCurrentUID().then((_) {
      getCurrentUsersSAKECEmail();
    });
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
                // Call checkFieldExists() after user is populated
                if (isEventHead24_25 == null) {
                  checkFieldExists().then((exists) {
                    setState(() {
                      isEventHead24_25 = exists;
                      print("UUid Exists or not: $exists");
                    });
                  });
                }
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
                              title: Text(
                                'Assign Roles',
                                style: AppFonts.poppins(size: 14),
                              ),
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
                              title: Text(
                                'Add Event',
                                style: AppFonts.poppins(size: 14),
                              ),
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
                              title: Text(
                                'Manage Sponsorships',
                                style: AppFonts.poppins(size: 14),
                              ),
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
                              title: Text(
                                'Add/Update College',
                                style: AppFonts.poppins(size: 14),
                              ),
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
                      isEventHead24_25 == true || user?.role == 8
                          ? ListTile(
                              title: Text(
                                'Attendance',
                                style: AppFonts.poppins(size: 14),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AttendancePage(), // Replace with your AttendancePage class
                                  ),
                                );
                              },
                            )
                          : Container(),
                      // ListTile(
                      //   title: Text('InterCollege'),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (BuildContext context) =>
                      //             InterCollegeHome(
                      //           userRole: user!.role,
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                      user?.role == 9
                          ? ListTile(
                              title: Text(
                                'Attendance',
                                style: AppFonts.poppins(size: 14),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ViewAttendanceAsTeacher(
                                            '2024-2025'), // Replace with your AttendancePage class
                                  ),
                                );
                              },
                            )
                          : SizedBox(),

                      ListTile(
                        title: Text(
                          'LeaderBoard',
                          style: AppFonts.poppins(size: 14),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => LeaderBoard(),
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
                      //      ListTile(
                      //   title: Text('Add council  backend'),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (BuildContext context) => AddCouncil(),
                      //       ),
                      //     );
                      //   },
                      // ),
                      ListTile(
                        title: Text(
                          'About Us',
                          style: AppFonts.poppins(size: 14),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => AboutUs(),
                            ),
                          );
                        },
                      ),
                      _isAnApprovedUser
                          ? ListTile(
                              title: Text(
                                'Approval',
                                style: AppFonts.poppins(size: 14),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const RegistrationListPage(),
                                  ),
                                );
                              },
                            )
                          : const SizedBox(),
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
