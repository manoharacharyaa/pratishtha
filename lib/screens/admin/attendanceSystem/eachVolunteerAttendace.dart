import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceCalendar extends StatefulWidget {
  final Map<String, dynamic> volunteerAttendanceStatus;

  const AttendanceCalendar(this.volunteerAttendanceStatus, {Key? key}) : super(key: key);

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
    attendanceData = {};
    widget.volunteerAttendanceStatus.forEach((dateString, status) {
      final dateParts = dateString.split('-');
      final date = DateTime(
        int.parse('20${dateParts[2]}'),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      attendanceData[date] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey.shade200)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      focusedDay = DateTime(focusedDay.year, focusedDay.month - 1, 1);
                    });
                  },
                ),
                Text(
                  DateFormat('MMM yyyy').format(focusedDay),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      focusedDay = DateTime(focusedDay.year, focusedDay.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
          ),
          TableCalendar(
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: focusedDay,
            calendarStyle: CalendarStyle(
              defaultDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade500,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(Icons.arrow_left, size: 16),
              rightChevronIcon: Icon(Icons.arrow_right, size: 16),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
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
                bool isPresent = attendanceData.containsKey(day) && attendanceData[day]!;

                Color dayColor = isWeekend ? Colors.grey.shade500 : Colors.blueAccent;
                Color textColor = isPresent ? Colors.white : (isWeekend ? Colors.white : Colors.black);

                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dayColor,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.0),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.grey, 'Holiday'),
        SizedBox(width: 8.0),
        _buildLegendItem(Colors.blueAccent, 'Working Day'),
        SizedBox(width: 8.0),
        _buildLegendItem(Colors.green, 'Present'),
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
        SizedBox(width: 4.0),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}