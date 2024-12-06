import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/screens/admin/attendanceSystem/eachVolunteerAttendace.dart';
import 'package:pratishtha/services/attendanceServices.dart';

class ViewAttendanceAsTeacher extends StatefulWidget {
  final String currentAcademicYear;
  const ViewAttendanceAsTeacher(this.currentAcademicYear, {super.key});

  @override
  State<ViewAttendanceAsTeacher> createState() =>
      _ViewAttendanceAsTeacherState();
}

class _ViewAttendanceAsTeacherState extends State<ViewAttendanceAsTeacher> {
  List<Map<String, dynamic>> volunteersData = [];
  bool isLoading = true;

  // Predefined lists for groups
  List<Map<String, dynamic>> feVolunteers = [];
  List<Map<String, dynamic>> seVolunteers = [];
  List<Map<String, dynamic>> teVolunteers = [];
  List<Map<String, dynamic>> beVolunteers = [];
  List<Map<String, dynamic>> others = [];
  List<String> volunteerBranch = [
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
  List<String> volunteerClass = ['FE', 'SE', 'TE', 'BE', 'OTHERS'];

  @override
  void initState() {
    super.initState();
    fetchVolunteersData();
  }

  String? selectedClass;
  String? selectedBranch;
  int selectedIndex = 0;

  bool isAscending = true;

  void refreshPage() {
    setState(() {
      fetchVolunteersData();
    });
  }

  void fetchVolunteersData() async {
    try {
      final result = await AttendaceServices()
          .getAllVolunteers(widget.currentAcademicYear);
      setState(() {
        volunteersData = result;
        _categorizeVolunteers();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching volunteers data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _categorizeVolunteers() {
    for (var volunteer in volunteersData) {
      final classField = volunteer['class'] ?? '';
      if (classField.startsWith('FE')) {
        feVolunteers.add(volunteer);
      } else if (classField.startsWith('SE')) {
        seVolunteers.add(volunteer);
      } else if (classField.startsWith('TE')) {
        teVolunteers.add(volunteer);
      } else if (classField.startsWith('BE')) {
        beVolunteers.add(volunteer);
      } else {
        others.add(volunteer);
      }
    }
    print('Debugging volunteer year-wise');
    print(feVolunteers);
    print(seVolunteers);
    print(teVolunteers);
    print(beVolunteers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () => print, icon: Icon(Icons.refresh))
        ],
        backgroundColor: Colors.pink,
        title: Text(
          'ATTENDANCE',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
        ),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height / 15,
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: Column(
        children: [
          // Container with the same color as the app bar
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            height: MediaQuery.of(context).size.height / 14,
            color: Colors.pink,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 4,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 21,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        alignment: Alignment.center,
                        hint: Center(
                          child: Text(
                            (selectedClass?.isNotEmpty ?? false)
                                ? selectedClass!
                                : 'CLASS',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        items: volunteerClass.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                                child: Text(
                              value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            )),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value!;
                          });

                          // Handle selection
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(25), // Rounded corners
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: selectedClass != null
                              ? Colors.white
                              : Colors.white.withOpacity(
                                  0.3), // Dropdown background color
                        ),
                        style: GoogleFonts.poppins(color: Colors.white),
                        isDense: true, // Removes the down arrow
                        icon: SizedBox
                            .shrink(), // Empty icon widget to disable the down arrow
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    flex: 4,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 21,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        alignment: Alignment.center,
                        hint: Center(
                          child: Text(
                            (selectedBranch?.isNotEmpty ?? false)
                                ? selectedBranch!
                                : 'BRANCH',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        items: volunteerBranch.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(child: Text(value)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBranch = value!;
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Rounded corners
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: selectedBranch != null
                              ? Colors.white
                              : Colors.white.withOpacity(
                                  0.3), // Dropdown background color
                        ),
                        isDense: true, // Removes the down arrow
                        icon: SizedBox
                            .shrink(), // Empty icon widget to disable the down arrow
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    flex: 4,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 21,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.3), // Uniform background color
                        borderRadius:
                            BorderRadius.circular(30), // Matches toggle buttons
                      ),
                      child: ToggleButtons(
                        renderBorder: false,
                        splashColor: Colors.white,
                        isSelected: [selectedIndex == 0, selectedIndex == 1],
                        onPressed: (int index) {
                          setState(() {
                            selectedIndex = index;
                          });
                          setState(() {
                            isAscending = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(30),
                        selectedColor: Colors.black,
                        fillColor: Colors.white.withOpacity(0.9),
                        color: Colors.white,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_upward, size: 16),
                              SizedBox(width: 2),
                              Text('A-Z'),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.arrow_downward, size: 16),
                              SizedBox(width: 2),
                              Text('Z-A'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ListView with bounded height
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: ListView(
                children: [
                  if ((selectedClass ?? '').isEmpty &&
                      (selectedBranch ?? '').isEmpty) ...[
                    if (isAscending) ...[
                      _buildVolunteerGroup(
                          'First Year (FE)', feVolunteers, context),
                      _buildVolunteerGroup(
                          'Second Year (SE)', seVolunteers, context),
                      _buildVolunteerGroup(
                          'Third Year (TE)', teVolunteers, context),
                      _buildVolunteerGroup(
                          'Fourth Year (BE)', beVolunteers, context),
                      _buildVolunteerGroup('Others', others, context),
                    ] else ...[
                      _buildVolunteerGroup('Others', others, context),
                      _buildVolunteerGroup(
                          'Fourth Year (BE)', beVolunteers, context),
                      _buildVolunteerGroup(
                          'Third Year (TE)', teVolunteers, context),
                      _buildVolunteerGroup(
                          'Second Year (SE)', seVolunteers, context),
                      _buildVolunteerGroup(
                          'First Year (FE)', feVolunteers, context),
                    ]
                  ] else if ((selectedClass ?? '').isNotEmpty &&
                      (selectedBranch ?? '').isNotEmpty) ...[
                    if (selectedClass == 'FE')
                      _buildVolunteerGroup(
                          'First Year (FE)', feVolunteers, context),
                    if (selectedClass == 'SE')
                      _buildVolunteerGroup(
                          'Second Year (SE)', seVolunteers, context),
                    if (selectedClass == 'TE')
                      _buildVolunteerGroup(
                          'Third Year (TE)', teVolunteers, context),
                    if (selectedClass == 'BE')
                      _buildVolunteerGroup(
                          'Fourth Year (BE)', beVolunteers, context),
                    if (selectedClass == 'Others')
                      _buildVolunteerGroup('Others', others, context),
                  ] else if ((selectedClass ?? '').isNotEmpty) ...[
                    if (selectedClass == 'FE')
                      _buildVolunteerGroup(
                          'First Year (FE)', feVolunteers, context),
                    if (selectedClass == 'SE')
                      _buildVolunteerGroup(
                          'Second Year (SE)', seVolunteers, context),
                    if (selectedClass == 'TE')
                      _buildVolunteerGroup(
                          'Third Year (TE)', teVolunteers, context),
                    if (selectedClass == 'BE')
                      _buildVolunteerGroup(
                          'Fourth Year (BE)', beVolunteers, context),
                    if (selectedClass == 'Others')
                      _buildVolunteerGroup('Others', others, context),
                  ] else if ((selectedBranch ?? '').isNotEmpty) ...[
                    _buildVolunteerGroup(
                      'Filtered by Branch ($selectedBranch)',
                      volunteersData
                          .where((volunteer) =>
                              (volunteer['branch'] ?? '').toLowerCase() ==
                              selectedBranch!.toLowerCase())
                          .toList(),
                      context,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildVolunteerGroup(
    String title, List<Map<String, dynamic>> volunteer, BuildContext context) {
  if (volunteer.isEmpty) return const SizedBox.shrink();

  return Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Expanded(
              child: Divider(
            color: Colors.grey,
            indent: 10,
            height: 3,
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          const Expanded(
              child: Divider(
            color: Colors.grey,
            endIndent: 10,
          )),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      ...volunteer
          .map((volunteer) => _buildVolunteerCard(volunteer, context))
          .toList(),
      SizedBox(
        height: 10,
      ),
    ],
  );
}

Widget _buildVolunteerCard(
    Map<String, dynamic> volunteer, BuildContext context) {
  return Card(
    shadowColor: Color.fromRGBO(255, 152, 148, 1),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(width: 2, color: Color.fromRGBO(252, 218, 217, 1.0))),
    elevation: 5,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Section: Name and Email
          Expanded(
            flex: 3, // Allocate more space to the name column
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  volunteer['name'] ?? 'Unknown',
                  overflow: TextOverflow.ellipsis, // Handle long names
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  volunteer['sakec_mail'] ?? 'No Email',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color.fromARGB(255, 234, 136, 137),
                  ),
                ),
              ],
            ),
          ),
          // Right Section: Class and Roll No
          Expanded(
            flex: 2, // Allocate less space for Class and Roll No
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Class
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      volunteer['class']?.toString() ?? 'N/A',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'CLASS',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Color.fromARGB(255, 234, 136, 137),
                      ),
                    ),
                  ],
                ),
                // Roll No
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      volunteer['rollno']?.toString() ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ROLL NO.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Color.fromARGB(255, 234, 136, 137),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Navigation Icon
          SizedBox(
            width: 40, // Smaller size for the arrow icon
            child: IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                print('Volunteer data: $volunteer');

                final attendanceData =
                    volunteer['attendance'] ?? volunteer['attendace'];
                print('Attendance data: $attendanceData');
                print('Attendance data type: ${attendanceData.runtimeType}');

                if (attendanceData is List && attendanceData.isNotEmpty) {
                  // Assuming the first item in the list is the attendance map
                  final firstAttendanceEntry = attendanceData[0];
                  print('First attendance entry: $firstAttendanceEntry');

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AttendanceCalendar(firstAttendanceEntry)));
                } else if (attendanceData is Map) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AttendanceCalendar(
                          Map<String, dynamic>.from(attendanceData))));
                } else {
                  print('No valid attendance data');
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No attendance data available')));
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}
