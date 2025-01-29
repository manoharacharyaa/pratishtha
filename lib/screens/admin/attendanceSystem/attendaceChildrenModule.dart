import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/attendanceServices.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/storageServices.dart';
import 'package:pratishtha/widgets/customTextField.dart';

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
  late Future<List<User>> users;
  TextEditingController volunteerFirstNameController = TextEditingController();
  TextEditingController volunteerLastNameController = TextEditingController();
  TextEditingController volunteerFullNameController = TextEditingController();
  TextEditingController volunteerClassDivController = TextEditingController();
  TextEditingController volunteerRollNoController = TextEditingController();
  TextEditingController volunteerBranchController = TextEditingController();
  TextEditingController volunteerPRNController = TextEditingController();
  TextEditingController volunteerSakecmailController = TextEditingController();
  TextEditingController departmentPersonUUidController =
      TextEditingController();
  TextEditingController TodayDate = TextEditingController();

  List<Map<String, String>> volunteerList = [];
  Map<String, bool> attendanceStatus = {};
  String isTodayAttendanceMarked = '';

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
    users = db.getSakecUsers();
    Future.wait([
      fetchUsers(),
      AttendaceServices()
          .getVolunteerList(widget.currentAcademicYear, widget.teamId),
      AttendaceServices()
          .checkTodayAttendanceEntry(widget.currentAcademicYear, widget.teamId)
    ]).then((results) {
      setState(() {
        // Cast to the correct types
        userList = results[0] as List<User>;
        volunteerList = results[1] as List<Map<String, String>>;
        isTodayAttendanceMarked = results[2] as String;
        log(isTodayAttendanceMarked);
      });
    });
    TodayDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
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
                  future: users,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      List<User> data = snapshot.data!;
                      List<User> srch = [];
                      srch.addAll(data);
                      if (filteredData.isEmpty) filteredData = data;
                      return Column(
                        children: [
                          // Search Bar Container
                          Container(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomTextField1(
                                    controller: searchController,
                                    hintText: 'Enter User Name',
                                    labelText: 'Enter User Name',
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        filteredData = data
                                            .where(
                                              (user) =>
                                                  user.firstName!
                                                      .toLowerCase()
                                                      .contains(
                                                        value.toLowerCase(),
                                                      ) ||
                                                  user.lastName!
                                                      .toLowerCase()
                                                      .contains(
                                                        value.toLowerCase(),
                                                      ),
                                            )
                                            .toList();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // List of Students
                          Flexible(
                              child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: searchController.text.isEmpty
                                ? srch.length
                                : filteredData.length,
                            itemBuilder: (context, index) {
                              // Determine which list to use based on search status
                              User selectedUser = searchController.text.isEmpty
                                  ? srch[index]
                                  : filteredData[index];

                              return ListTile(
                                title: Text(
                                    "${selectedUser.firstName} ${selectedUser.lastName}"),
                                onTap: () {
                                  // Update the controllers outside of setState
                                  departmentPersonUUidController.text =
                                      selectedUser.uid!;
                                  volunteerFullNameController.text =
                                      "${selectedUser.firstName} ${selectedUser.lastName}";

                                  // Trigger a rebuild of the parent widget to update the text field
                                  Navigator.pop(context);
                                },
                              );
                            },
                          )),
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
      String result = await at.addVolunteerAttendance(
        widget.currentAcademicYear,
        widget.teamId,
        volunteerIds,
        volunteerAttendanceStatus,
        TodayDate.text,

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
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AttendanceChildrenModule(
                    widget.user, widget.currentAcademicYear, widget.teamId)));
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

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.deepPurple.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.deepPurple.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                      child: Stack(
                        children: [
                          // Main Content
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Title
                                  Center(
                                    child: Text(
                                      'Add New Volunteer',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Form
                                  Form(
                                    key: addkey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Member Selection
                                        _buildAnimatedTextField(
                                          controller:
                                              volunteerFullNameController,
                                          labelText: 'Select Member',
                                          readOnly: true,
                                          onTap: () =>
                                              openUserSelectionModal(context),
                                        ),

                                        // Class and Roll Number Row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildAnimatedTextField(
                                                controller:
                                                    volunteerClassDivController,
                                                labelText: 'Enter Class-Div',
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: _buildAnimatedTextField(
                                                controller:
                                                    volunteerRollNoController,
                                                labelText: 'Enter Roll No',
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Branch Dropdown
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors
                                                      .deepPurple.shade200),
                                            ),
                                            child:
                                                DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 5),
                                                border: InputBorder.none,
                                                // labelText: 'Select Branch',
                                                // labelStyle: TextStyle(
                                                //     color: Colors.black),
                                              ),
                                              value: branchList.contains(
                                                      volunteerBranchController
                                                          .text)
                                                  ? volunteerBranchController
                                                      .text
                                                  : null,
                                              items: branchList
                                                  .map((value) =>
                                                      DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(value),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  volunteerBranchController
                                                      .text = value ?? '';
                                                });
                                              },
                                              hint: Text(
                                                "Select Branch",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // PRN Input
                                        _buildAnimatedTextField(
                                          controller: volunteerPRNController,
                                          labelText: 'Enter PRN',
                                        ),
                                        _buildAnimatedTextField(
                                          controller:
                                              volunteerSakecmailController,
                                          labelText: 'Enter SAKEC mail',
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  // Add Volunteer Button
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade800,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                    ),
                                    onPressed: () async {
                                      try {
                                        if (addkey.currentState!.validate()) {
                                          String result =
                                              await AttendaceServices()
                                                  .addVolunteerDetails(
                                            volunteerFullNameController.text
                                                .split(' ')
                                                .first, // First name
                                            volunteerFullNameController.text
                                                        .split(' ')
                                                        .length >
                                                    1
                                                ? volunteerFullNameController
                                                    .text
                                                    .split(' ')
                                                    .sublist(1)
                                                    .join(' ')
                                                : '', // Last name
                                            volunteerBranchController.text,
                                            volunteerClassDivController.text,
                                            volunteerPRNController.text,
                                            volunteerSakecmailController.text,
                                            int.parse(
                                                volunteerRollNoController.text),
                                            widget.currentAcademicYear,
                                            widget.teamId,
                                          );

                                          if (result == 'Success') {
                                            Fluttertoast.showToast(
                                              msg:
                                                  "Volunteer added successfully",
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor:
                                                  Colors.green[700],
                                              textColor: Colors.white,
                                            );
                                          }
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: "Failed to add member(s)",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red[700],
                                            textColor: Colors.white,
                                          );
                                        }
                                        Navigator.of(context).pop();
                                      } catch (e) {
                                        Fluttertoast.showToast(
                                          msg: "An error occurred : $e",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red[700],
                                          textColor: Colors.white,
                                        );
                                        Navigator.of(context).pop();
                                        print('Error: $e');
                                      }
                                    },
                                    child: Text(
                                      'Add New Volunteer',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Close Button
                          Positioned(
                            right: 10,
                            top: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 20,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height:
                      MediaQuery.of(context).size.height * 0.4, // Fixed height
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          border: Border(
                            bottom:
                                BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            // Serial Number Header
                            Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                      color: Colors.grey[300]!, width: 1),
                                ),
                              ),
                              child: Text(
                                'Sr. No',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            // Volunteer Name Header
                            Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        color: Colors.grey[300]!, width: 1),
                                  ),
                                ),
                                child: Text(
                                  'Volunteers',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            // Present Header
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        color: Colors.grey[300]!, width: 1),
                                  ),
                                ),
                                child: Text(
                                  'Present',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            // Absent Header
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Absent',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      // Serial Number
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                                color: Colors.grey[300]!,
                                                width: 1),
                                          ),
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      // Volunteer Name
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1),
                                            ),
                                          ),
                                          child: Text(
                                            name!,
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Present Button
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1),
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.check,
                                              color: attendanceStatus[docId] ==
                                                      true
                                                  ? Colors.white
                                                  : Colors.green,
                                            ),
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  attendanceStatus[docId] ==
                                                          true
                                                      ? Colors.green
                                                      : Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                    color: Colors.green),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                attendanceStatus[docId!] = true;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      // Absent Button
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: attendanceStatus[docId] ==
                                                      false
                                                  ? Colors.white
                                                  : Colors.red,
                                            ),
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  attendanceStatus[docId] ==
                                                          false
                                                      ? Colors.red
                                                      : Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                    color: Colors.red),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                attendanceStatus[docId!] =
                                                    false;
                                              });
                                            },
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
                    ],
                  ),
                ),
                Padding(
                    padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
               
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        " For ${TodayDate.text} :",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                        TextField(
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.blue.shade800,
                            width: 2,
                          ),
                          ),
                          enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.blue.shade800,
                            width: 2,
                          ),
                          ),
                          focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.teal.shade700,
                            width: 2,
                          ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                          ),
                        ),
                        readOnly: true,
                        controller: TodayDate,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                          setState(() {
                            TodayDate.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                          });
                          }
                        },
                        
                    
        
                        
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (isTodayAttendanceMarked == 'No_Today_Entry' && TodayDate.text != DateTime.now().toString()) 
                                    ? Colors.blue
                                    : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (isTodayAttendanceMarked == 'No_Today_Entry' && TodayDate.text != DateTime.now().toString()) {
                              submitAttendance();
                            } else {
                              null;
                            }
                          },
                          child: AutoSizeText(
                            "Submit ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (isTodayAttendanceMarked == 'Yes_Today_Entry')
                                    ? Colors.redAccent
                                    : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (isTodayAttendanceMarked == 'Yes_Today_Entry') {
                              submitAttendance();
                            } else {
                              null;
                            }
                          },
                          child: AutoSizeText(
                            "Edit Attendance",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for background design
class _TopRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
