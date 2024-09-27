import 'package:intl/date_symbol_data_local.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting();

  List<Event> events = await DatabaseServices().getEvents();
  List<String> data = [];

  for(Event currUser in events) {
    data.add(currUser.id!);
  }

  List<Event> events2 = await DatabaseServices().getSpecificEvents(data);

  print('------');
  print(events.length);
  print(events2.length);

}

//Todo: Register button removal
//Todo: Update Participant Status
//Todo: Fix Register button