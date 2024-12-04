import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/attendanceServices.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/storageServices.dart';

class AttendanceChildrenModule extends StatefulWidget {
  final User? user;
  final String currentAcademicYear;
  final String teamId;
  const AttendanceChildrenModule(
      this.user, this.currentAcademicYear, this.teamId,
      {super.key});

  @override
  State<AttendanceChildrenModule> createState() => _AttendanceChildrenModule();
}

class _AttendanceChildrenModule extends State<AttendanceChildrenModule> {
  bool showTextBoxes = false;
  List<User> userList = [];
  TextEditingController volunteerFirstNameController = TextEditingController();
  TextEditingController volunteerLastNameController = TextEditingController();
  TextEditingController volunteerFullNameController = TextEditingController();
  TextEditingController volunteerClassDivController = TextEditingController();
  TextEditingController volunteerRollNoController = TextEditingController();
  TextEditingController volunteerBranchController = TextEditingController();
  TextEditingController volunteerPRNController = TextEditingController();
  TextEditingController volunteerSakecmailController = TextEditingController();

  List<Map<String, String>> volunteerList = [];
  Map<String, bool> attendanceStatus = {};

  List<String> branchList = [
    'Comps',
    'IT',
    'EXTC',
    'CYSE',
    'AIDS',
    'ECS',
    'EEE',
    'ACT',
    'VLSI',
    'B.Voc AIDS',
    'B.Voc CYSE',
  ];

  final addkey = GlobalKey<FormState>();

  var db = DatabaseServices();
  var cs = StorageServices();
  var at = AttendaceServices();

  @override
  void initState() {
    super.initState();
    Future.wait([
      fetchUsers(),
      AttendaceServices()
          .getVolunteerList(widget.currentAcademicYear, widget.teamId)
    ]).then((results) {
      setState(() {
        // Cast to the correct types
        userList = results[0] as List<User>;
        volunteerList = results[1] as List<Map<String, String>>;
      });
    });
  }

  Future<List<User>> fetchUsers() async {
    return await db.getSakecUsers();
  }

