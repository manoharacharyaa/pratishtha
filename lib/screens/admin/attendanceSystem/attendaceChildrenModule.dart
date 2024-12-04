import 'package:flutter/material.dart';
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
  TextEditingController volunteerNameController = TextEditingController();
  TextEditingController volunteerClassDivController = TextEditingController();
  TextEditingController volunteerRollNoController = TextEditingController();
  TextEditingController volunteerBranchController = TextEditingController();
  TextEditingController volunteerPRNController = TextEditingController();
  TextEditingController volunteerSakecmailCOntroller = TextEditingController();

  List<String> branchList = ['Comps','IT','EXTC','CYSE','AIDS'];

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
                            padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                                            .contains(query.toLowerCase()) ||
                                            user.lastName!
                                                .toLowerCase()
                                                .contains(query.toLowerCase()))
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
                                          .contains(query.toLowerCase()) ||
                                          user.lastName!
                                              .toLowerCase()
                                              .contains(query.toLowerCase()))
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
                                      volunteerNameController.text = "${filteredData[index].firstName} ${filteredData[index].lastName}";
                                      volunteerSakecmailCOntroller.text = filteredData[index].sakecId;
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: volunteerNameController,
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
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextField(
                            controller: volunteerClassDivController,
                            decoration: InputDecoration(
                              labelText: 'Enter Class-Div',
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
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextField(
                            controller: volunteerRollNoController,
                            decoration: InputDecoration(
                              labelText: 'Enter Roll No',
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
                      ),
                    ],
                  ),
                  // Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      value: volunteerBranchController.text, // Set initial value
                      items: branchList
                          .map((value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          volunteerBranchController.text = value!; // Update controller
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Branch',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.blue, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                        ),
                      ),
                      hint: Text("Select Branch"), // Show when no value is selected
                    ),
                  ),
                  // PRN Input
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  border:
                  Border.all(style: BorderStyle.solid, color: primaryColor),
                  color: Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Add New Volunteer",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              onTap: () async {
                try {
                  if (addkey.currentState!.validate()) {
                    // Add new volunteer cha code :
                  }else {
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