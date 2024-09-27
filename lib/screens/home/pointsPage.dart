import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/pointModel.dart';
import 'package:pratishtha/screens/rules/pointsRulesPage.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/pointServices.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/pointsCard.dart';
import 'package:pratishtha/widgets/pratishthaLogo.dart';
import 'package:pratishtha/widgets/receiptCard.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/widgets/rulesCard.dart';

class PointsPage extends StatefulWidget {

  String? userId;
  PointsPage({this.userId});

  @override
  _PointsPageState createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  var db = DatabaseServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: hamburgerColor,
          backgroundColor: whiteColor,
          actions: [
            rulesIconButton(
                context: context,
                popUpPage: PointsRulesPage()
            )
          ],
          title: pratishthaTextLogo(context: context),
          // title: Text(
          //   'Pratishtha',style: TextStyle(
          //   color: primaryColor,
          // ),
          // ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: FutureBuilder<User>(
                future: db.getUser(this.widget.userId!),
                builder: (context, snap) {
                  if (snap.hasData) {
                    //print("points hist data: ${snap.data}");
                    var data = snap.data;
                    List pointsHistory = data!.pointsHistory!.reversed.toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
                        margin: MediaQuery.of(context).padding,
                        child: PointsCard(
                          pointsValue: data.points,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 5.0),
                      //   child: Text('Pocket Friendly Fest',
                      //       style: mainTheme.textTheme.subtitle1,
                      //       overflow: TextOverflow.clip,
                      //       textAlign: TextAlign.left),
                      // ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // Container(
                      //   padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      //   margin: MediaQuery.of(context).padding,
                      //   height: 160,
                      //   child: ListView(
                      //     scrollDirection: Axis.horizontal,
                      //     children: [
                      //       DealsButton(dealName: '3 Day Pass'),
                      //       DealsButton(dealName: '1 Day Pass'),
                      //       DealsButton(dealName: '3 Game Pass'),
                      //       DealsButton(dealName: '5 Game Pass'),
                      //       DealsButton(dealName: '2 Day Pass'),
                      //       DealsButton(dealName: '10 Game Pass'),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30.0, 10.0, 10.0, 0.0),
                        child: Text('Points History',
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: blackColor),
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.left),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      pointsHistory.length==0 ? Center(child: Text("You do not have any point history yet",style: TextStyle(color: blackColor),),):
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        margin: MediaQuery.of(context).padding,
                        //height: 210,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: pointsHistory.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<Points>(
                                future: PointsServices()
                                    .getpointHist(pointsHistory[index]),
                                builder: (context, snapshot) {

                                  if (snapshot.hasData) {
                                    return Column(
                                      children: [
                                        ReceiptCard(
                                            context: context,
                                            user: data,
                                            point: snapshot.data,
                                            isWallet: false
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                          child: Divider(
                                            thickness: 1,
                                            height: 2,
                                          ),
                                        )
                                      ],
                                    );
                                  }
                                  else if (snapshot.hasError){
                                    //print("points page snapshot error: ${snapshot.error}");
                                    return CustomErrorWidget();
                                  }
                                  else {
                                    return loadingWidget();
                                  }
                                });
                          },
                          scrollDirection: Axis.vertical,
                        ),
                      ),
                    ]);
                  } else {
                    return loadingWidget();
                  }
                }),
          ),
        ));
  }
}
