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

      // Safely extract results
      final fetchedAcademicYear = results[0] as String?;
      final fetchedUser = results[1] as User?;

      if (fetchedAcademicYear == null) {
        throw Exception("Failed to fetch academic year.");
      }

      String fetchedTeamId = "";
      if (fetchedUser != null) {
        fetchedTeamId = await AttendaceServices().fetchUsersDepartment(
              fetchedUser.firstName,
              fetchedUser.lastName,
              fetchedAcademicYear,
            ) ??
            ""; // Default to empty string if null
      }

      setState(() {
        currentAcademicYear = fetchedAcademicYear;
        user = fetchedUser;
        teamId = fetchedTeamId;
        print('Attendance page debugging');
        print(currentAcademicYear);
        print(user);
        print(teamId);
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
      body: teamId.isNotEmpty
          ? AttendanceChildrenModule(
              user!, currentAcademicYear, teamId) // Pass all loaded data
          : user!.role == 8 || user!.role == 9
              ? AttendanceMasterModule(user!, currentAcademicYear)
              : Container(),
    );
  }
}
