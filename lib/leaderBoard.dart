import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  int counter = 0;
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LeaderBoards'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              height: MediaQuery.of(context).size.height / 6,
              width: MediaQuery.of(context).size.width - 50,
              child: Center(
                child: Text('InterCollege LeaderBoard', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('colleges').orderBy('score', descending: true).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final documents = snapshot.data!.docs;
                return  ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    int serial = index + 1;
                    final document = documents[index];
                    final collegeName = document['collegeName'];
                    final score = document['score'].toString();
                    Color avatarColor = Colors.white;

                    // Assign gold, silver, and bronze colors to the top three serial numbers
                    if (index == 0) {
                      avatarColor = Colors.amber; // Gold
                    } else if (index == 1) {
                      avatarColor = Colors.grey; // Silver
                    } else if (index == 2) {
                      avatarColor = Colors.brown; // Bronze
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 17,
                        decoration: BoxDecoration(
                            color: purpleAccentColor, borderRadius: BorderRadius.circular(25)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: CircleAvatar(
                                    backgroundColor: avatarColor,
                                    child: Text(
                                      serial.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: avatarColor != Colors.white
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  collegeName,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 6,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: Colors.tealAccent),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      score,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}