import 'package:flutter/material.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeGirlsVolleyBall.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeBoysVolleyBall.dart';

class InterCollegeVolleyballHome extends StatefulWidget {
  const InterCollegeVolleyballHome({super.key});

  @override
  State<InterCollegeVolleyballHome> createState() =>
      _InterCollegeVolleyballHomeState();
}

class _InterCollegeVolleyballHomeState
    extends State<InterCollegeVolleyballHome> {
  bool isGirlsSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InterCollege Volleyball'),
      ),
      body: Column(
        children: [
          ToggleButtons(
            selectedColor: Colors.black,
            selectedBorderColor: Color(0xFFA8F7E3),
            borderColor: Color(0xFFA8F7E3),
            fillColor:Color(0xFFA8F7E3),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Girls'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Boys'),
              ),
            ],
            isSelected: [isGirlsSelected, !isGirlsSelected],
            onPressed: (int index) {
              setState(() {
                isGirlsSelected = index == 0;
              });
            },
          ),
          Expanded(
            child: isGirlsSelected
                ? InterCollegeVolleyBallGirlsHome(currentAcademicYear: '2024-2025')
                : InterCollegeVolleyBallBoysHome(currentAcademicYear: '2024-2025'),
          ),
        ],
      ),
    );
  }
}