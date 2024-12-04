import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/services/attendanceServices.dart';

class ViewAttendanceAsTeacher extends StatefulWidget {
  final String currentAcademicYear;
  const ViewAttendanceAsTeacher(this.currentAcademicYear,{super.key});

  @override
  State<ViewAttendanceAsTeacher> createState() => _ViewAttendanceAsTeacherState();
}

class _ViewAttendanceAsTeacherState extends State<ViewAttendanceAsTeacher> {
  List<String> volunteerClassDiv = [];
  List<String> volunteerBranch = [];
  bool isAscending = true;
  List<Map<String, dynamic>> volunteersData= [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dynamic result = AttendaceServices().getAllVolunteers(widget.currentAcademicYear);
    if(result != null)
      {
        volunteersData = result;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom gradient header
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 10, // Adjust height as needed
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 96, 88, 255), // Start color
                  Color.fromARGB(255, 24, 87, 255), // End color
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Center(
              child: Text(
                'ATTENDANCE',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Container with three dropdowns in a row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    items: volunteerBranch.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // Handle the selection
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    items: volunteerBranch.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // Handle the selection
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        isAscending = !isAscending; // Toggle sort order
                      });
                      // You can add additional logic here to sort your list based on the isAscending flag
                    },
                    tooltip: isAscending ? 'Sort Z to A' : 'Sort A to Z',
                    color: Colors.blue, // Adjust the color as needed
                  )
                ),
              ],
            ),
          ),
          Spacer(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // 5% width padding
        child: ListView.builder(
          itemCount: volunteersData.length,
          itemBuilder: (context, index) {
            final volunteer = volunteersData[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Left Section: Name and Email
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                volunteer['name'] ?? 'Unknown',
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
                        // Center Section: Roll No and Class
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Roll No
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        volunteer['rollno']?.toString() ?? 'N/A',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Roll No',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Class
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        volunteer['class'] ?? 'N/A',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Class',
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
                          ],
                        ),
                      ],
                    ),
                    // Right Section: Arrow
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        // Navigate to the attendance details page
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
        ],
      ),
    );
  }
}