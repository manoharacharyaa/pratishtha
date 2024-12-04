import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/constants/colors.dart';
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

  @override
  void initState() {
    super.initState();
    fetchVolunteersData();
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
      appBar: AppBar(
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
            height: MediaQuery.of(context).size.height / 15,
            color: Colors.pink,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 4,
                  child: DropdownButtonFormField<String>(
                    items: volunteerBranch.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(child: Text(value)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // Handle selection
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded corners
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white, // Dropdown background color
                    ),
                    isDense: true, // Removes the down arrow
                    icon: SizedBox
                        .shrink(), // Empty icon widget to disable the down arrow
                  ),
                ),
                Flexible(
                  flex: 4,
                  child: DropdownButtonFormField<String>(
                    items: volunteerBranch.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(child: Text(value)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // Handle selection
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded corners
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white, // Dropdown background color
                    ),
                    isDense: true, // Removes the down arrow
                    icon: SizedBox
                        .shrink(), // Empty icon widget to disable the down arrow
                  ),
                ),
                Flexible(
                  flex: 4,
                  child: DropdownButtonFormField<String>(
                    items: [
                      DropdownMenuItem<String>(
                        value: 'A-Z',
                        child: Center(child: Text('A-Z')),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Z-A',
                        child: Center(child: Text('Z-A')),
                      ),
                    ],
                    onChanged: (value) {
                      // Handle selection
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded corners
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          Colors.grey[300], // Toggle button background color
                    ),
                    isDense: true, // Removes the down arrow
                    icon: SizedBox
                        .shrink(), // Empty icon widget to disable the down arrow
                  ),
                ),
              ],
            ),
          ),
          // ListView with bounded height
          Expanded(
            child: ListView(
              children: [
                _buildVolunteerGroup('First Year (FE)', feVolunteers),
                _buildVolunteerGroup('Second Year (SE)', seVolunteers),
                _buildVolunteerGroup('Third Year (TE)', teVolunteers),
                _buildVolunteerGroup('Fourth Year (BE)', beVolunteers),
                _buildVolunteerGroup('Others', others),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildVolunteerGroup(
    String title, List<Map<String, dynamic>> volunteers) {
  if (volunteers.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Divider(
        thickness: 2,
        color: Colors.grey.shade400,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ...volunteers.map((volunteer) => _buildVolunteerCard(volunteer)).toList(),
    ],
  );
}

Widget _buildVolunteerCard(Map<String, dynamic> volunteer) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
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
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  volunteer['sakec_mail'] ?? 'No Email',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey,
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
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'CLASS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey,
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
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ROLL NO.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey,
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
              onPressed: () {},
            ),
          ),
        ],
      ),
    ),
  );
}
