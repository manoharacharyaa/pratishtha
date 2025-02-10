import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceCalendar extends StatefulWidget {
  final Map<String, dynamic> volunteerAttendanceStatus;

  const AttendanceCalendar(this.volunteerAttendanceStatus, {Key? key})
      : super(key: key);

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  late Map<DateTime, bool> attendanceData;
  late DateTime focusedDay;
  late DateTime firstDay;
  late DateTime lastDay;

  @override
  void initState() {
    super.initState();
    _prepareAttendanceData();
    focusedDay = DateTime.now();
    firstDay = DateTime(focusedDay.year - 1, 1, 1);
    lastDay = DateTime(focusedDay.year + 1, 12, 31);
  }

  void _prepareAttendanceData() {
    print('Volunteer Attendance Status: ${widget.volunteerAttendanceStatus}');

    attendanceData = {};

    // Remove the 'attendanceList' key if it exists
    final attendanceMap =
        widget.volunteerAttendanceStatus.containsKey('attendanceList')
            ? widget.volunteerAttendanceStatus['attendanceList'][0]
            : widget.volunteerAttendanceStatus;

    print('Processed Attendance Map: $attendanceMap');

    attendanceMap.forEach((dateString, status) {
      print('Processing date: $dateString, Status: $status');

      if (dateString != 'attendanceList') {
        try {
          final dateParts = dateString.split('-');
          if (dateParts.length == 3) {
            final date = DateTime(
              int.parse(dateParts[2]),
              int.parse(dateParts[1]),
              int.parse(dateParts[0]),
            );
            attendanceData[date] = status;
            print('Parsed date: $date, Added to attendanceData: $status');
          } else {
            print('Invalid date format: $dateString');
          }
        } catch (e) {
          print('Error parsing date: $dateString, Error: $e');
        }
      }
    });

    print('Final attendanceData: $attendanceData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'ATTENDANCE',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
        ),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height / 15,
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 18, left: 8, right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Material(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Color.fromARGB(255, 246, 251, 255),
                  ),
                  child: TableCalendar(
                    firstDay: firstDay,
                    lastDay: lastDay,
                    focusedDay: focusedDay,
                    calendarStyle: const CalendarStyle(
                      isTodayHighlighted: false,
                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: CircleAvatar(
                        child: Icon(
                          Icons.arrow_left,
                          size: 30,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.grey,
                        radius: 18,
                      ),
                      rightChevronIcon: CircleAvatar(
                        child: Icon(
                          Icons.arrow_right,
                          size: 30,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.grey,
                        radius: 18,
                      ),
                      headerPadding: EdgeInsets.only(bottom: 16),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      weekendStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        bool isPresent = attendanceData.entries.any((entry) =>
                            entry.value == true &&
                            entry.key.year == day.year &&
                            entry.key.month == day.month &&
                            entry.key.day == day.day);

                        if (isPresent) {
                          // If the volunteer is present on this day
                          return Center(
                            child: Container(
                              width: 40, // Adjust the size as needed
                              height: 40, // Adjust the size as needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00C411), // Green color
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          // For all other days
                          bool isWeekend = day.weekday == 6 || day.weekday == 7;
                          Color textColor = isWeekend
                              ? const Color(0xFFB2B2B2)
                              : const Color(0xFF2E8CED);

                          return Center(
                            child: Text(
                              '${day.day}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              _buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(const Color(0xFFB2B2B2), 'Holiday'),
          Spacer(),
          _buildLegendItem(const Color(0xFF2E8CED), 'Working Day'),
          Spacer(),
          _buildLegendItem(const Color(0xFF00C411), 'Present'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4.0),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
