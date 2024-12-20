// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:uuid/uuid.dart';

import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/services/interCollegeServices.dart';

class AddCollege extends StatefulWidget {
  const AddCollege({super.key});

  @override
  State<AddCollege> createState() => _AddCollegeState();
}

class _AddCollegeState extends State<AddCollege> {
  String? selectedCollege;

  final FocusNode _collegeFocusNode = FocusNode();
  final FocusNode _scoreFocusNode = FocusNode();
  final FocusNode _updatedscoreFocusNode = FocusNode();

  MultiSelectController _controller =
      MultiSelectController(); // Assuming you have a MultiS

  Future<String?> getCollegeIdByName(String? collegeName) async {
    try {
      // Perform a query to find the document ID based on the college name
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(
              'colleges') // Replace 'your_collection' with your actual Firestore collection name
          .where('collegeName', isEqualTo: collegeName)
          .get();

      // Check if any documents were found
      if (querySnapshot.docs.isNotEmpty) {
        // Return the document ID of the first matching document
        return querySnapshot.docs.first.id;
      } else {
        // Handle the case where no matching document was found
        print('No document found for college: $collegeName');
        return null;
      }
    } catch (e) {
      // Handle any errors that may occur during the query
      print('Error getting college ID: $e');
      return null;
    }
  }

  Future<List<String>> fetchColleges() async {
    List<String> colleges = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('colleges').get();

      querySnapshot.docs.forEach((doc) {
        colleges.add(doc['collegeName']);
      });
    } catch (e) {
      print('Error fetching colleges: $e');
    }

