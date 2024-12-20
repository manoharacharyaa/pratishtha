import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/interCollege.dart';
import 'package:pratishtha/services/interCollegeServices.dart';

class AdminInterCollegePage extends StatefulWidget {
  const AdminInterCollegePage({super.key});

  @override
  State<AdminInterCollegePage> createState() => _AdminInterCollegePageState();
}

class _AdminInterCollegePageState extends State<AdminInterCollegePage> {
  String? selectedCollege;

  final FocusNode _collegeNameFocusNode = FocusNode();
  final FocusNode _collegeShortNameFocusNode = FocusNode();
  final FocusNode _collegeLocationFocusNode = FocusNode();
  final FocusNode _collegeLogoFocusNode = FocusNode();
  final FocusNode _updatedScoreFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController collegeShortNameController =
      TextEditingController();
  final TextEditingController collegeLocationController =
      TextEditingController();
  final TextEditingController updatedScoreController = TextEditingController();

  File? _pickedImage;
  List<InterCollege> allCollegeList = [];

  @override
  void initState() {
    super.initState();
    Future.wait([
      InterCollegeServices().getAllCollegesInter(),
    ]).then((results) {
      setState(() {
        allCollegeList =
            results[0]; // Assuming results[0] is already a List<InterCollege>
        log("Printing all college list");
        log(allCollegeList
            .toString()); // Use toString() instead of type casting
      });
    }).catchError((error) {
      log("Error fetching colleges: $error");
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error picking image: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[700],
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
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
                                  'Colleges',
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
                                  'Score',
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
                                  'Edit Score',
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
                          itemCount: allCollegeList.length,
                          itemBuilder: (context, index) {
                            final college = allCollegeList[index];
                            final docId = college.id;
                            final name = college.collegeName;
                            final score = college.score;

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
                                      // College Name
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
                                            name,
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
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
                                            '$score', // Convert score to a string using string interpolation
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),

                                      // Absent Button
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.red,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize
                                                            .min, // This is the key change
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              // Main Content
                                                              Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                children: [
                                                                  Form(
                                                                    key:
                                                                        _formKey,
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              5),
                                                                      margin: EdgeInsets
                                                                          .all(
                                                                              10),
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            SizedBox(
                                                                              height: 40,
                                                                            ),
                                                                            Text(
                                                                              'Update College Score',
                                                                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 40,
                                                                            ),
                                                                            SizedBox(
                                                                              width: MediaQuery.of(context).size.width * 0.85,
                                                                              child: MyTextField(
                                                                                focusNode: _updatedScoreFocusNode, // Associate the FocusNode
                                                                                hinttext: 'Enter Updated Score',
                                                                                keyboard: TextInputType.number,
                                                                                obscuretext: false,
                                                                                controller: updatedScoreController,
                                                                                icon: Icon(
                                                                                  Icons.school_rounded,
                                                                                  color: headline2Color,
                                                                                ),
                                                                                validator: (value) {
                                                                                  if (value == null || value.isEmpty) {
                                                                                    return 'Please enter valid score';
                                                                                  }
                                                                                  return null;
                                                                                },
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 30,
                                                                            ),
                                                                            Material(
                                                                              elevation: 5,
                                                                              borderRadius: BorderRadius.circular(30),
                                                                              color: cardBackgroundColor,
                                                                              child: MaterialButton(
                                                                                minWidth: 275,
                                                                                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                                                onPressed: () async {
                                                                                  if (_formKey.currentState!.validate()) {
                                                                                    String result = await InterCollegeServices().updateCollege(
                                                                                      name,
                                                                                      docId,
                                                                                      updatedScoreController,
                                                                                    );

                                                                                    if (result != 'Failed to update score.') {
                                                                                      Fluttertoast.showToast(
                                                                                        msg: "$result",
                                                                                        toastLength: Toast.LENGTH_LONG,
                                                                                        gravity: ToastGravity.BOTTOM,
                                                                                        backgroundColor: Colors.green[700],
                                                                                        textColor: Colors.white,
                                                                                      );
                                                                                    }
                                                                                    Navigator.pop(context);
                                                                                    Navigator.pushReplacement(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                        builder: (context) => AdminInterCollegePage(),
                                                                                      ),
                                                                                    );
                                                                                  } else {
                                                                                    Fluttertoast.showToast(
                                                                                      msg: "Failed to update score",
                                                                                      toastLength: Toast.LENGTH_LONG,
                                                                                      gravity: ToastGravity.BOTTOM,
                                                                                      backgroundColor: Colors.red[700],
                                                                                      textColor: Colors.white,
                                                                                    );
                                                                                    Navigator.pop(context);
                                                                                  }
                                                                                },
                                                                                child: Text(
                                                                                  'UPDATE',
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize: 15,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 30,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              // Close Button
                                                              Positioned(
                                                                right: 10,
                                                                top: 10,
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  radius: 20,
                                                                  child:
                                                                      IconButton(
                                                                    icon: Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: Colors
                                                                            .white),
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (index < allCollegeList.length - 1)
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize:
                                    MainAxisSize.min, // This is the key change
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Stack(
                                    children: [
                                      // Main Content
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Form(
                                            key: _formKey,
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              margin: EdgeInsets.all(10),
                                              // decoration: BoxDecoration(
                                              //   color: primaryColor,
                                              //   borderRadius:
                                              //       BorderRadius.circular(10),
                                              // ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      height: 40,
                                                    ),
                                                    Text(
                                                      'Add College',
                                                      style: TextStyle(
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                    SizedBox(
                                                      height: 40,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                      child: MyTextField(
                                                        focusNode:
                                                            _collegeNameFocusNode, // Associate the FocusNode
                                                        hinttext:
                                                            'Enter College Name',
                                                        keyboard:
                                                            TextInputType.text,
                                                        obscuretext: false,
                                                        controller:
                                                            collegeNameController,
                                                        icon: Icon(
                                                          Icons.school_rounded,
                                                          color: headline2Color,
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter college name';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                      child: MyTextField(
                                                        focusNode:
                                                            _collegeShortNameFocusNode,
                                                        hinttext:
                                                            'Enter College Short Name',
                                                        keyboard: TextInputType
                                                            .number,
                                                        obscuretext: false,
                                                        controller:
                                                            collegeShortNameController,
                                                        icon: Icon(
                                                          Icons.score,
                                                          color: headline2Color,
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter college short name';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                      child: MyTextField(
                                                        focusNode:
                                                            _collegeLocationFocusNode,
                                                        hinttext:
                                                            'Enter College Location',
                                                        keyboard: TextInputType
                                                            .number,
                                                        obscuretext: false,
                                                        controller:
                                                            collegeLocationController,
                                                        icon: Icon(
                                                          Icons.location_city,
                                                          color: headline2Color,
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter college location';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                      child: GestureDetector(
                                                        onTap: _pickImage,
                                                        child: AbsorbPointer(
                                                          child: MyTextField(
                                                            hinttext:
                                                                'Enter College Logo',
                                                            obscuretext: false,
                                                            controller:
                                                                TextEditingController(
                                                              text: _pickedImage !=
                                                                      null
                                                                  ? _pickedImage!
                                                                      .path
                                                                      .split(
                                                                          '/')
                                                                      .last
                                                                  : '',
                                                            ),
                                                            icon: Icon(
                                                              Icons.upload_file,
                                                              color:
                                                                  headline2Color,
                                                            ),
                                                            validator: (value) {
                                                              if (_pickedImage ==
                                                                  null) {
                                                                return 'Please enter a logo';
                                                              }
                                                              return null;
                                                            },
                                                            focusNode:
                                                                _collegeLogoFocusNode,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (_pickedImage != null)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Image.file(
                                                          _pickedImage!,
                                                          height: 100,
                                                          width: 100,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                    Material(
                                                      elevation: 5,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      color:
                                                          cardBackgroundColor,
                                                      child: MaterialButton(
                                                        minWidth: 275,
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                20, 15, 20, 15),
                                                        onPressed: () async {
                                                          if (_formKey
                                                              .currentState!
                                                              .validate()) {
                                                            String result =
                                                                await InterCollegeServices()
                                                                    .addCollegeForInter(
                                                              collegeNameController
                                                                  .text,
                                                              collegeShortNameController
                                                                  .text,
                                                              collegeLocationController
                                                                  .text,
                                                              _pickedImage!,
                                                            );

                                                            if (result ==
                                                                'Success') {
                                                              Fluttertoast
                                                                  .showToast(
                                                                msg:
                                                                    "College added successfully",
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                backgroundColor:
                                                                    Colors.green[
                                                                        700],
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                              );
                                                            }
                                                            Navigator.pop(
                                                                context);
                                                          } else {
                                                            Fluttertoast
                                                                .showToast(
                                                              msg:
                                                                  "Failed to add college",
                                                              toastLength: Toast
                                                                  .LENGTH_LONG,
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM,
                                                              backgroundColor:
                                                                  Colors
                                                                      .red[700],
                                                              textColor:
                                                                  Colors.white,
                                                            );
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        child: Text(
                                                          'SUBMIT',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Close Button
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 20,
                                          child: IconButton(
                                            icon: Icon(Icons.close,
                                                color: Colors.white),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      "Submit Attendance",
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
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
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
          )
        ],
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final FocusNode focusNode;
  final String hinttext;
  final bool obscuretext;
  final TextEditingController controller;
  final TextInputType keyboard;
  final Icon icon;
  final String? Function(String?)? validator;

  const MyTextField({
    Key? key,
    required this.hinttext,
    required this.obscuretext,
    required this.controller,
    required this.icon,
    required this.validator,
    this.keyboard = TextInputType.text,
    required this.focusNode, // Provide a default value for keyboard
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      keyboardType: keyboard,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 4),
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: hinttext,
        prefixIcon: icon,
      ),
      obscureText: obscuretext,
      validator: validator,
    );
  }
}
