import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:toastification/toastification.dart';

class AprovalPage extends StatefulWidget {
  const AprovalPage({
    super.key,
    required this.event,
    required this.matchId,
  });

  final Event event;
  final String matchId;

  @override
  State<AprovalPage> createState() => _AprovalPageState();
}

class _AprovalPageState extends State<AprovalPage> {
  List<User> registeredUsers = [];
  bool isLoading = true;
  List<int> selectedIndices = [];
  List<String> userIds = [];
  List<String> team1 = [];
  List<String> team2 = [];
  List uid = [];

  bool addedToTeam1 = false;
  bool addedToTeam2 = false;

  Future<List<User>> eventRegisteredUsers() async {
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.id)
        .get();

    if (!eventSnapshot.exists) {
      toastification.show(
        context: context,
        title: Text('Document does not exist'),
        autoCloseDuration: const Duration(seconds: 5),
      );
    }

    List<dynamic> registeredUsersArray = eventSnapshot['registered_users'];

    userIds =
        registeredUsersArray.map((user) => (user)['uid'] as String).toList();

    if (userIds.isEmpty) {
      return [];
    }

    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: userIds)
        .get();

    return userQuery.docs.map((doc) {
      return User.fromMap(doc.data() as Map<String, dynamic>);  
    }).toList();
  }

  void getUsers() async {
    try {
      List<User> users = await eventRegisteredUsers();
      setState(() {
        registeredUsers = users;
        isLoading = false;
      });
      print(userIds);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching users: $e');
    }
  }

  Future<void> updateTeamInFirestore(
      String teamField, List<String> teamUIDs) async {
    try {
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .get();

      if (!eventSnapshot.exists) {
        throw Exception('Event doc do not exist');
      }

      List<dynamic> matches = eventSnapshot['matches'] ?? [];

      int matchIndex =
          matches.indexWhere((match) => match['matchId'] == widget.matchId);

      if (matchIndex != -1) {
        matches[matchIndex][teamField] = teamUIDs;

        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.event.id)
            .update({'matches': matches});

        print('$teamField updated sucessfully for matchId ${widget.matchId}');
      } else {
        print("Match with matchId: ${widget.matchId} not found");
      }
    } catch (e) {
      print("Error updating teams: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getUsers();
    print(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.46;
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Approvals'),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.people),
              ),
              Tab(
                icon: Icon(Icons.group_add),
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : registeredUsers.isEmpty
                ? Center(child: Text('No users found'))
                : TabBarView(
                    children: [
                      registeredMembersView(),
                      Container(
                        child: Stack(
                          children: [
                            Center(
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
                                  Container(
                                    width: width,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: width,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Team 1',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: team1.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                child: Container(
                                                  height: 50,
                                                  width: width,
                                                  decoration: BoxDecoration(
                                                    color: secondaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      team1[index],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.46,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: width,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Team 2',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: team2.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                child: Container(
                                                  height: 50,
                                                  width: width,
                                                  decoration: BoxDecoration(
                                                    color: secondaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      team2[index],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Column registeredMembersView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: registeredUsers.length,
            itemBuilder: (context, index) {
              final user = registeredUsers[index];
              final isInTeam1 = team1.contains(user.uid);
              final isInTeam2 = team2.contains(user.uid);
              return Container(
                height: 70,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 30,
                          color: primaryColor,
                        ),
                        SizedBox(width: 20),
                        Text(
                          '${user.firstName!} ${user.lastName!}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    isInTeam1 || isInTeam2
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                if (isInTeam1) {
                                  team1.remove(user.uid);
                                } else if (isInTeam2) {
                                  team2.remove(user.uid);
                                }
                                selectedIndices.remove(index);
                                uid.remove(user.uid);
                              });
                              print(team1);
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 28,
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              setState(() {
                                if (selectedIndices.contains(index) &&
                                    uid.contains(user.uid)) {
                                  selectedIndices.remove(index);
                                  uid.remove(user.uid!);
                                } else {
                                  selectedIndices.add(index);
                                  uid.add(user.uid!);
                                }
                              });
                              print(team1);
                            },
                            child: Container(
                              height: 33,
                              width: 33,
                              decoration: BoxDecoration(
                                color: selectedIndices.contains(index)
                                    ? Colors.green
                                    : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: selectedIndices.contains(index)
                                  ? Icon(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: () async {
                  setState(() {
                    team1.addAll(uid.map((e) => e as String).toList());
                    selectedIndices.clear();
                    uid.clear();
                  });
                  await updateTeamInFirestore("team1", team1);
                  print(team1);
                },
                child: Text(
                  'Add To Team 1',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    primaryColor,
                  ),
                  fixedSize: WidgetStatePropertyAll(
                    Size(MediaQuery.sizeOf(context).width * 0.45, 55),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: () async {
                  setState(() {
                    team2.addAll(uid.map((e) => e as String).toList());
                    selectedIndices.clear();
                    uid.clear();
                  });
                  await updateTeamInFirestore("team2", team2);
                  print(team2);
                },
                child: Text(
                  'Add To Team 2',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    primaryColor,
                  ),
                  fixedSize: WidgetStatePropertyAll(
                    Size(MediaQuery.sizeOf(context).width * 0.45, 55),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Widget customDropdownButton({
//   required String selectedTeam,
//   required void Function(String?) onChanged,
// }) {
//   List<String> teams = ['team1', 'team2'];
//   return DropdownButton(
//     value: selectedTeam,
//     onChanged: onChanged,
//     items: teams
//         .map((team) => DropdownMenuItem(
//               value: team,
//               child: Text(
//                 team,
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ))
//         .toList(),
//   );
// }
