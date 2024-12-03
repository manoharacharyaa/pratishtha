import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/attendanceServices.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart';
import 'package:pratishtha/services/storageServices.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  User? user;
  String currentAcademicYear = "";
  String teamId = "";
  bool isLoading = true; // To show the loading screen

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  Future<void> initializePage() async {
    try {
      // Fetch data in parallel
      final results = await Future.wait([
        fetchAcademicYear(),
        _loadUser(),
      ]);

      // After fetching user, use their data to fetch the team
      final fetchedUser = results[1] as User?;
      final fetchedTeamId = fetchedUser != null
          ? await AttendaceServices().fetchUsersDepartment(
        fetchedUser.firstName,
        fetchedUser.lastName,
        results[0] as String,
      ) : "";

      setState(() {
        currentAcademicYear = results[0] as String;
        user = fetchedUser;
        teamId = fetchedTeamId!;
        isLoading = false; // Stop showing loading screen
      });
    } catch (e) {
      debugPrint("Error initializing AttendancePage: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Wrapper to handle academic year fetching
  Future<String> fetchAcademicYear() async {
    return await getCurrentAcademicYear();
  }

  Future<String> getCurrentAcademicYear() async {
    DateTime currentDate = DateTime.now();

    DateTime startOfAcademicYear = DateTime(currentDate.year, 6, 15);
    DateTime endOfAcademicYear = DateTime(currentDate.year + 1, 5, 30);

    if (currentDate.isBefore(startOfAcademicYear)) {
      return "${currentDate.year - 1}-${currentDate.year}";
    } else if (currentDate.isAfter(endOfAcademicYear)) {
      return "${currentDate.year}-${currentDate.year + 1}";
    } else {
      return "${currentDate.year}-${currentDate.year + 1}";
    }
  }

  Future<User?> _loadUser() async {
    return await getUserFromPrefs(); // Fetch user from SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: loadingWidget()), // Show loading widget
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Error: User data not available")),
      );
    }

    return Scaffold(
      body: user!.role == 8
          ? AttendanceMasterModule(user!, currentAcademicYear) // Pass all loaded data
          : teamId != null ? AttendanceChildrenModule(user!, currentAcademicYear,teamId) : Container(),
    );
  }
}

// Jar Admin like banda so Attendance MasterModule else tar to user head/cohead asnar means to data add karnar + attendance pan

class AttendanceChildrenModule extends StatefulWidget {
  final User? user;
  final String currentAcademicYear;
  final String teamId;
  const AttendanceChildrenModule(this.user,this.currentAcademicYear,this.teamId,{super.key});

  @override
  State<AttendanceChildrenModule> createState() => _AttendanceChildrenModule();
}

class _AttendanceChildrenModule extends State<AttendanceChildrenModule> {
  bool showTextBoxes = false;
  List<User> userList = [];
  TextEditingController departmentNameController = TextEditingController();
  TextEditingController deptHeadorCoheadNameController = TextEditingController();
  final addkey = GlobalKey<FormState>();

  var db = DatabaseServices();
  var cs = StorageServices();
  var at = AttendaceServices();

  @override
  void initState() {
    super.initState();
    // Run both futures concurrently using Future.wait
    Future.wait([fetchUsers()]).then((results) {
      setState(() {
        userList = results[0];
      });
    });
  }



  Future<List<User>> fetchUsers() async {
    return await db.getSakecUsers();
  }


