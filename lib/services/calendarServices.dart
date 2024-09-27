import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:pratishtha/models/userModel.dart';

import 'dateTimeServices.dart';

Color calendarColorPicker({Event? event, User? user}) {
  if (event!.parentId != "") {
    if (event.eventHeads!.contains(user!.uid)) {
      return eventHeadColor;
    } else if (event.volunteers!.contains(user.uid)) {
      return volunteerColor;
    } else if (event.registration!.contains(user.uid)) {
      return registeredColor;
    } else {
      return defaultColor;
    }
  } else {
    return festColor;
  }
}

_AppointmentDataSource getCalendarDataSource(
    {List<Event>? eventsList, User? user}) {
  List<Appointment> appointments = <Appointment>[];

  eventsList!.forEach((event) {
    if (event.parentId != "") {
      int difference = daysBetween(event.dateFrom!, event.dateTo!);
      for (int i = 0; i <= difference; i++) {
        appointments.add(Appointment(
            startTime: event.dateFrom!.add(Duration(days: i)),
            endTime: event.dateTo!.subtract(Duration(days: difference - i)),
            subject: event.name!,
            color: calendarColorPicker(event: event, user: user),
            startTimeZone: '',
            endTimeZone: '',
            isAllDay: false));
      }
    } else {
      appointments.add(Appointment(
          startTime: event.dateFrom!,
          endTime: event.dateTo!,
          subject: event.name!,
          color: buttonBackgroundColor,
          startTimeZone: '',
          endTimeZone: '',
          isAllDay: !event.isEvent));
    }
  });

  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
