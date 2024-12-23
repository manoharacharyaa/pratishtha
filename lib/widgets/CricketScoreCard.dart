import 'package:flutter/material.dart';

class MatchCard extends StatefulWidget {
  final String matchTitle;
  final String date;
  final String team1;
  final String team1Score;
  final String team2;
  final String team2Score;
  final String result;
  final String time;
  final String location;
  final String team1TopBatter;
  final String team1TopBowler;
  final String team2TopBatter;
  final String team2TopBowler;

  const MatchCard({
    required this.matchTitle,
    required this.date,
    required this.team1,
    required this.team1Score,
    required this.team2,
    required this.team2Score,
    required this.result,
    required this.time,
    required this.location,
    required this.team1TopBatter,
    required this.team1TopBowler,
    required this.team2TopBatter,
    required this.team2TopBowler,
    Key? key,
  }) : super(key: key);

  @override
  _MatchCardState createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 227, 255, 235),
      shadowColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.matchTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.date,
                  style: TextStyle(
                    color: Colors.grey.shade900,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_outlined),
                        SizedBox(width: 4),
                        Text(
                          widget.time,
                          style: TextStyle(color: Colors.grey.shade900),
                        ),
                      ],
                    ),
                    Row(
                      
                      children: [
                        const Icon(Icons.stadium),
                        SizedBox(width: 4),
                        Text(
                          widget.location,
                          style: TextStyle(color: Colors.grey.shade900),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Text(
                        widget.team1[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.team1,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
                Text(widget.team1Score),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 102, 228, 167),
                  ),
                  child: const Text(
                    "VS",
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
                Text(widget.team2Score),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        widget.team2[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.team2,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.result,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Match Details",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Team 1"),
                                    Text("Top Batter: ${widget.team1TopBatter}"),
                                    Text("Top Bowler: ${widget.team1TopBowler}"),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Team 2"),
                                    Text("Top Batter: ${widget.team2TopBatter}"),
                                    Text("Top Bowler: ${widget.team2TopBowler}"),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
