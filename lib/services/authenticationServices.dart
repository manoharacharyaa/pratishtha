import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('users');

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanged => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed In";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    }
  }

  Future<String> signup(
      {String? email,
      String? password,
      String? firstName,
      String? lastName,
      String? phone,
      String? institute,
      int? regNo,
      String? smartCardNo,
      String? sakecId,
      int? rollNo,
      String? branch,
      String? year,
      int? div}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email!, password: password!);
      User user = _firebaseAuth.currentUser!;
      String uid = user.uid;

      await _firebaseAuth.currentUser!.sendEmailVerification();

      // await FirebaseMessaging.instance.subscribeToTopic('All');

      await _collectionReference.doc(uid).set({
        'uid': uid,
        'email': email,
        'role': 0,
        'avatar': Random().nextInt(8),
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'institute': institute,
        'reg_no': regNo,
        'smartcard_no': smartCardNo,
        'sakec_id': sakecId,
        'roll_no': rollNo,
        'branch': branch,
        'year': year,
        'div': div,
        'soft_delete': false,
        'is_verified': false,
      });

      return "Signed up";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    }
  }
}
