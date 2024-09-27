// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:pratishtha/main.dart';

// Widget showNotifications({Widget child}) {
//   return StreamBuilder(
//       stream: FirebaseMessaging.onMessageOpenedApp,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           var msg = snapshot.data;
//           RemoteNotification notification = msg.notification;
//           AndroidNotification android = msg.notification?.android;
//           if (notification != null && android != null) {
//             showDialog(
//                 context: context,
//                 builder: (_) {
//                   return AlertDialog(
//                     title: Text(notification.title),
//                     content: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [Text(notification.body)],
//                       ),
//                     ),
//                   );
//                 });
//           }

//           return StreamBuilder(
//               stream: FirebaseMessaging.onMessage,
//               builder: (context, snap) {
//                 if (snap.hasData) {
//                   var message = snap.data;
//                   RemoteNotification notification = message.notification;
//                   AndroidNotification android = message.notification?.android;
//                   if (notification != null && android != null) {
//                     flutterLocalNotificationsPlugin.show(
//                         notification.hashCode,
//                         notification.title,
//                         notification.body,
//                         NotificationDetails(
//                           android: AndroidNotificationDetails(
//                             channel.id,
//                             channel.name,
//                             channelDescription: channel.description,
//                             color: Colors.blue,
//                             playSound: true,
//                             icon: '@mipmap/ic_launcher',
//                           ),
//                         ));
//                   }

//                   return child;
//                 } else {
//                   return child;
//                 }
//               });
//         } else {
//           return StreamBuilder(
//               stream: FirebaseMessaging.onMessage,
//               builder: (context, snap) {
//                 if (snap.hasData) {
//                   var message = snap.data;
//                   RemoteNotification notification = message.notification;
//                   AndroidNotification android = message.notification?.android;
//                   if (notification != null && android != null) {
//                     flutterLocalNotificationsPlugin.show(
//                         notification.hashCode,
//                         notification.title,
//                         notification.body,
//                         NotificationDetails(
//                           android: AndroidNotificationDetails(
//                             channel.id,
//                             channel.name,
//                             channelDescription: channel.description,
//                             color: Colors.blue,
//                             playSound: true,
//                             icon: '@mipmap/ic_launcher',
//                           ),
//                         ));
//                   }

//                   return child;
//                 } else {
//                   return child;
//                 }
//               });
//         }
//       });
// }
