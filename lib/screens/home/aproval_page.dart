import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/utils/fonts.dart';
import 'package:toastification/toastification.dart';

class AprovalPage extends StatefulWidget {
  const AprovalPage({
    super.key,
    required this.index,
    required this.event,
    required this.matchId,
  });

  final int index; // Index of the match in the matches list
  final Event event;
  final String matchId;

  @override
  State<AprovalPage> createState() => _AprovalPageState();
}

class _AprovalPageState extends State<AprovalPage> {
  List<User> registeredUsers = [];
  bool isLoading = true;
  List<String> selectedUids = [];
  List<String> team1 = [];
  List<String> team2 = [];
  List<String> team1UserNames = [];
  List<String> team2UserNames = [];

  @override
  void initState() {
    super.initState();
    _fetchRegisteredUsers();
    _setupTeamStreams();
  }

  Future<void> _fetchRegisteredUsers() async {
    try {
      final eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .get();

      if (!eventSnapshot.exists) {
        toastification.show(
          context: context,
          title: const Text('Document does not exist'),
          autoCloseDuration: const Duration(seconds: 5),
        );
        return;
      }

      // final registeredUsersArray = eventSnapshot['registered_users'] as List;
      // final registeredUserIds =
      //     registeredUsersArray.map((user) => user['uid'] as String).toList();

      final registeredUserIds = eventSnapshot['approved_users'] as List;

      if (registeredUserIds.isEmpty) return;

      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: registeredUserIds)
          .get();

      setState(() {
        registeredUsers =
            userQuery.docs.map((doc) => User.fromMap(doc.data())).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching registered users: $e');
      setState(() => isLoading = false);
    }
  }

  void _setupTeamStreams() {
    FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.id)
        .snapshots()
        .listen((eventSnapshot) async {
      if (!eventSnapshot.exists) return;

      final matches = eventSnapshot['matches'] as List;
      if (widget.index >= matches.length) {
        print('Match index ${widget.index} is out of bounds');
        return;
      }

      final match = matches[widget.index];
      if (match['matchId'] != widget.matchId) {
        print(
            'Match ID mismatch: Expected ${widget.matchId}, found ${match['matchId']}');
        return;
      }

      // Get team IDs, ensure they're not null
      final team1Ids = List<String>.from(match['team1'] ?? []);
      final team2Ids = List<String>.from(match['team2'] ?? []);

      // Only fetch user names if there are team members
      if (team1Ids.isNotEmpty || team2Ids.isNotEmpty) {
        final userNames = await _fetchTeamUserNames(team1Ids, team2Ids);
        setState(() {
          team1 = team1Ids;
          team2 = team2Ids;
          team1UserNames = userNames['team1'] ?? [];
          team2UserNames = userNames['team2'] ?? [];
        });
      } else {
        setState(() {
          team1 = [];
          team2 = [];
          team1UserNames = [];
          team2UserNames = [];
        });
      }
    });
  }

  Future<Map<String, List<String>>> _fetchTeamUserNames(
      List<String> team1Ids, List<String> team2Ids) async {
    Map<String, List<String>> result = {
      'team1': [],
      'team2': [],
    };

    if (team1Ids.isNotEmpty) {
      final team1Snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: team1Ids)
          .get();
      result['team1'] =
          team1Snapshot.docs.map((doc) => doc['first_name'] as String).toList();
    }

