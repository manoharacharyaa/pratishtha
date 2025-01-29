import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/interCollege.dart';
import 'package:pratishtha/services/interCollegeServices.dart';
import 'package:pratishtha/widgets/customTextField.dart';

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
  late List<InterCollege> allCollegeList = [];

  TextEditingController teamANameController = TextEditingController();
  TextEditingController teamBNameController = TextEditingController();
  TextEditingController teamALocationController = TextEditingController();
  TextEditingController teamBLocationController = TextEditingController();
  TextEditingController teamAScoreController = TextEditingController();
  TextEditingController teamBScoreController = TextEditingController();
  TextEditingController teamALogoUrlController = TextEditingController();
  TextEditingController teamBLogoUrlController = TextEditingController();
  TextEditingController teamADocIdController = TextEditingController();
  TextEditingController teamBDocIdController = TextEditingController();

  TextEditingController matchTypeController = TextEditingController();
  TextEditingController matchDayDateController = TextEditingController();
  TextEditingController matchLocationController = TextEditingController();
  TextEditingController matchTimeController = TextEditingController();

  TextEditingController teamABestPlayer1Controller = TextEditingController();
  TextEditingController teamABestPlayer2Controller = TextEditingController();
  TextEditingController teamBBestPlayer1Controller = TextEditingController();
  TextEditingController teamBBestPlayer2Controller = TextEditingController();

  String selectedSport = '';
  List<String> sportsList = [
    'Cricket',
    'Football',
    'Kabaddi',
    'Volleyball(Girls)',
    'Volleyball(Boys)',
    'BasketBall',
    'Tug of War',
    'chess',
    'Carrom',
    'Table Tennis',
    'powerLifting',
  ];
  GlobalKey<FormState> addMatchKey = GlobalKey();

  late Future<List<InterCollege>> colleges;
  var ic = InterCollegeServices();

  @override
  void initState() {
    super.initState();
    // Initialize the Future that FutureBuilder will use
    colleges = InterCollegeServices().getAllCollegesInter();

    // If you still want to keep allCollegeList updated
    colleges.then((results) {
      setState(() {
        allCollegeList = results;
        log("Printing all college list");
        log(allCollegeList.toString());
      });
    }).catchError((error) {
      log("Error fetching colleges: $error");
    });
  }

  Widget _buildAnimatedTextFieldWithSuggestions({
    required TextEditingController controller,
    required String labelText,
    required List<String> suggestions, // Use a list of suggestions
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          // Return suggestions that include the input text
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return suggestions.where((suggestion) => suggestion
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase()));
        },
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
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
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          );
        },
        onSelected: (String selectedSuggestion) {
          controller.text = selectedSuggestion;
        },
      ),
    );
  }

  void openUserSelectionModalCollege1(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<InterCollege> filteredData = [];

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
                child: FutureBuilder<List<InterCollege>>(
                  future: colleges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      List<InterCollege> data = snapshot.data!;
                      List<InterCollege> srch = [];
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
                                    hintText: 'Enter College Name',
                                    labelText: 'Enter College Name',
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        filteredData = data
                                            .where((college) => college
                                                .collegeName
                                                .toLowerCase()
                                                .contains(
                                                  value.toLowerCase(),
                                                ))
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
                              InterCollege selectedCollege =
                                  searchController.text.isEmpty
                                      ? srch[index]
                                      : filteredData[index];

                              return ListTile(
                                title: Text("${selectedCollege.collegeName}"),
                                onTap: () {
                                  teamANameController.text =
                                      selectedCollege.collegeShortName;
                                  teamADocIdController.text =
                                      selectedCollege.id;
                                  teamALogoUrlController.text =
                                      selectedCollege.imageUrl;
                                  teamALocationController.text =
                                      selectedCollege.collegeLocation;
                                  Navigator.pop(context);
                                  print(
                                      "${teamANameController.text} + ${teamADocIdController.text} + ${teamALogoUrlController.text}");
                                },
                              );
                            },
                          )),
                        ],
                      );
                    } else {
                      return Center(child: Text('No colleges available'));
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

  void openUserSelectionModalCollege2(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<InterCollege> filteredData = [];

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
                child: FutureBuilder<List<InterCollege>>(
                  future: colleges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      List<InterCollege> data = snapshot.data!;
                      List<InterCollege> srch = [];
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
                                    hintText: 'Enter College Name',
                                    labelText: 'Enter College Name',
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        filteredData = data
                                            .where((college) => college
                                                .collegeName
                                                .toLowerCase()
                                                .contains(
                                                  value.toLowerCase(),
                                                ))
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
                              InterCollege selectedCollege =
                                  searchController.text.isEmpty
                                      ? srch[index]
                                      : filteredData[index];

                              return ListTile(
                                title: Text("${selectedCollege.collegeName}"),
                                onTap: () {
                                  teamBNameController.text =
                                      selectedCollege.collegeShortName;
                                  teamBDocIdController.text =
                                      selectedCollege.id;
                                  teamBLocationController.text =
                                      selectedCollege.collegeLocation;
                                  teamBLogoUrlController.text =
                                      selectedCollege.imageUrl;
                                  Navigator.pop(context);
                                },
                              );
                            },
                          )),
                        ],
                      );
                    } else {
                      return Center(child: Text('No colleges available'));
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

  final List<String> suggestions = ['semi-final', 'final', 'quarter final','Group Stage - M(num)'];

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
                          return StatefulBuilder(
                            builder: (context, setStateDialog) {
                              return Dialog(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize
                                        .min, // This is the key change
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        SizedBox(
                                                          height: 40,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                          child: MyTextField(
                                                            focusNode:
                                                                _collegeNameFocusNode, // Associate the FocusNode
                                                            hinttext:
                                                                'Enter College Name',
                                                            keyboard:
                                                                TextInputType
                                                                    .text,
                                                            obscuretext: false,
                                                            controller:
                                                                collegeNameController,
                                                            icon: Icon(
                                                              Icons
                                                                  .school_rounded,
                                                              color:
                                                                  headline2Color,
                                                            ),
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
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
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                          child: MyTextField(
                                                            focusNode:
                                                                _collegeShortNameFocusNode,
                                                            hinttext:
                                                                'Enter College Short Name',
                                                            keyboard:
                                                                TextInputType
                                                                    .number,
                                                            obscuretext: false,
                                                            controller:
                                                                collegeShortNameController,
                                                            icon: Icon(
                                                              Icons.score,
                                                              color:
                                                                  headline2Color,
                                                            ),
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
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
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                          child: MyTextField(
                                                            focusNode:
                                                                _collegeLocationFocusNode,
                                                            hinttext:
                                                                'Enter College Location',
                                                            keyboard:
                                                                TextInputType
                                                                    .number,
                                                            obscuretext: false,
                                                            controller:
                                                                collegeLocationController,
                                                            icon: Icon(
                                                              Icons
                                                                  .location_city,
                                                              color:
                                                                  headline2Color,
                                                            ),
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
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
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              await _pickImage();
                                                              setStateDialog(
                                                                  () {});
                                                            },
                                                            child:
                                                                AbsorbPointer(
                                                              child:
                                                                  MyTextField(
                                                                hinttext:
                                                                    'Enter College Logo',
                                                                obscuretext:
                                                                    false,
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
                                                                  Icons
                                                                      .upload_file,
                                                                  color:
                                                                      headline2Color,
                                                                ),
                                                                validator:
                                                                    (value) {
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
                                                        if (_pickedImage !=
                                                            null)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10),
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
                                                              BorderRadius
                                                                  .circular(30),
                                                          color:
                                                              cardBackgroundColor,
                                                          child: MaterialButton(
                                                            minWidth: 275,
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    20,
                                                                    15,
                                                                    20,
                                                                    15),
                                                            onPressed:
                                                                () async {
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
                                                                    toastLength:
                                                                        Toast
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
                                                                      Colors.red[
                                                                          700],
                                                                  textColor:
                                                                      Colors
                                                                          .white,
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
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                      );
                    },
                    child: Text(
                      "Add College",
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
                  // child: ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.redAccent,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //   ),
                  //   onPressed: () {},
                  //   child: Text(
                  //     "Add Match",
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Title
                                          Center(
                                            child: Text(
                                              'Add New Match',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),

                                          // Form
                                          SingleChildScrollView(
                                            child: Form(
                                              key: addMatchKey,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Sport Select Dropdown
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        border: Border.all(
                                                            color: Colors
                                                                .deepPurple
                                                                .shade200),
                                                      ),
                                                      child:
                                                          DropdownButtonFormField<
                                                              String>(
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          5),
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        value:
                                                            sportsList.contains(
                                                                    selectedSport)
                                                                ? selectedSport
                                                                : null,
                                                        items: sportsList
                                                            .map((value) =>
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value: value,
                                                                  child: Text(
                                                                      value),
                                                                ))
                                                            .toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedSport =
                                                                value!;
                                                          });
                                                          print(selectedSport);
                                                        },
                                                        hint: Text(
                                                          "Select Sport",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // Member Selection 1
                                                  _buildAnimatedTextField(
                                                    controller:
                                                        teamANameController,
                                                    labelText: selectedSport ==
                                                            'Cricket'
                                                        ? 'Select Team Batting First'
                                                        : 'Select Team A',
                                                    readOnly: true,
                                                    onTap: () =>
                                                        openUserSelectionModalCollege1(
                                                            context),
                                                  ),

                                                  // Member Selection 1
                                                  _buildAnimatedTextField(
                                                    controller:
                                                        teamBNameController,
                                                    labelText: selectedSport ==
                                                            'Cricket'
                                                        ? 'Select Team Batting Second'
                                                        : 'Select Team B',
                                                    readOnly: true,
                                                    onTap: () =>
                                                        openUserSelectionModalCollege2(
                                                            context),
                                                  ),

                                                  // Team A,B Score Input
                                                  _buildAnimatedTextField(
                                                    controller:
                                                        teamAScoreController,
                                                    labelText: selectedSport ==
                                                            'Cricket'
                                                        ? 'Enter Team A Score Eg. 137/8'
                                                        : 'Enter Team A Points / Goals',
                                                  ),
                                                  _buildAnimatedTextField(
                                                    controller:
                                                        teamBScoreController,
                                                    labelText: selectedSport ==
                                                            'Cricket'
                                                        ? 'Enter Team B Score Eg. 137/8'
                                                        : 'Enter Team B Points / Goals',
                                                  ),

                                                  // Match Type, Location, DayDate, Time
                                                  Row(
                                                    children: [
                                                        Expanded(
                                                        child: _buildAnimatedTextFieldWithSuggestions(
                                                          controller: matchTypeController,
                                                          labelText: 'Enter Match Type (Group Stage - M(num), QF, SF, Final)',
                                                          suggestions: suggestions,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child:
                                                            _buildAnimatedTextField(
                                                          controller:
                                                              matchLocationController,
                                                          labelText:
                                                              'Enter Match Location',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      // Date Picker
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            final DateTime?
                                                                pickedDate =
                                                                await showDatePicker(
                                                              context: context,
                                                              initialDate:
                                                                  DateTime
                                                                      .now(),
                                                              firstDate:
                                                                  DateTime(
                                                                      2000),
                                                              lastDate:
                                                                  DateTime(
                                                                      2100),
                                                            );

                                                            if (pickedDate !=
                                                                null) {
                                                              final formattedDate =
                                                                  DateFormat(
                                                                          'EEE, dd MMM yyyy')
                                                                      .format(
                                                                          pickedDate);
                                                              setState(() {
                                                                matchDayDateController
                                                                        .text =
                                                                    formattedDate;
                                                              });
                                                            }
                                                          },
                                                          child:
                                                              _buildAnimatedTextField(
                                                            controller:
                                                                matchDayDateController,
                                                            labelText:
                                                                'Select Match Date',
                                                            readOnly: false,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
// Time Picker
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            final TimeOfDay?
                                                                pickedTime =
                                                                await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now(),
                                                            );

                                                            if (pickedTime !=
                                                                null) {
                                                              final formattedTime =
                                                                  pickedTime
                                                                      .format(
                                                                          context);
                                                              setState(() {
                                                                matchTimeController
                                                                        .text =
                                                                    formattedTime;
                                                              });
                                                            }
                                                          },
                                                          child:
                                                              _buildAnimatedTextField(
                                                            controller:
                                                                matchTimeController,
                                                            labelText:
                                                                'Select Match Start Time',
                                                            readOnly: false,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                    ],
                                                  ),

                                                  //Team A, B Top Players
                                                  _buildAnimatedTextField(
                                                    controller:
                                                        teamABestPlayer1Controller,
                                                    labelText: selectedSport ==
                                                            'Cricket'
                                                        ? 'Enter Team A Top Scorer'
                                                        : selectedSport ==
                                                                'Football'
                                                            ? 'Enter Team A Top GoalScorer'
                                                            : selectedSport ==
                                                                    'Kabaddi'
                                                                ? 'Enter Team A Top Raider'
                                                                : 'Enter Team A Top Player / Null',
                                                  ),
                                                  _buildAnimatedTextField(
                                                    controller:
                                                        teamABestPlayer2Controller,
                                                    labelText: selectedSport ==
                                                            'Cricket'
                                                        ? 'Enter Team A Top Bowler'
                                                        : selectedSport ==
                                                                'Kabaddi'
                                                            ? 'Enter Team A Top Defender '
                                                            : 'Leave this',
                                                  ),

                                                  _buildAnimatedTextField(
                                                    controller:
                                                        teamBBestPlayer1Controller,
                                                    labelText: selectedSport ==
                                                            'Cricket'
                                                        ? 'Enter Team B Top Scorer'
                                                        : selectedSport ==
                                                                'Football'
                                                            ? 'Enter Team B Top GoalScorer'
                                                            : selectedSport ==
                                                                    'Kabaddi'
                                                                ? 'Enter Team B Top Raider'
                                                                : 'Enter Team B Top Player / Null',
                                                  ),
                                                  _buildAnimatedTextField(
                                                    controller:
                                                        teamBBestPlayer2Controller,
                                                    labelText: selectedSport ==
                                                            'Cricket'
                                                        ? 'Enter Team B Top Bowler'
                                                        : selectedSport ==
                                                                'Kabaddi'
                                                            ? 'Enter Team B Top Defender '
                                                            : 'Leave this',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          SizedBox(height: 20),

                                          // Add Volunteer Button
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blue.shade800,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 15),
                                            ),
                                            onPressed: () async {
                                              if (selectedSport == 'Cricket') {
                                                try {
                                                  if (addMatchKey.currentState!
                                                      .validate()) {
                                                    String result = await InterCollegeServices().recordCricketMatch(
                                                        academicYear:
                                                            "2024-2025",
                                                        matchLocation:
                                                            matchLocationController
                                                                .text,
                                                        teamBattingFirstLocation:
                                                            teamALocationController
                                                                .text,
                                                        teamBattingSecondLocation:
                                                            teamBLocationController
                                                                .text,
                                                        matchType:
                                                            matchTypeController
                                                                .text,
                                                        matchTime:
                                                            matchTimeController
                                                                .text,
                                                        matchDayDate:
                                                            matchDayDateController
                                                                .text,
                                                        teamBattingFirst:
                                                            teamANameController
                                                                .text,
                                                        teamBattingSecond:
                                                            teamBNameController
                                                                .text,
                                                        teamBattingFirstScore:
                                                            teamAScoreController
                                                                .text,
                                                        teamBattingSecondScore:
                                                            teamBScoreController.text,
                                                        teamBattingFirstTopBatter: teamABestPlayer1Controller.text,
                                                        teamBattingFirstTopBowlerPerformance: teamABestPlayer2Controller.text,
                                                        teamBattingSecondTopBatter: teamBBestPlayer1Controller.text,
                                                        teamBattingSecondTopBowlerPerformance: teamBBestPlayer2Controller.text,
                                                        teamBattingFirstLogoUrl: teamALogoUrlController.text,
                                                        teamBattingSecondLogoUrl: teamBLogoUrlController.text,
                                                        teamBattingFirstId: teamADocIdController.text,
                                                        teamBattingSecondId: teamBDocIdController.text);

                                                    if (result ==
                                                        'Cricket Match Record Added Successfully') {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Cricket Match Added Successfully",
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        backgroundColor:
                                                            Colors.green[700],
                                                        textColor: Colors.white,
                                                      );
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Failed to add Cricket Match)",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      backgroundColor:
                                                          Colors.red[700],
                                                      textColor: Colors.white,
                                                    );
                                                  }
                                                  Navigator.of(context).pop();
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "An error occurred: $e",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.red[700],
                                                    textColor: Colors.white,
                                                  );
                                                  Navigator.of(context).pop();
                                                  print('Error: $e');
                                                }
                                              } else if (selectedSport ==
                                                  'Football') {
                                                try {
                                                  if (addMatchKey.currentState!
                                                      .validate()) {
                                                    String result = await InterCollegeServices().recordFootballMatch(
                                                        academicYear:
                                                            "2024-2025",
                                                        matchLocation:
                                                            matchLocationController
                                                                .text,
                                                        matchType: matchTypeController
                                                            .text,
                                                        teamALocation:
                                                            teamALocationController
                                                                .text,
                                                        teamBLocation:
                                                            teamBLocationController
                                                                .text,
                                                        matchTime: matchTimeController
                                                            .text,
                                                        matchDayDate:
                                                            matchDayDateController
                                                                .text,
                                                        teamAName:
                                                            teamANameController
                                                                .text,
                                                        teamBName:
                                                            teamBNameController
                                                                .text,
                                                        teamAScore:
                                                            teamAScoreController
                                                                .text,
                                                        teamBScore:
                                                            teamBScoreController
                                                                .text,
                                                        teamATopGoalScorer:
                                                            teamABestPlayer1Controller
                                                                .text,
                                                        teamBTopGoalScorer:
                                                            teamBBestPlayer1Controller.text,
                                                        teamALogoUrl: teamALogoUrlController.text,
                                                        teamBLogoUrl: teamBLogoUrlController.text,
                                                        teamAId: teamADocIdController.text,
                                                        teamBId: teamBDocIdController.text);

                                                    if (result ==
                                                        'Football Match Record Added Successfully') {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Football Match Added Successfully",
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        backgroundColor:
                                                            Colors.green[700],
                                                        textColor: Colors.white,
                                                      );
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Failed to add Football Match)",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      backgroundColor:
                                                          Colors.red[700],
                                                      textColor: Colors.white,
                                                    );
                                                  }
                                                  Navigator.of(context).pop();
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "An error occurred: $e",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.red[700],
                                                    textColor: Colors.white,
                                                  );
                                                  Navigator.of(context).pop();
                                                  print('Error: $e');
                                                }
                                              } else if (selectedSport ==
                                                  'Kabaddi') {
                                                try {
                                                  int teamAPoints = int.tryParse(
                                                          teamAScoreController
                                                              .text) ??
                                                      0; // Default to 0 if parsing fails
                                                  int teamBPoints = int.tryParse(
                                                          teamBScoreController
                                                              .text) ??
                                                      0; // Default to 0 if parsing fails
                                                  if (addMatchKey.currentState!
                                                      .validate()) {
                                                    String result = await InterCollegeServices().recordKabaddiMatch(
                                                        academicYear:
                                                            "2024-2025",
                                                        matchLocation:
                                                            matchLocationController
                                                                .text,
                                                        matchType: matchTypeController
                                                            .text,
                                                        matchTime: matchTimeController
                                                            .text,
                                                        matchDayDate:
                                                            matchDayDateController
                                                                .text,
                                                        teamAName: teamANameController
                                                            .text,
                                                        teamBName:
                                                            teamBNameController
                                                                .text,
                                                        teamALocation:
                                                            teamALocationController
                                                                .text,
                                                        teamBLocation:
                                                            teamBLocationController
                                                                .text,
                                                        teamAPoints:
                                                            teamAPoints,
                                                        teamBPoints:
                                                            teamBPoints,
                                                        teamATopRaider:
                                                            teamABestPlayer1Controller
                                                                .text,
                                                        teamATopDefender:
                                                            teamABestPlayer2Controller
                                                                .text,
                                                        teamBTopRaider:
                                                            teamBBestPlayer1Controller
                                                                .text,
                                                        teamBTopDefender:
                                                            teamBBestPlayer2Controller.text,
                                                        teamALogoUrl: teamALogoUrlController.text,
                                                        teamBLogoUrl: teamBLogoUrlController.text,
                                                        teamAId: teamADocIdController.text,
                                                        teamBId: teamBDocIdController.text);

                                                    if (result ==
                                                        'Kabaddi Match Record Added Successfully') {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Kabaddi Match Added Successfully",
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        backgroundColor:
                                                            Colors.green[700],
                                                        textColor: Colors.white,
                                                      );
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Failed to add Kabaddi Match)",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      backgroundColor:
                                                          Colors.red[700],
                                                      textColor: Colors.white,
                                                    );
                                                  }
                                                  Navigator.of(context).pop();
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "An error occurred: $e",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.red[700],
                                                    textColor: Colors.white,
                                                  );
                                                  Navigator.of(context).pop();
                                                  print('Error: $e');
                                                }
                                              } else if (selectedSport ==
                                                  'Volleyball(Girls)') {
                                                try {
                                                  int teamAPoints = int.tryParse(
                                                          teamAScoreController
                                                              .text) ??
                                                      0; // Default to 0 if parsing fails
                                                  int teamBPoints = int.tryParse(
                                                          teamBScoreController
                                                              .text) ??
                                                      0; // Default to 0 if parsing fails
                                                  if (addMatchKey.currentState!
                                                      .validate()) {
                                                    String result =
                                                        await InterCollegeServices()
                                                            .recordVolleyballGirlsMatch(
                                                      academicYear: "2024-2025",
                                                      matchLocation:
                                                          matchLocationController
                                                              .text,
                                                      matchType:
                                                          matchTypeController
                                                              .text,
                                                      matchTime:
                                                          matchTimeController
                                                              .text,
                                                      matchDayDate:
                                                          matchDayDateController
                                                              .text,
                                                      teamAName:
                                                          teamANameController
                                                              .text,
                                                      teamBName:
                                                          teamBNameController
                                                              .text,
                                                      teamALocation:
                                                          teamALocationController
                                                              .text,
                                                      teamBLocation:
                                                          teamBLocationController
                                                              .text,
                                                      teamAScore: teamAPoints
                                                          .toString(),
                                                      teamBScore: teamBPoints
                                                          .toString(),
                                                      teamALogoUrl:
                                                          teamALogoUrlController
                                                              .text,
                                                      teamBLogoUrl:
                                                          teamBLogoUrlController
                                                              .text,
                                                      teamAId:
                                                          teamADocIdController
                                                              .text,
                                                              teamBId: teamBDocIdController.text,
                                                    );

                                                    if (result ==
                                                        'Volleyball(Girls) Match Record Added Successfully') {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Volleyball(Girls) Match Added Successfully",
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        backgroundColor:
                                                            Colors.green[700],
                                                        textColor: Colors.white,
                                                      );
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Failed to add Volleyball(Girls) Match)",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      backgroundColor:
                                                          Colors.red[700],
                                                      textColor: Colors.white,
                                                    );
                                                  }
                                                  Navigator.of(context).pop();
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "An error occurred: $e",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.red[700],
                                                    textColor: Colors.white,
                                                  );
                                                  Navigator.of(context).pop();
                                                  print('Error: $e');
                                                }
                                              } else if (selectedSport ==
                                                  'Volleyball(Boys)') {
                                                try {
                                                  int teamAPoints = int.tryParse(
                                                          teamAScoreController
                                                              .text) ??
                                                      0; // Default to 0 if parsing fails
                                                  int teamBPoints = int.tryParse(
                                                          teamBScoreController
                                                              .text) ??
                                                      0; // Default to 0 if parsing fails
                                                  if (addMatchKey.currentState!
                                                      .validate()) {
                                                    String result =
                                                        await InterCollegeServices()
                                                            .recordVolleyballBoysMatch(
                                                      academicYear: "2024-2025",
                                                      matchLocation:
                                                          matchLocationController
                                                              .text,
                                                      matchType:
                                                          matchTypeController
                                                              .text,
                                                      matchTime:
                                                          matchTimeController
                                                              .text,
                                                      matchDayDate:
                                                          matchDayDateController
                                                              .text,
                                                      teamAName:
                                                          teamANameController
                                                              .text,
                                                      teamBName:
                                                          teamBNameController
                                                              .text,
                                                      teamALocation:
                                                          teamALocationController
                                                              .text,
                                                      teamBLocation:
                                                          teamBLocationController
                                                              .text,
                                                      teamAScore: teamAPoints
                                                          .toString(),
                                                      teamBScore: teamBPoints
                                                          .toString(),
                                                      teamALogoUrl:
                                                          teamALogoUrlController
                                                              .text,
                                                      teamBLogoUrl:
                                                          teamBLogoUrlController
                                                              .text, teamAId: teamADocIdController.text,
                                                              teamBId: teamBDocIdController.text,
                                                    );

                                                    if (result ==
                                                        'Volleyball(Boys) Match Record Added Successfully') {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Volleyball(Boys) Match Added Successfully",
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        backgroundColor:
                                                            Colors.green[700],
                                                        textColor: Colors.white,
                                                      );
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Failed to add Volleyball(Boys) Match)",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      backgroundColor:
                                                          Colors.red[700],
                                                      textColor: Colors.white,
                                                    );
                                                  }
                                                  Navigator.of(context).pop();
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "An error occurred: $e",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.red[700],
                                                    textColor: Colors.white,
                                                  );
                                                  Navigator.of(context).pop();
                                                  print('Error: $e');
                                                }
                                              } else if (selectedSport ==
                                                  'Tug of War') {
                                                try {
                                                  int teamAPoints = int.tryParse(
                                                          teamAScoreController
                                                              .text) ??
                                                      0; // Default to 0 if parsing fails
                                                  int teamBPoints = int.tryParse(
                                                          teamBScoreController
                                                              .text) ??
                                                      0; // Default to 0 if parsing fails
                                                  if (addMatchKey.currentState!
                                                      .validate()) {
                                                    String result =
                                                        await InterCollegeServices()
                                                            .recordTugOfWarMatch(
                                                      academicYear: "2024-2025",
                                                      matchLocation:
                                                          matchLocationController
                                                              .text,
                                                      matchType:
                                                          matchTypeController
                                                              .text,
                                                      matchTime:
                                                          matchTimeController
                                                              .text,
                                                      matchDayDate:
                                                          matchDayDateController
                                                              .text,
                                                      teamAName:
                                                          teamANameController
                                                              .text,
                                                      teamBName:
                                                          teamBNameController
                                                              .text,
                                                      teamALocation:
                                                          teamALocationController
                                                              .text,
                                                      teamBLocation:
                                                          teamBLocationController
                                                              .text,
                                                      teamAScore: teamAPoints
                                                          .toString(),
                                                      teamBScore: teamBPoints
                                                          .toString(),
                                                      teamALogoUrl:
                                                          teamALogoUrlController
                                                              .text,
                                                      teamBLogoUrl:
                                                          teamBLogoUrlController
                                                              .text, teamAId: teamADocIdController.text,
                                                              teamBId: teamBDocIdController.text,
                                                    );

                                                    if (result ==
                                                        'TugOfWar Match Record Added Successfully') {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "TugOfWar Match Added Successfully",
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        backgroundColor:
                                                            Colors.green[700],
                                                        textColor: Colors.white,
                                                      );
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Failed to add TugOfWar Match)",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      backgroundColor:
                                                          Colors.red[700],
                                                      textColor: Colors.white,
                                                    );
                                                  }
                                                  Navigator.of(context).pop();
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "An error occurred: $e",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.red[700],
                                                    textColor: Colors.white,
                                                  );
                                                  Navigator.of(context).pop();
                                                  print('Error: $e');
                                                }
                                              } else if (selectedSport ==
                                                  'BasketBall') {
                                                try {
                                                  int teamAPoints = int.tryParse(
                                                          teamAScoreController
                                                              .text) ??
                                                      0; // Default to 0 if parsing fails
                                                  int teamBPoints = int.tryParse(
                                                          teamBScoreController
                                                              .text) ??
                                                      0; // Default to 0 if parsing fails
                                                  if (addMatchKey.currentState!
                                                      .validate()) {
                                                    String result =
                                                        await InterCollegeServices()
                                                            .recordBasketBsallMatch(
                                                      academicYear: "2024-2025",
                                                      matchLocation:
                                                          matchLocationController
                                                              .text,
                                                      matchType:
                                                          matchTypeController
                                                              .text,
                                                      matchTime:
                                                          matchTimeController
                                                              .text,
                                                      matchDayDate:
                                                          matchDayDateController
                                                              .text,
                                                      teamAName:
                                                          teamANameController
                                                              .text,
                                                      teamBName:
                                                          teamBNameController
                                                              .text,
                                                      teamALocation:
                                                          teamALocationController
                                                              .text,
                                                      teamBLocation:
                                                          teamBLocationController
                                                              .text,
                                                      teamAScore: teamAPoints
                                                          .toString(),
                                                      teamBScore: teamBPoints
                                                          .toString(),
                                                      teamALogoUrl:
                                                          teamALogoUrlController
                                                              .text,
                                                      teamBLogoUrl:
                                                          teamBLogoUrlController
                                                              .text, teamAId: teamADocIdController.text,
                                                              teamBId: teamBDocIdController.text,
                                                    );

                                                    if (result ==
                                                        'BasketBall Match Record Added Successfully') {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "BasketBall Match Added Successfully",
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        backgroundColor:
                                                            Colors.green[700],
                                                        textColor: Colors.white,
                                                      );
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Failed to add BasketBall Match)",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      backgroundColor:
                                                          Colors.red[700],
                                                      textColor: Colors.white,
                                                    );
                                                  }
                                                  Navigator.of(context).pop();
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "An error occurred: $e",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.red[700],
                                                    textColor: Colors.white,
                                                  );
                                                  Navigator.of(context).pop();
                                                  print('Error: $e');
                                                }
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "Method Still Not Defined for $selectedSport",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor:
                                                      Colors.red[700],
                                                  textColor: Colors.white,
                                                );
                                              }
                                            },
                                            child: Text(
                                              'Add New Match',
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
                                        icon: Icon(Icons.close,
                                            color: Colors.white),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                        },
                      );
                    },
                    child: Text(
                      "Add Match",
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
