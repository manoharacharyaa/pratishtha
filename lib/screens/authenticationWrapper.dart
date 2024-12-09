import 'package:pratishtha/screens/authentication/loginPage.dart';
import 'package:pratishtha/screens/home/navPanel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart' as sh;
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:provider/provider.dart';
import 'package:pratishtha/models/userModel.dart' as user;

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  DatabaseServices databaseServices = DatabaseServices();

  Future<void> returnVoid() async {
    return;
  }

  Future<void> getUser(User firebaseUser) async {
    try {
      user.User currentUser = await databaseServices.getUser(firebaseUser.uid);
      await sh.setUserFromPrefs(currentUser);
      if (firebaseUser.emailVerified) {
        if (!currentUser.isVerified) {
          currentUser.isVerified = true;
          try {
            await databaseServices.updateUserVerifiedStatus(user: currentUser);
          } catch (e) {
            // debugPrint(e.message);
            // debugPrint(s.toString());
          }
        }
      } else {
        if (currentUser.isFaculty!) {
          if (!currentUser.isVerified) {
            currentUser.isVerified = true;
            try {
              await databaseServices.updateUserVerifiedStatus(
                  user: currentUser);
            } catch (e) {
              // debugPrint(e.message);
              // debugPrint(s.toString());
            }
          }
        } else {
          if (currentUser.isVerified) {
            currentUser.isVerified = false;
            try {
              await databaseServices.updateUserVerifiedStatus(
                  user: currentUser);
            } catch (e) {
              // debugPrint(e.message);
              // debugPrint(s.toString());
            }
          }
        }
      }
    } catch (e) {
      // print(e.message);
      // print(s);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return Scaffold(
        body: FutureBuilder<List>(
            future: Future.wait([
              databaseServices.checkGeneralFeatureAccess(),
              databaseServices.getEventTypes(),
              getUser(firebaseUser),
              databaseServices.getRules()
            ]),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              //print(snapshot.error);
              if (snapshot.hasData) {
                return checkConection(
                  child: Home(
                    selectedIndex: 0,
                  ),
                );
              } else if (snapshot.hasError) {
                //print("auth wrapper: ${snapshot.error}");
                return CustomErrorWidget();
              } else {
                return Center(child: loadingWidget());
              }
            }),
      );
    } else {
      return SignIn();
    }
    //return SignIn();
  }
}