    if (team2Ids.isNotEmpty) {
      final team2Snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: team2Ids)
          .get();
      result['team2'] =
          team2Snapshot.docs.map((doc) => doc['first_name'] as String).toList();
    }

    return result;
  }

  Future<void> _updateTeamInFirestore(
      String teamField, List<String> teamUids) async {
    try {
      final eventRef =
          FirebaseFirestore.instance.collection('events').doc(widget.event.id);

      final eventSnapshot = await eventRef.get();
      final matches = List.from(eventSnapshot['matches'] as List);

      if (widget.index >= matches.length) {
        print('Match index ${widget.index} is out of bounds');
        return;
      }

      final match = matches[widget.index];
      if (match['matchId'] != widget.matchId) {
        print(
            'Match ID mismatch: Expected ${widget.matchId}, found ${match['matchId']}');
        return;
      }

      // Update the specific team
      match[teamField] = teamUids;
      matches[widget.index] = match;

      // Update Firestore
      await eventRef.update({'matches': matches});

      // Show success message
      if (context.mounted) {
        toastification.show(
          context: context,
          title: Text('Team updated successfully'),
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error updating teams: $e');
      if (context.mounted) {
        toastification.show(
          context: context,
          title: Text('Error updating team'),
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _removeUser(String uid, String teamField) async {
    try {
      final team = teamField == 'team1' ? team1 : team2;
      team.remove(uid);

      await _updateTeamInFirestore(teamField, team);
    } catch (e) {
      print('Error removing user: $e');
    }
  }

  Widget _buildUserList(
      List<String> teamUserNames, List<String> team, String teamField) {
    // Handle empty list case
    if (teamUserNames.isEmpty || team.isEmpty) {
      return Center(
        child: Text(
          'No users in team',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: teamUserNames.length,
      itemBuilder: (context, index) {
        // Ensure index is within bounds
        if (index >= teamUserNames.length || index >= team.length) {
          return null;
        }
        final name = teamUserNames[index];
        final uid = team[index];
        return TeamUser(
          index: index,
          teamUserNames: name,
          onPressed: () => _removeUser(uid, teamField),
        );
      },
    );
  }

  Widget _buildTeamColumn(String teamName, List<String> teamUserNames,
      List<String> team, String teamField) {
    final width = MediaQuery.sizeOf(context).width * 0.46;

    return Container(
      width: width,
      child: Column(
        children: [
          Container(
            height: 40,
            width: width,
            margin: EdgeInsets.only(bottom: 10, top: 5),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                teamName,
                style: AppFonts.poppins(
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildUserList(teamUserNames, team, teamField),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredMembersView() {
    // Create a set of all assigned users for efficient lookup
    final Set<String> assignedUsers = {...team1, ...team2};

    // Filter out users that are already in teams
    final filteredUsers = registeredUsers.where((user) {
      return !assignedUsers.contains(user.uid);
    }).toList();

    // Handle empty filtered list
    if (filteredUsers.isEmpty) {
      return Center(
        child: Text(
          'All users have been assigned to teams',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return Container(
                height: 70,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 30,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '${user.firstName!} ${user.lastName!}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (selectedUids.contains(user.uid)) {
                            selectedUids.remove(user.uid!);
                          } else {
                            selectedUids.add(user.uid!);
                          }
                        });
                      },
                      child: Container(
                        height: 33,
                        width: 33,
                        decoration: BoxDecoration(
                          color: selectedUids.contains(user.uid)
                              ? Colors.green
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: selectedUids.contains(user.uid)
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Only show buttons if there are users to add
        if (filteredUsers.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAddToTeamButton('Add To Team 1', 'team1'),
              _buildAddToTeamButton('Add To Team 2', 'team2'),
            ],
          ),
      ],
    );
  }

  Widget _buildAddToTeamButton(String label, String teamField) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextButton(
        onPressed: selectedUids.isEmpty
            ? null // Disable button if no users selected
            : () async {
                final currentTeam = teamField == 'team1' ? team1 : team2;
                final updatedTeam = [...currentTeam, ...selectedUids];

                // First update Firestore
                await _updateTeamInFirestore(teamField, updatedTeam);

                // Then clear selection
                if (mounted) {
                  setState(() {
                    selectedUids.clear();
                  });
                }
              },
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey;
            }
            return primaryColor;
          }),
          fixedSize: WidgetStateProperty.all(
            Size(MediaQuery.sizeOf(context).width * 0.42, 55),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Approvals',
            style: AppFonts.poppins(color: Colors.black),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(icon: Icon(Icons.people)),
              Tab(icon: Icon(Icons.group_add)),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : registeredUsers.isEmpty
                ? const Center(child: Text('No users found'))
                : TabBarView(
                    children: [
                      _buildRegisteredMembersView(),
                      Stack(
                        children: [
                          const Center(
                            child: VerticalDivider(
                              indent: 20,
                              endIndent: 20,
                              width: 10,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                _buildTeamColumn(
                                    'Team 1', team1UserNames, team1, 'team1'),
                                const Spacer(),
                                _buildTeamColumn(
                                    'Team 2', team2UserNames, team2, 'team2'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}

class TeamUser extends StatelessWidget {
  const TeamUser({
    super.key,
    required this.index,
    required this.teamUserNames,
    this.onPressed,
  });

  final int index;
  final String teamUserNames;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.46;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 50,
        width: width,
        padding: const EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              '${index + 1}. ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              teamUserNames,
              style: AppFonts.poppins(),
            ),
            const Spacer(),
            IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.cancel, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
