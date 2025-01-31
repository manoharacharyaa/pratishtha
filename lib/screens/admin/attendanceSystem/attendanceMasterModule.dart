import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/attendanceServices.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/storageServices.dart';
import 'package:pratishtha/widgets/customTextField.dart';

class AttendanceMasterModule extends StatefulWidget {
  final User? user;
  final String currentAcademicYear;
  const AttendanceMasterModule(
    this.user,
    this.currentAcademicYear, {
    super.key,
  });

  @override
  State<AttendanceMasterModule> createState() => _AttendanceMasterModule();
}

class _AttendanceMasterModule extends State<AttendanceMasterModule> {
  bool showTextBoxes = false;
  List<User> userList = [];
  late Future<List<User>> users;
  TextEditingController departmentNameController = TextEditingController();
  TextEditingController deptHeadorCoheadNameController =
      TextEditingController();

  TextEditingController departmentPersonUUidController =
      TextEditingController();
      

  final addkey = GlobalKey<FormState>();

  var db = DatabaseServices();
  var cs = StorageServices();
  var at = AttendaceServices();

  @override
  void initState() {
    users = db.getSakecUsers();
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
    List<User> filteredUser = [];

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
                      if (filteredUser.isEmpty) filteredUser = data;
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
                                        filteredUser = data
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
                                : filteredUser.length,
                            itemBuilder: (context, index) {
                              return searchController.text.isEmpty
                                  ? ListTile(
                                      title: Text(
                                          "${srch[index].firstName} ${srch[index].lastName}"),
                                      onTap: () {
                                        setState(() {
                                          departmentPersonUUidController.text =
                                              srch[index].uid!;
                                          deptHeadorCoheadNameController.text =
                                              "${srch[index].firstName} ${srch[index].lastName}";
                                        });
                                        Navigator.pop(context);
                                      },
                                    )
                                  : ListTile(
                                      title: Text(
                                          "${filteredUser[index].firstName} ${filteredUser[index].lastName}"),
                                      onTap: () {
                                        setState(() {
                                          departmentPersonUUidController.text =
                                              filteredUser[index].uid!;
                                          deptHeadorCoheadNameController.text =
                                              "${filteredUser[index].firstName} ${filteredUser[index].lastName}";
                                        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Page'),
      ),
      body: Column(
        children: [
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: deptHeadorCoheadNameController,
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
                    style: BorderStyle.solid, color: primaryColor, width: 2),
                color: Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Text(
                "Add Dept Details",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            onTap: widget.user!.role == 8
                ? () {
                    setState(() {
                      showTextBoxes = !showTextBoxes;
                    });
                  }
                : null, // No action for roles other than 8
          ),
          if (showTextBoxes) ...[
            Form(
              key: addkey,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: departmentNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter Dept Name',
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: deptHeadorCoheadNameController,
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
                      style: BorderStyle.solid, color: primaryColor, width: 2),
                  color: Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Add Dept Details",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              onTap: () async {
                try {
                  if (addkey.currentState!.validate()) {
                    String result = await at.addHeadorCohead(
                      widget.currentAcademicYear,
                      departmentNameController.text,
                      deptHeadorCoheadNameController.text,
                      departmentPersonUUidController.text,
                     
                    );

                    if (result == "Member Added" ||
                        result == "Member Updated") {
                      Fluttertoast.showToast(
                        msg: "Event Added Successfully",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[500],
                        textColor: Colors.black,
                        fontSize: 16.0,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Failed to add Details",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[300],
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
