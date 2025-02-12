import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/screens/home/aproval_page.dart';
import 'package:pratishtha/utils/fonts.dart';

class EventMatchesPage extends StatefulWidget {
  const EventMatchesPage({
    super.key,
    required this.event,
  });

  final Event event;
  @override
  State<EventMatchesPage> createState() => _EventMatchesPageState();
}

class _EventMatchesPageState extends State<EventMatchesPage> {
  List<dynamic> matchesMap = [];
  List<MatchModel> matches = [];
  bool isLoading = true;

  Future<void> getMatches() async {
    try {
      DocumentSnapshot eventSnapshots = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .get();

      matchesMap = eventSnapshots['matches'];

      setState(() {
        matches =
            matchesMap.map((match) => MatchModel.fromJson(match)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('$e event_match_page line 36');
      setState(() {
        matches = [];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getMatches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Matches',
          style: AppFonts.poppins(color: Colors.black),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : matches.isEmpty
              ? Center(
                  child: Text(
                    'No Matches Found',
                    style: AppFonts.poppins(),
                  ),
                )
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AprovalPage(
                                index: index,
                                event: widget.event,
                                matchId: match.matchId ?? '',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 70,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                match.team01!,
                                style: AppFonts.poppins(),
                              ),
                              Text(
                                'VS',
                                style: AppFonts.poppins(),
                              ),
                              Text(
                                match.team02!,
                                style: AppFonts.poppins(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
