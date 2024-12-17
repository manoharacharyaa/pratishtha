import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/walletServices.dart';
import 'package:pratishtha/widgets/balanceCard.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/receiptCard.dart';
import 'package:pratishtha/models/userModel.dart';

class WalletPage extends StatefulWidget {
  String? userId;
  WalletPage({this.userId});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  var db = DatabaseServices();
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        setState(() {});
        return Future.delayed(
          Duration(seconds: 1),
        );
      },
      child: Scaffold(
          body: SingleChildScrollView(
        child: Center(
          child: FutureBuilder<User>(
              future: db.getSingleUser(this.widget.userId!),
              builder: (context, snap) {
                if (snap.hasData) {
                  var data = snap.data;
                  List walletHistory = data!.walletHistory!.reversed.toList();
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
                          margin: MediaQuery.of(context).padding,
                          child: BalanceCard(
                            balValue: data.wallet,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 5.0),
                        //   child: Text('Pocket Friendly Fest',
                        //       style: TextStyle(
                        //           fontSize: 24.0,
                        //           fontWeight: FontWeight.bold,
                        //           color: blackColor),
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
                        // const SizedBox(
                        //   height: 10,
                        // ),

                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(30.0, 10.0, 10.0, 0.0),
                          child: Text('Payment History',
                              style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: blackColor),
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.left),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        walletHistory.length == 0
                            ? Center(
                                child: Text(
                                  "You do not have any wallet history yet",
                                  style: TextStyle(color: blackColor),
                                ),
                              )
                            : Container(
                                padding:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                margin: MediaQuery.of(context).padding,
                                //height: 210,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: walletHistory.length,
                                  itemBuilder: (context, index) {
                                    return FutureBuilder(
                                        future: WalletServices().getWalletHist(
                                            walletHistory[index]),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Column(
                                              children: [
                                                ReceiptCard(
                                                  context: context,
                                                  user: data,
                                                  wallet: snapshot.data,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, right: 20),
                                                  child: Divider(
                                                    thickness: 1,
                                                    height: 2,
                                                  ),
                                                )
                                              ],
                                            );
                                          } else if (snapshot.hasError) {
                                            return CustomErrorWidget();
                                          } else {
                                            return Center(
                                              child: loadingWidget(),
                                            );
                                          }
                                        });
                                  },
                                  scrollDirection: Axis.vertical,
                                ),
                              ),
                      ]);
                } else if (snap.hasError) {
                  return CustomErrorWidget();
                } else {
                  return loadingWidget();
                }
              }),
        ),
      )),
    );
  }
}