    return colleges;
  }

  Future<List<ValueItem>> getUserNamesFromFirestore() async {
    List<ValueItem> names = [];
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    querySnapshot.docs.forEach((doc) {
      String name = doc.data()['email'];
      String id = doc.id;
      names.add(ValueItem(label: name, value: id));
    });
    return names;
  }

  Future<void> addCollege() async {
    try {
      String UniqueCode = Uuid().v4().substring(0, 6); // Unique Code
      final CollectionReference collegecoll =
          FirebaseFirestore.instance.collection('colleges');

      // Check if the participant and team fields are empty and set values accordingly
      List<String> participantsList = participantcontroller.text.isEmpty
          ? []
          : participantcontroller.text.split(',').map((e) => e.trim()).toList();

      List<String> teamsList = teamcontroller.text.isEmpty
          ? []
          : teamcontroller.text.split(',').map((e) => e.trim()).toList();

      // Add the document without the ID
      DocumentReference docRef = await collegecoll.add({
        'unique_code': UniqueCode,
        'collegeName': collegecontroller.text,
        'participants': participantsList,
        'teams': teamsList,
        'soft_delete': false,
        'score': int.parse(scorecontroller.text), // Because score is numeric
      });

      // Get the ID of the added document
      String docId = docRef.id;

      // Update the document with the ID
      await docRef.update({'id': docId});

      // Clear text fields after successful submission
      collegecontroller.clear();
      participantcontroller.clear();
      teamcontroller.clear();
      scorecontroller.clear();

      // Optionally show a success message or navigate to another screen
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Success'),
            content: Text('College added successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error adding college: $e');
      // Handle errors, e.g., show an error message
      // Show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add college. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> updateCollege() async {
    // Parse the entered score
    int scoreChange = int.tryParse(updatedscorecontroller.text) ?? 0;

    // Get the selected college ID
    String? selectedCollegeId = await getCollegeIdByName(selectedCollege);

    // Fetch the current score from Firestore
    DocumentSnapshot collegeDoc = await FirebaseFirestore.instance
        .collection('colleges')
        .doc(selectedCollegeId)
        .get();

    // Perform addition or subtraction
    int currentScore = collegeDoc['score'];
    int newScore = currentScore + scoreChange;

    if (newScore < 0) {
      newScore = 0;
    }

    // Update the score in Firestore
    await FirebaseFirestore.instance
        .collection('colleges')
        .doc(selectedCollegeId)
        .update({
      'score': newScore,
    });

    // Update the UI if needed
    setState(() {
      // Update the state variables here
      updatedscorecontroller.clear();
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController collegecontroller = TextEditingController();
  final TextEditingController participantcontroller = TextEditingController();
  final TextEditingController teamcontroller = TextEditingController();
  final TextEditingController scorecontroller = TextEditingController();
  final TextEditingController updatedscorecontroller = TextEditingController();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController collegeShortNameController =
      TextEditingController();
  final TextEditingController collegeLocation = TextEditingController();

  File? _pickedImage;

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: dullGreyColor,
                        blurRadius: 20,
                      )
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Add College',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: MyTextField(
                          focusNode:
                              _collegeFocusNode, // Associate the FocusNode
                          hinttext: 'Enter College Name',
                          keyboard: TextInputType.text,
                          obscuretext: false,
                          controller: collegecontroller,
                          icon: Icon(
                            Icons.school_rounded,
                            color: headline2Color,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                      ),
                      // SizedBox(
                      //   height: 30,
                      // ),

                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width * 0.90,
                      //   child: FutureBuilder<List<ValueItem>>(
                      //     future: getUserNamesFromFirestore(),
                      //     builder: (context, snapshot) {
                      //       if (snapshot.connectionState == ConnectionState.waiting) {
                      //         return CircularProgressIndicator();
                      //       } else if (snapshot.hasError) {
                      //         return Text('Error: ${snapshot.error}');
                      //       } else {
                      //         List<ValueItem> options = snapshot.data!;
                      //         return Column(
                      //           children: [
                      //             Padding(
                      //               padding: const EdgeInsets.symmetric(horizontal: 10),
                      //               child: MultiSelectDropDown(
                      //                 searchEnabled: options.length > 10,
                      //                 showClearIcon: true,
                      //                 controller: _controller,
                      //                 onOptionSelected: (options) {
                      //                   debugPrint(options.toString());
                      //                 },
                      //                 options: options,
                      //                 maxItems: 3,
                      //                 dropdownHeight: 300,
                      //                 chipConfig: ChipConfig(wrapType: WrapType.wrap),
                      //                 optionTextStyle: const TextStyle(fontSize: 16),
                      //                 selectedOptionIcon: const Icon(Icons.check_circle),
                      //               ),
                      //             ),
                      //           ],
                      //         );
                      //       }
                      //     },
                      //   ),
                      // ),

                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width * 0.85,
                      //   child: MyTextField(
                      //     hinttext: 'Enter Participants',
                      //     keyboard: TextInputType.text,
                      //     obscuretext: false,
                      //     controller: participantcontroller,
                      //     icon: Icon(Icons.people_outline_sharp,
                      //         color: headline2Color),
                      //     validator: (value) {
                      //       if (value == null || value.isEmpty) {
                      //         return null;
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: MyTextField(
                          focusNode: _scoreFocusNode,
                          hinttext: 'Enter College Short Name',
                          keyboard: TextInputType.number,
                          obscuretext: false,
                          controller: scorecontroller,
                          icon: Icon(
                            Icons.score,
                            color: headline2Color,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a short name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: MyTextField(
                          focusNode: _scoreFocusNode,
                          hinttext: 'Enter College Location',
                          keyboard: TextInputType.number,
                          obscuretext: false,
                          controller: scorecontroller,
                          icon: Icon(
                            Icons.score,
                            color: headline2Color,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a location';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: FutureBuilder<List<String>>(
                          future: fetchColleges(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(); // or any loading indicator
                            } else if (snapshot.hasError) {
                              return Text('Error loading colleges');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text('No colleges available');
                            } else {
                              List<String>? colleges = snapshot.data;

                              return DropdownButtonFormField(
                                style: TextStyle(
                                  color: Colors.black, // Set text color
                                  fontSize: 16.0, // Set text size
                                ),
                                elevation:
                                    8, // Set elevation for the dropdown menu
                                dropdownColor: Colors
                                    .white, // Set background color for the dropdown menu
                                focusColor: Colors.white,
                                icon: Icon(
                                  Icons
                                      .arrow_drop_down, // Customize the dropdown icon
                                  color: Colors.black,
                                ),

                                items: colleges?.map((String college) {
                                  return DropdownMenuItem(
                                    value: college,
                                    child: Text(college),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  // Handle the selected college
                                  print('Selected College: $value');

                                  selectedCollege =
                                      value; // Update the selectedCollege variable
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  hintText: 'Select your College',
                                  prefixIcon: Icon(
                                    FontAwesomeIcons.university,
                                    color: headline2Color,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                                validator: null,
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: MyTextField(
                          focusNode: _updatedscoreFocusNode,
                          hinttext: 'Enter Score',
                          keyboard: TextInputType.number,
                          obscuretext: false,
                          controller: updatedscorecontroller,
                          icon: Icon(
                            Icons.score,
                            color: headline2Color,
                          ),
                          validator: null,
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
                          onPressed: () {
                            updateCollege();
                          },
                          child: Text(
                            'Submit',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
    required this.focusNode,
    required this.hinttext,
    required this.obscuretext,
    required this.controller,
    this.keyboard = TextInputType.text,
    required this.icon,
    required this.validator,
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
