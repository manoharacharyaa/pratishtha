import 'package:flutter/material.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/screens/admin/attendanceSystem/attendaceChildrenModule.dart';
import 'package:pratishtha/screens/admin/attendanceSystem/attendanceMasterModule.dart';
import 'package:pratishtha/services/attendanceServices.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  User? user;
  String currentAcademicYear = "";
  String teamId = "";
  bool isLoading = true; // To show the loading screen

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  Future<void> initializePage() async {
    try {
      // Fetch data in parallel
      final results = await Future.wait([
        fetchAcademicYear(),
        _loadUser(),
      ]);

      // After fetching user, use their data to fetch the team
      final fetchedUser = results[1] as User?;
      final fetchedTeamId = fetchedUser != null
          ? await AttendaceServices().fetchUsersDepartment(
              fetchedUser.firstName,
              fetchedUser.lastName,
              results[0] as String,
            )
          : "";

      setState(() {
        currentAcademicYear = results[0] as String;
        user = fetchedUser;
        teamId = fetchedTeamId!;
        isLoading = false; // Stop showing loading screen
      });
    } catch (e) {
      debugPrint("Error initializing AttendancePage: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Wrapper to handle academic year fetching
  Future<String> fetchAcademicYear() async {
    return await getCurrentAcademicYear();
  }

  Future<String> getCurrentAcademicYear() async {
    DateTime currentDate = DateTime.now();

    DateTime startOfAcademicYear = DateTime(currentDate.year, 6, 15);
    DateTime endOfAcademicYear = DateTime(currentDate.year + 1, 5, 30);

    if (currentDate.isBefore(startOfAcademicYear)) {
      return "${currentDate.year - 1}-${currentDate.year}";
    } else if (currentDate.isAfter(endOfAcademicYear)) {
      return "${currentDate.year}-${currentDate.year + 1}";
    } else {
      return "${currentDate.year}-${currentDate.year + 1}";
    }
  }

  Future<User?> _loadUser() async {
    return await getUserFromPrefs(); // Fetch user from SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: loadingWidget()), // Show loading widget
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Error: User data not available")),
      );
    }

    return Scaffold(
      body: user!.role == 8
          ? AttendanceMasterModule(
              user!, currentAcademicYear) // Pass all loaded data
          : teamId != null
              ? AttendanceChildrenModule(user!, currentAcademicYear, teamId)
              : Container(),
    );
  }
}

