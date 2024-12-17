import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';

class MatchesDetailsPage extends StatefulWidget {
  const MatchesDetailsPage({
    super.key,
    required this.matchIndex,
    required this.eventId,
  });

  final int matchIndex;
  final String eventId;

  @override
  State<MatchesDetailsPage> createState() => _MatchesDetailsPageState();
}

class _MatchesDetailsPageState extends State<MatchesDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match =
        FirebaseFirestore.instance.collection('events').doc(widget.eventId);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text('Match Details'),
              floating: true,
              expandedHeight: 250,
              flexibleSpace: Container(
                color: primaryColor,
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: secondaryColor,
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                indicatorColor: Colors.transparent,
                tabs: [
                  Tab(text: 'Team 01'),
                  Tab(text: 'Team 02'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            ListView.builder(
              itemCount: 11,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: secondaryColor,
                    title: Text('data'),
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: 11,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: secondaryColor,
                    title: Text('Tab2'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
