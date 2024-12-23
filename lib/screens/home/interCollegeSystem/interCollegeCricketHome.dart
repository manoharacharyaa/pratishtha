import 'package:flutter/material.dart';
import 'package:pratishtha/widgets/CricketScoreCard.dart';

class InterCollegeCricketHome extends StatelessWidget {
  const InterCollegeCricketHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crickket'),
      ),
      body: Expanded(
          
          child: Container(
            height: 306,
            padding: EdgeInsets.all(10),
            child: MatchCard(
              team1TopBatter: 
              'Rahul',
              team1TopBowler: 'Jay',
              team2TopBatter: 'Soham',
              team2TopBowler: 'sairaj',
                matchTitle: 'Cricket',
                date: 'Sun, June 12th',
                team1: 'RCB',
                time: '7:80',
                team1Score: '100/8 (5)',
                team2: 'MI',
                team2Score: '200/8',
                result: 'Mi won by 100 runs',
                location:'Mumbai'),
          )),
    );
  }
}
