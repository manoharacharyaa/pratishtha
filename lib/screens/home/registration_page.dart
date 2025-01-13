import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart' as user;
import 'package:pratishtha/utils/fonts.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key, required this.event});

  final Event event;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  user.User? currentUser;

  void assignUser() {
    getCurrentUser().then((value) {
      setState(() {
        currentUser = value;
      });
    });
  }

  Future<user.User> getCurrentUser() async {
    final String curentUid = FirebaseAuth.instance.currentUser!.uid;

    final currentUser = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: curentUid)
        .get()
        .then((e) => user.User.fromMap(e.docs.first.data()));

    return currentUser;
  }

  @override
  void initState() {
    assignUser();
    super.initState();
  }

  void uploadRegrestration() {
    // Map<String, dynamic> regrestration = {
    //   "uid": currentUser!.uid,
    // };

    List<String> registration = [
      currentUser?.uid ?? '',
    ];

    try {
      FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .update({
        'registered_users': registration,
      }).then(
        (_) => Fluttertoast.showToast(msg: 'Registration Successful'),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Registration Failed $e');
    }
  }

  // Future<void> uploadRegistration() async {
  //   Map<String, dynamic> registration = {
  //     "uid": currentUser?.uid ?? '',
  //   };

  //   try {
  //     final batch = FirebaseFirestore.instance.batch();

  //     final eventRef =
  //         FirebaseFirestore.instance.collection('events').doc(widget.event.id);

  //     final userRef =
  //         FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

  //     batch.update(eventRef, {
  //       'registered_users': FieldValue.arrayUnion([registration])
  //     });

  //     batch.update(userRef, {
  //       'registered_events': FieldValue.arrayUnion([widget.event.id])
  //     });

  //     await batch.commit();

  //     Fluttertoast.showToast(msg: 'Registration Successful');
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: 'Registration Failed: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: AppFonts.poppins(color: Colors.black),
        title: Text(
          'Regristration Page',
        ),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.event.name ?? '',
              style: AppFonts.poppins(
                color: Colors.black,
                size: 20,
              ),
            ),
            Text(
              currentUser?.firstName ?? '',
              style: AppFonts.poppins(
                color: Colors.black,
                size: 20,
              ),
            ),
            TextButton(
              onPressed: uploadRegrestration,
              child: Text('Confirm Registration'),
            ),
          ],
        ),
      ),
    );
  }
}
