import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart' as user;

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
    Map<String, dynamic> regrestration = {
      "uid": currentUser!.uid,
    };

    try {
      FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .update({
        'registered_users': FieldValue.arrayUnion([regrestration])
      }).then(
        (_) => Fluttertoast.showToast(msg: 'Registration Successful'),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Registration Failed $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regristration Page'),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.event.name!),
            Text(currentUser!.firstName!),
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