  void openUserSelectionModal(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<User> filteredData = [];

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
        return StatefulBuilder(
          builder: (context, setState) {
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
                      filteredData = filteredData.isEmpty
                          ? data
                          : filteredData; // Initialize filteredData
                      return Column(
                        children: [
                          // Search Bar
                          Container(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      labelText: "Search Students",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    onChanged: (query) {
                                      setState(() {
                                        filteredData = data
                                            .where((user) =>
                                                user.firstName!
                                                    .toLowerCase()
                                                    .contains(
                                                        query.toLowerCase()) ||
                                                user.lastName!
                                                    .toLowerCase()
                                                    .contains(
                                                        query.toLowerCase()))
                                            .toList();
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.search, color: Colors.blue),
                                  onPressed: () {
                                    String query = searchController.text.trim();
                                    setState(() {
                                      filteredData = data
                                          .where((user) =>
                                              user.firstName!
                                                  .toLowerCase()
                                                  .contains(
                                                      query.toLowerCase()) ||
                                              user.lastName!
                                                  .toLowerCase()
                                                  .contains(
                                                      query.toLowerCase()))
                                          .toList();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          // List of Students
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                      "${filteredData[index].firstName} ${filteredData[index].lastName}"),
                                  onTap: () {
                                    setState(() {
                                      volunteerFirstNameController.text =
                                          filteredData[index].firstName!;
                                      volunteerLastNameController.text =
                                          filteredData[index].lastName!;
                                      volunteerSakecmailController.text =
                                          filteredData[index].sakecId;
                                      volunteerFullNameController.text =
                                          "${filteredData[index].firstName!} ${filteredData[index].lastName!}";
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
      },
    );
  }

  void submitAttendance() async {
    List<String> volunteerIds = [];
    List<bool> volunteerAttendanceStatus = [];

    attendanceStatus.forEach((docId, status) {
      volunteerIds.add(docId);
      volunteerAttendanceStatus.add(status); // Use boolean status directly
    });

    try {
      // Await the result from addVoulunteerAttendance
      String result = await at.addVoulunteerAttendance(
        widget.currentAcademicYear,
        widget.teamId,
        volunteerIds,
        volunteerAttendanceStatus,
      );

      // Check if the result explicitly matches "Success"
      if (result.trim().toLowerCase() == "success") {
        print("Attendance submitted successfully!");
        Fluttertoast.showToast(
          msg: "Attendance added successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green[700],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        // Handle any non-success response
        print("Failed to submit attendance: $result");
        Fluttertoast.showToast(
          msg: "Failed to add attendance: $result",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red[700],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // Handle exceptions and display a toast
      print("Error submitting attendance: $e");
      Fluttertoast.showToast(
        msg: "Error submitting attendance: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red[700],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Page'),
      ),
      body: Scrollable(
          viewportBuilder: (BuildContext context, ViewportOffset position) {
        return Column(
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
                  "Add New Volunteer : ${widget.teamId}",
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: volunteerFullNameController,
                        decoration: InputDecoration(
                          labelText: 'Select Member',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 3,
                                strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => openUserSelectionModal(context),
                      ),
                    ),
                    // Class-Division and Roll No
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: TextField(
                              controller: volunteerClassDivController,
                              decoration: InputDecoration(
                                labelText: 'Enter Class-Div',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 3,
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: TextField(
                              controller: volunteerRollNoController,
                              decoration: InputDecoration(
                                labelText: 'Enter Roll No',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 3,
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: DropdownButtonFormField<String>(
                        value: branchList
                                .contains(volunteerBranchController.text)
                            ? volunteerBranchController.text
                            : null, // Ensure initial value matches one of the items
                        items: branchList
                            .map((value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            volunteerBranchController.text =
                                value ?? ''; // Update controller
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Branch',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 10,
                            ),
                          ),
                        ),
                        hint: const Text(
                            "Select Branch"), // Show when no value is selected
                      ),
                    ),

                    // PRN Input
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: volunteerPRNController,
                        decoration: InputDecoration(
                          labelText: 'Enter PRN',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 3,
                                strokeAlign: BorderSide.strokeAlignOutside),
                          ),
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
                    border: Border.all(
                        style: BorderStyle.solid, color: primaryColor),
                    color: Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Add New Volunteer",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                onTap: () async {
                  try {
                    if (addkey.currentState!.validate()) {
                      String result =
                          await AttendaceServices().addVolunteerDetails(
                        volunteerFirstNameController.text,
                        volunteerLastNameController.text,
                        volunteerBranchController.text,
                        volunteerClassDivController.text,
                        volunteerPRNController.text,
                        volunteerSakecmailController.text,
                        int.parse(volunteerRollNoController.text),
                        widget.currentAcademicYear,
                        widget.teamId,
                      );

                      if (result == 'Success') {
                        Fluttertoast.showToast(
                          msg: "Volunteer added successfully",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green[700],
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: "Failed to add member(s)",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red[700],
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  } catch (e) {
                    // Log or show a toast with the error message
                    Fluttertoast.showToast(
                      msg: "An error occurred : $e",
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
            Expanded(
              child: Column(
                children: [
                  // Header Row
                  Container(
                    color: Colors.blue[100],
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        // Serial Number Header
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.15, // 10% width
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Sr. No',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Volunteer Name Header
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.5, // 50% width
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 60),
                          child: Text(
                            'Volunteers',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Present Header
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.175, // 20% width
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(right: 20.0),
                          child: Text(
                            'Present',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Absent Header
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.175, // 20% width
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(right: 10.0),
                          child: Text(
                            'Absent',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Volunteer List
                  Expanded(
                    child: ListView.builder(
                      itemCount: volunteerList.length,
                      itemBuilder: (context, index) {
                        final volunteer = volunteerList[index];
                        final docId = volunteer['docId'];
                        final name = volunteer['name'];

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  // Serial Number
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.1, // 10% width
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  // Volunteer Name
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.5, // 50% width
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 35.0),
                                    child: Text(
                                      name!,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  // Present Button
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.2, // 20% width
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: 15.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        backgroundColor:
                                            attendanceStatus[docId] == true
                                                ? Colors.green
                                                : Colors.white,
                                        foregroundColor:
                                            attendanceStatus[docId] == true
                                                ? Colors.white
                                                : Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(color: Colors.green),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          attendanceStatus[docId!] = true;
                                        });
                                      },
                                      child: Icon(
                                        Icons.check,
                                        color: attendanceStatus[docId] == true
                                            ? Colors.white
                                            : Colors.green,
                                      ),
                                    ),
                                  ),
                                  // Absent Button
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.2, // 20% width
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        backgroundColor:
                                            attendanceStatus[docId] == false
                                                ? Colors.red
                                                : Colors.white,
                                        foregroundColor:
                                            attendanceStatus[docId] == false
                                                ? Colors.white
                                                : Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(color: Colors.red),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          attendanceStatus[docId!] = false;
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: attendanceStatus[docId] == false
                                            ? Colors.white
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index < volunteerList.length - 1)
                              Divider(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Submit Button
                  InkWell(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Submit Attendance",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () {
                      submitAttendance();
                    },
                  ),
                  Spacer()
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