  void openUserSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      elevation: 10,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
            child: FutureBuilder<List<User>>(
              future: db.getSakecUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<User> data = snapshot.data!;
                  return Column(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: Row(
                          children: [
                            Text("Select Event Head", style: TextStyle(fontSize: 16)),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                color: Colors.lightBlue,
                                padding: EdgeInsets.fromLTRB(4, 2, 4, 3),
                                child: Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text("${data[index].firstName} ${data[index].lastName}"),
                              onTap: () {
                                setState(() {
                                  deptHeadorCoheadNameController.text = "${data[index].firstName} ${data[index].lastName}";
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: Text('No users available'));
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Page'),
      ),
      body: Column(
        children: [
          InkWell(
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: primaryColor,
              ),
              alignment: Alignment.center,
              child: Text(
                "Add Dept Head / Co-head",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            onTap: () {
              setState(() {
                showTextBoxes = !showTextBoxes;
              });
            },
          ),
          if (showTextBoxes) ...[
            Form(
              key: addkey,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: departmentNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter Dept Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue, width: 3, strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: deptHeadorCoheadNameController,
                        decoration: InputDecoration(
                          labelText: 'Select Member',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue, width: 3, strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => openUserSelectionModal(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(style: BorderStyle.solid, color: primaryColor),
                  color: Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Add Dept Details",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              onTap: () async {
                try {
                  if (addkey.currentState!.validate()) {
                    String result = await at.addHeadorCohead(
                      widget.currentAcademicYear,
                      departmentNameController.text,
                      deptHeadorCoheadNameController.text,
                    );

                    if (result == "Member Added" || result == "Member Updated") {
                      Fluttertoast.showToast(
                        msg: "Event Added Successfully",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 16.0,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Failed to add Details",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[700],
                        textColor: Colors.red,
                        fontSize: 16.0,
                      );
                    }
                  }
                } catch (e) {
                  // Log or show a toast with the error message
                  Fluttertoast.showToast(
                    msg: "An error occurred: $e",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red[700],
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  print('Error: $e'); // For debugging purposes
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}


class AttendanceMasterModule extends StatefulWidget {
  final User? user;
  final String currentAcademicYear;
  const AttendanceMasterModule(this.user,this.currentAcademicYear,{super.key});

  @override
  State<AttendanceMasterModule> createState() => _AttendanceMasterModule();
}

class _AttendanceMasterModule extends State<AttendanceMasterModule> {
  bool showTextBoxes = false;
  List<User> userList = [];
  TextEditingController departmentNameController = TextEditingController();
  TextEditingController deptHeadorCoheadNameController = TextEditingController();
  final addkey = GlobalKey<FormState>();

  var db = DatabaseServices();
  var cs = StorageServices();
  var at = AttendaceServices();

  @override
  void initState() {
    super.initState();
    // Run both futures concurrently using Future.wait
    Future.wait([fetchUsers()]).then((results) {
      setState(() {
        userList = results[0];
      });
    });
  }



  Future<List<User>> fetchUsers() async {
    return await db.getSakecUsers();
  }


  void openUserSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      elevation: 10,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
            child: FutureBuilder<List<User>>(
              future: db.getSakecUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<User> data = snapshot.data!;
                  return Column(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: Row(
                          children: [
                            Text("Select Event Head", style: TextStyle(fontSize: 16)),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                color: Colors.lightBlue,
                                padding: EdgeInsets.fromLTRB(4, 2, 4, 3),
                                child: Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text("${data[index].firstName} ${data[index].lastName}"),
                              onTap: () {
                                setState(() {
                                  deptHeadorCoheadNameController.text = "${data[index].firstName} ${data[index].lastName}";
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: Text('No users available'));
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Page'),
      ),
      body: Column(
        children: [
          InkWell(
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: primaryColor,
              ),
              alignment: Alignment.center,
              child: Text(
                "Add Dept Head / Co-head",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            onTap: () {
              setState(() {
                showTextBoxes = !showTextBoxes;
              });
            },
          ),
          if (showTextBoxes) ...[
            Form(
              key: addkey,
              child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: departmentNameController,
                      decoration: InputDecoration(
                        labelText: 'Enter Dept Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue, width: 3, strokeAlign: BorderSide.strokeAlignOutside),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: deptHeadorCoheadNameController,
                      decoration: InputDecoration(
                        labelText: 'Select Member',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue, width: 3, strokeAlign: BorderSide.strokeAlignOutside),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => openUserSelectionModal(context),
                    ),
                  ),
                ),
              ],
             ),
            ),
            InkWell(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(style: BorderStyle.solid, color: primaryColor),
                  color: Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Add Dept Details",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              onTap: () async {
                try {
                  if (addkey.currentState!.validate()) {
                    String result = await at.addHeadorCohead(
                      widget.currentAcademicYear,
                      departmentNameController.text,
                      deptHeadorCoheadNameController.text,
                    );

                    if (result == "Member Added" || result == "Member Updated") {
                      Fluttertoast.showToast(
                        msg: "Event Added Successfully",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 16.0,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Failed to add Details",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[700],
                        textColor: Colors.red,
                        fontSize: 16.0,
                      );
                    }
                  }
                } catch (e) {
                  // Log or show a toast with the error message
                  Fluttertoast.showToast(
                    msg: "An error occurred: $e",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red[700],
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  print('Error: $e'); // For debugging purposes
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}



