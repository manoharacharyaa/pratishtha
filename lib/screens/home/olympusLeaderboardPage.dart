// import 'dart:js';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/errorWidget.dart';

import '../../constants/colors.dart';
import '../../constants/style.dart';

class olympusLeaderboardPage extends StatefulWidget {
  const olympusLeaderboardPage();

  @override
  State<olympusLeaderboardPage> createState() => _olympusLeaderboardPageState();
}

class _olympusLeaderboardPageState extends State<olympusLeaderboardPage> {
  List<String> winnerBadgeAssets = [
    "assets/gifs/trophy_burst_animation.gif"
        "assets/gifs/medallion_burst_animation.gif"
  ];
  GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
  List<DocumentSnapshot> documentsAll = [];
  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: RefreshIndicator(
        key: _refresh,
        onRefresh: () async {
          // FirebaseFirestore.instance
          //       .collection('fests')
          //       .doc('RrmhEXrMQR5HyI4mdddc')
          //       .collection('teams')
          //       .where('score', isGreaterThan: 0)
          //       .orderBy('score', descending: true)
          //       .get().then((value){
          //         documentsAll = value.docs;
          // });
          setState(() {});
          return Future.delayed(Duration(seconds: 1));
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Leaderboard',
              style: TextStyle(
                color: blackColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: whiteColor,
            elevation: 0,
            iconTheme: IconThemeData(
              color: blackColor,
            ),
          ),
          body: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('fests')
                .doc('2a95253317c848e7bddfe4a99ec38f4a')
                .collection('teams')
                .where('score')
                .orderBy('score', descending: true)
                .get(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
              if (snapshots.hasError) {
                return Center(
                  child: CustomErrorWidget(),
                );
              }

              if (snapshots.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }
              if (snapshots.data!.docs.isEmpty) {
                return SingleChildScrollView(
                  child: Scaffold(
                    body: Center(
                      child: Text(
                        'No Winners Yet',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }
              try {
                int flag = 1;
                if (snapshots.hasData) {
                  documentsAll = snapshots.data!.docs;
                  List<DocumentSnapshot> documents = [];
                  documentsAll.forEach((doc) {
                    if (doc['soft_delete'] == false) {
                      documents.add(doc);
                    }
                  });
                  return (documents.length == 0)
                      ? Center(
                          child: Text(
                            'No Winners Found',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : Scaffold(
                          body: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Container(
                                //   padding: EdgeInsets.only(
                                //     // left: SizeConfig.blockSizeHorizontal * 5,
                                //     // right: SizeConfig.blockSizeHorizontal * 5,
                                //     // top: SizeConfig.blockSizeVertical * 5,

                                //     left: 20,
                                //     right: 20,
                                //     top: 20,
                                //   ),
                                //   child: Column(

                                //     children: [

                                //       Row(
                                //         mainAxisAlignment: MainAxisAlignment.center,
                                //         children: [
                                //           SizedBox(
                                //             width: 75,
                                //           ),
                                //           leaderboardCard(
                                //             name: "BE-IT",
                                //             score: "22",
                                //             rank: 1
                                //           ),
                                //           SizedBox(
                                //             width: 75,
                                //           ),
                                //         ],
                                //       ),
                                //       SizedBox(
                                //         height: 8,
                                //       ),
                                //       Row(
                                //         mainAxisAlignment: MainAxisAlignment.center,
                                //         crossAxisAlignment: CrossAxisAlignment.center,

                                //         children: [
                                //           leaderboardCard(
                                //               name: "BE-COMPS",
                                //               score: "12",
                                //             rank: 2
                                //           ),
                                //           SizedBox(
                                //             width: 10,
                                //           ),
                                //           leaderboardCard(
                                //               name: "BE-EXTC",
                                //               score: "2",
                                //             rank: 3
                                //           ),
                                //         ],
                                //       )
                                //     ],
                                //   ),
                                // ),
                                ListView.builder(
                                  itemCount: documents.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  addAutomaticKeepAlives: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    debugPrint(
                                        "LEADERBORDS DOCS: ${documents}");
                                    debugPrint(
                                        "LEADERBORDS DOCS INDEX: ${index}");

                                    if (index < 3) {
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            // left: SizeConfig.blockSizeHorizontal * 5,
                                            // right: SizeConfig.blockSizeHorizontal * 5,
                                            // top: SizeConfig.blockSizeVertical * 5,

                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                16,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                16,
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                34,
                                          ),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                index == 0
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                10,
                                                          ),
                                                          leaderboardCard(
                                                              name:
                                                                  "${documents[index]['name']}",
                                                              score:
                                                                  "${documents[index]['score']}",
                                                              rank: 1,
                                                              context: context),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                10,
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                                documents.length == 2 &&
                                                        index >= 1
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          leaderboardCard(
                                                              name:
                                                                  "${documents[index]['name']}",
                                                              score:
                                                                  "${documents[index]['score']}",
                                                              rank: 2,
                                                              context: context),
                                                        ],
                                                      )
                                                    : documents.length >= 3 &&
                                                            index >= 2
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            // SizedBox(width:4 ,),
                                                            children: [
                                                              leaderboardCard(
                                                                  name:
                                                                      "${documents[index - 1]['name']}",
                                                                  score:
                                                                      "${documents[index - 1]['score']}",
                                                                  rank: 2,
                                                                  context:
                                                                      context),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    25,
                                                              ),
                                                              leaderboardCard(
                                                                  name:
                                                                      "${documents[index]['name']}",
                                                                  score:
                                                                      "${documents[index]['score']}",
                                                                  rank: 3,
                                                                  context:
                                                                      context),
                                                            ],
                                                          )
                                                        : Container()
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          Divider(),
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Card(
                                              margin: EdgeInsets.only(
                                                  left: 10,
                                                  right: 20,
                                                  bottom: 5),
                                              color: whiteColor,
                                              elevation: 0,
                                              // shape: RoundedRectangleBorder(
                                              //   side: new BorderSide(
                                              //     color: blackColor,
                                              //     width: 1.0,
                                              //   ),
                                              //   borderRadius: BorderRadius.circular(
                                              //     8.0,
                                              //   ),
                                              // ),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    title: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${documents[index]['name']}"
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        // SizedBox(
                                                        //   width: 20,
                                                        // ),
                                                        LinearProgressIndicator(
                                                          backgroundColor:
                                                              primaryColor
                                                                  .withOpacity(
                                                                      0.4),
                                                          value: double.parse(
                                                                  "${documents[index]['score']}") /
                                                              double.parse(
                                                                  "${documents[0]['score']}"),
                                                        ),
                                                        Text(
                                                          "Score : ${documents[index]['score']}",
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          // textAlign: TextAlign.right,
                                                        )
                                                      ],
                                                    ),
                                                    // leading: CircleAvatar(
                                                    //   radius: 25,
                                                    //   backgroundColor: Colors.transparent,
                                                    //   child: Image.asset(
                                                    //     winnerBadgeAssets[index],
                                                    //   ),
                                                    // ),
                                                    leading: CircleAvatar(
                                                      radius: 20,
                                                      backgroundColor:
                                                          blackColor,
                                                      // backgroundImage: AssetImage(
                                                      //     "assets/gifs/medallion_burst_animation.gif"
                                                      //     // (index==0||index==2||index==3)?
                                                      //     // "assets/gifs/trophy_burst_animation.gif":"assets/gifs/medallion_burst_animation.gif"
                                                      //     ),
                                                      child: Text(
                                                        "${index + 1}",
                                                        style: TextStyle(
                                                            color: whiteColor),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  // Divider(height: ,)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                Divider(),
                              ],
                            ),
                          ),
                        );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              } catch (e) {
                debugPrint("LOCAL LEADERBOARD ERROR: $e");
                return Scaffold(
                  body: Center(
                    child: Text(
                      'Try Again.',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

Widget leaderboardCard(
    {required String name,
    required String score,
    String matchesWon = "",
    required int rank,
    required BuildContext context}) {
  return Flexible(
    child: Container(
      //height: rank == 1 ? SizeConfig.blockSizeVertical*19 : SizeConfig.blockSizeVertical*15 ,
      height: (rank == 1)
          ? MediaQuery.of(context).size.height / 5
          : MediaQuery.of(context).size.height / 7,
      width: rank == 1
          ? MediaQuery.of(context).size.height / 2
          : MediaQuery.of(context).size.height / 4,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          color: rank == 1
              ? goldColor
              : rank == 2
                  ? Colors.grey
                  :
                  // Colors.orange,
                  Colors.brown),
      child: Row(
        mainAxisAlignment:
            rank == 1 ? MainAxisAlignment.start : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: rank == 1
                  ? MediaQuery.of(context).size.width / 40
                  : MediaQuery.of(context).size.width / 75,
              // right: SizeConfig.blockSizeHorizontal! * 1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: rank == 1
                        ? MediaQuery.of(context).size.width / 30
                        : MediaQuery.of(context).size.width / 70),
                CircleAvatar(
                  radius: (rank == 1)
                      ? MediaQuery.of(context).size.width / 13
                      : MediaQuery.of(context).size.width / 18,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage((rank == 1)
                          ? 'assets/gifs/trophy_burst_animation.gif'
                          : "assets/gifs/medallion_burst_animation.gif"
                      // (index==0||index==2||index==3)?
                      // "assets/gifs/trophy_burst_animation.gif":"assets/gifs/medallion_burst_animation.gif"
                      ),
                ),
                // Image.asset(true ? 'assets/gifs/trophy_burst_animation.gif' : rank == 1 ? 'assets/gold.png' :
                //   rank == 2 ? 'assets/silver.png' :
                //   'assets/bronze.png',
                //   height: rank==1 ? 44 : 30.8 ,
                //   //width: SizeConfig.blockSizeHorizontal!*1,
                // ),

                SizedBox(
                    width: rank == 1
                        ? MediaQuery.of(context).size.width / 40
                        : MediaQuery.of(context).size.width / 110),
                VerticalDivider(
                  //width: 17,
                  thickness: 5,
                  color: Colors.white,
                ),
                SizedBox(
                    width: rank == 1
                        ? MediaQuery.of(context).size.width / 30
                        : MediaQuery.of(context).size.width / 70),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      "${name}".toUpperCase(),
                      //overflow: TextOverflow.clip,
                      minFontSize: 8,
                      maxLines: 1,
                      style: kPoppinsSemiBold.copyWith(
                        color: kWhite,
                        fontSize: rank == 1
                            ? MediaQuery.of(context).size.height / 35
                            : MediaQuery.of(context).size.height / 65,
                      ),
                    ),
                    AutoSizeText(
                      "Score: $score",
                      minFontSize: 7,
                      maxLines: 1,
                      style: kPoppinsRegular.copyWith(
                        color: kWhite,
                        fontSize: rank == 1
                            ? MediaQuery.of(context).size.height / 45
                            : MediaQuery.of(context).size.height / 75,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
