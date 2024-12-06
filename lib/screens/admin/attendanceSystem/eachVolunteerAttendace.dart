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
        backgroundColor: const Color(0xFFFF4B80),
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Material(
              child: TableCalendar(
                firstDay: firstDay,
                lastDay: lastDay,
                focusedDay: focusedDay,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF00C411),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(Icons.arrow_left, size: 16),
                  rightChevronIcon: Icon(Icons.arrow_right, size: 16),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  weekendStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    bool isWeekend = day.weekday == 6 || day.weekday == 7;

                    // Debug print for each day
                    print('Checking day: $day');
                    print('Attendance data keys: ${attendanceData.keys}');

                    // Check if the current day exists in attendanceData
                    bool isPresent = attendanceData.keys.any((key) =>
                        key.year == day.year &&
                        key.month == day.month &&
                        key.day == day.day);

                    print('Is $day present? $isPresent');

                    Color textColor = isWeekend
                        ? const Color(0xFFB2B2B2)
                        : const Color(0xFF2E8CED);
                    if (isPresent) {
                      textColor = const Color(0xFF00C411);
                    }

                    return Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Center(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C411),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(const Color(0xFFB2B2B2), 'Holiday'),
        const SizedBox(width: 8.0),
        _buildLegendItem(const Color(0xFF2E8CED), 'Working Day'),
        const SizedBox(width: 8.0),
        _buildLegendItem(const Color(0xFF00C411), 'Present'),
      ],
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
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
