import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/screens/admin/event_approval/registration_list_page.dart';
import 'package:pratishtha/screens/admin/event_approval/regristration_model.dart';
import 'package:pratishtha/utils/fonts.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key, required this.event});

  final RegistrationModel event;

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  bool _isLoading = false;
  List<String> approvedUids = [];
  List<Registration> eventRegistrations = [];
  List<Registration> filteredRegistrations = [];
  final searchController = TextEditingController();

  _setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  Future<void> fetchRegistrations() async {
    _setLoading(true);
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('registrations')
          .doc(widget.event.eventId)
          .get();

      final data = docSnapshot.data() as Map<String, dynamic>;
      final List<dynamic> registrations = data['registrations'];

      List<Registration> fetchedRegistrations =
          registrations.map((reg) => Registration.fromJson(reg)).toList();

      setState(() {
        eventRegistrations = fetchedRegistrations;

        final query = searchController.text.toLowerCase();
        if (query.isNotEmpty) {
          filteredRegistrations = fetchedRegistrations
              .where((reg) => reg.userName.toLowerCase().contains(query))
              .toList();
        } else {
          filteredRegistrations = fetchedRegistrations;
        }
      });
    } catch (e) {
      print('Error fetching registrations: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAprovedUids() async {
    final eventsSnapshots =
        await FirebaseFirestore.instance.collection('events').get();

    final eventDocs = eventsSnapshots.docs;

    final eventData = eventDocs.map((doc) => doc.data()).toList();

    for (var event in eventData) {
      if (event.containsKey('approved_users')) {
        approvedUids.add('approved_users');
      }
    }
  }

  Future<void> checkApprovedUsers() async {
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.eventId)
        .get();

    if (eventSnapshot.exists) {
      Map<String, dynamic> eventData =
          eventSnapshot.data() as Map<String, dynamic>;

      if (eventData.containsKey('approved_users')) {
        approvedUids = List<String>.from(eventData['approved_users']);
      }
    }

    setState(() {});
  }

  void _showSSDialog(BuildContext context, String screenshot) {
    final size = MediaQuery.sizeOf(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            Container(
              height: size.height * 0.8,
              width: size.width * 0.8,
              color: Colors.white,
              child: Image.network(screenshot),
            ),
          ],
        );
      },
    );
  }

  void _approvalRejectionDailog(BuildContext context,
      {String? title, void Function()? onConfirm, String? lottie}) async {
    final size = MediaQuery.sizeOf(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: size.height * 0.2,
                width: size.height * 0.2,
                child: Column(
                  children: [
                    Text(
                      title ?? '',
                      textAlign: TextAlign.center,
                      style: AppFonts.poppins(),
                    ),
                    Expanded(child: Lottie.asset(lottie ?? '')),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xff32cf15),
                      ),
                    ),
                    child: Text(
                      'confirm',
                      style: AppFonts.poppins(color: Colors.white, size: 15),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xffee0000),
                      ),
                    ),
                    child: Text(
                      'cancel',
                      style: AppFonts.poppins(color: Colors.white, size: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadConfirmation(String uid, String imageUrl) async {
    print('---uid: $uid');

    DocumentReference eventRef = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.eventId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(eventRef);

      if (!snapshot.exists) {
        print("Event does not exist!");
        return;
      }

      Map<String, dynamic>? eventData =
          snapshot.data() as Map<String, dynamic>?;

      List<String> approvedUsers =
          eventData != null && eventData.containsKey('approved_users')
              ? List<String>.from(eventData['approved_users'])
              : [];

      if (!approvedUsers.contains(uid)) {
        approvedUsers.add(uid);
      }

      transaction.update(eventRef, {'approved_users': approvedUsers});
    }).then((_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Approved Sucessfully');
      // deleteSSfromStorage(imageUrl);
      print("Successfully updated Firestore!");
    }).catchError((error) {
      print("Error updating Firestore: $error");
    });
  }

  // Future<void> deleteSSfromStorage(String imageUrl) async {
  //   try {
  //     Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
  //     await storageRef.delete();
  //     print("✅ Image deleted successfully from Firebase Storage");
  //   } catch (e) {
  //     print("❌ Error deleting image: $e");
  //   }
  // }

  @override
  void initState() {
    checkApprovedUsers();
    fetchRegistrations();
    searchController.addListener(() {
      fetchRegistrations();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event.eventName,
          style: AppFonts.poppins(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            CustomSearchBar(searchController: searchController),
            const SizedBox(height: 10),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredRegistrations.length,
                    itemBuilder: (context, index) {
                      final registration = filteredRegistrations[index];
                      return Container(
                        height: size.height * 0.18,
                        width: double.infinity,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                _showSSDialog(context, registration.screenshot);
                              },
                              child: Container(
                                height: size.height * 0.3,
                                width: 80,
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: registration.screenshot.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No SS Found',
                                          style: AppFonts.poppins(size: 10),
                                        ),
                                      )
                                    : Image.network(registration.screenshot),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.65,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              'Name: ${registration.userName}',
                                              maxLines: 1,
                                              style: AppFonts.poppins(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.65,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              'Branch: ${registration.branch}',
                                              maxLines: 1,
                                              style: AppFonts.poppins(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.65,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              'Phone: ${registration.phone}',
                                              maxLines: 1,
                                              style: AppFonts.poppins(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: approvedUids
                                          .contains(registration.uid)
                                      ? [
                                          Container(
                                            // margin: EdgeInsets.only(
                                            //   left: size.width * 0.38,
                                            // ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: Color(0xff32cf15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Approved',
                                              style: AppFonts.poppins(
                                                  color: Colors.white,
                                                  size: 16),
                                            ),
                                          ),
                                        ]
                                      : [
                                          SizedBox(
                                            width: size.width * 0.30,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                  Color(0xff32cf15),
                                                ),
                                              ),
                                              onPressed: () {
                                                _approvalRejectionDailog(
                                                  context,
                                                  title: 'Confirm\nApproval',
                                                  lottie:
                                                      'assets/lottie/tick.json',
                                                  onConfirm: () {
                                                    uploadConfirmation(
                                                      registration.uid,
                                                      registration.screenshot,
                                                    ).then((_) {
                                                      checkApprovedUsers();

                                                      Navigator.pop(context);
                                                      print(
                                                          '✅ Approval success');
                                                    }).catchError((error) {
                                                      print('❌ Error: $error');
                                                    });
                                                  },
                                                );
                                              },
                                              child: Text(
                                                'Approve',
                                                style: AppFonts.poppins(
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.03,
                                          ),
                                          SizedBox(
                                            width: size.width * 0.30,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                  Color(0xffee0000),
                                                ),
                                              ),
                                              onPressed: () {
                                                _approvalRejectionDailog(
                                                  context,
                                                  title: 'Confirm\nRejection',
                                                  lottie:
                                                      'assets/lottie/cross.json',
                                                );
                                              },
                                              child: Text(
                                                'Reject',
                                                style: AppFonts.poppins(
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // SizedBox(
                                          //   width: size.width * 0.02,
                                          // ),
                                        ],
                                ),
                              ],
                            ),
                          ],
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
