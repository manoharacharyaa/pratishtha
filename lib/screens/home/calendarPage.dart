import 'package:flutter/material.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/calendarServices.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
// import 'package:pratishtha/widgets/loadingWidgets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'navPanel.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  CalendarController calendarController = CalendarController();
  DatabaseServices databaseServices = DatabaseServices();

  @override
  void initState() {
    calendarController.view = CalendarView.month;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(calendarController.view==CalendarView.day){
          calendarController.view = CalendarView.month;
          calendarController.displayDate = DateTime.now();
          return false;
        }
        else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(selectedIndex: 0)));
          return false;
        }
      },
      child: RefreshIndicator(
      onRefresh: () {
        setState(() {});
        return Future.delayed(
          Duration(seconds: 1),
        );
      },
        child: Scaffold(
          body: FutureBuilder<List>(
            future: Future.wait([
              databaseServices.getEvents(),
              databaseServices.getCurrentUser(),
              databaseServices.getFests()
            ]),
            builder: (BuildContext context, AsyncSnapshot<List> snapshot){
              if(snapshot.hasData){
                List<Event> tempAllEventsList = [];

                List<Event> eventsSnapshot = snapshot.data![0];
                User currentUserSnapshot = snapshot.data![1];
                List<Event> festsSnapshot = snapshot.data![2];

                festsSnapshot.forEach((Event event) {
                  if(event.isEvent){
                    eventsSnapshot.removeWhere((Event childEvent) => childEvent.id==event.childId![0]);
                  }
                });

                if([5,3].contains(currentUserSnapshot.role)){
                  tempAllEventsList = eventsSnapshot + festsSnapshot;
                }
                else{
                  eventsSnapshot.forEach((Event event) {
                    if(event.goLive){
                      tempAllEventsList.add(event);
                    }
                  });
                  festsSnapshot.forEach((Event event) {
                    if(event.goLive){
                      tempAllEventsList.add(event);
                    }
                  });
                }
                tempAllEventsList.removeWhere((Event event) => event.dateFrom!.isAtSameMomentAs(DateTime(1975, 12, 11)));
                return Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: SfCalendar(
                      view: CalendarView.month,
                      controller: calendarController,
                      dataSource: getCalendarDataSource(eventsList: tempAllEventsList, user: currentUserSnapshot),
                      initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month),
                      initialSelectedDate: DateTime.now(),
                      onLongPress: (CalendarLongPressDetails ctd){
                        calendarController.view = CalendarView.day;
                      },
                      monthViewSettings: MonthViewSettings(
                          navigationDirection: MonthNavigationDirection.horizontal,
                          numberOfWeeksInView: 6,
                          showTrailingAndLeadingDates: true,
                          showAgenda: true,
                          agendaViewHeight: MediaQuery.of(context).size.height/4.5,
                          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                      ),
                    ),
                  ),
                );
              }
              else if(snapshot.hasError){
                //print("snapshot error: ${snapshot.error} ");
                return CustomErrorWidget();
              }
              return Center(child: loadingWidget());
            },
          )
        ),
      ),
    );
  }
}