import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/screens/rules/editWalletRulesPage.dart';
import 'package:pratishtha/services/searchServices.dart';
import 'package:pratishtha/services/walletServices.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/rulesCard.dart';
import 'package:pratishtha/widgets/userCard.dart';

class EditWallet extends StatefulWidget {
  const EditWallet();

  @override
  _EditWalletState createState() => _EditWalletState();
}

class _EditWalletState extends State<EditWallet> {
  TextEditingController priceTextEditingController = TextEditingController();
  TextEditingController searchTextEditingController = TextEditingController();
  User? selectedUser;
  List<User> searchResultsUsersList = [];

  DatabaseServices databaseServices = DatabaseServices();
  WalletServices walletServices = WalletServices();

  @override
  void initState() {
    super.initState();
    priceTextEditingController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Update Wallet"),
          actions: [
            rulesIconButton(context: context, popUpPage: EditWalletRulesPage())
          ],
        ),
        body: FutureBuilder(
            future: Future.wait([databaseServices.getUsers()]),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child:
                      StatefulBuilder(builder: (context, StateSetter setState) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: TextButton(
                            child: Text(
                              selectedUser == null
                                  ? "+ Select a User"
                                  : "Change Selected User",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 27),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                        builder: (context, ss) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                1.5,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.all(15),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.6,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: dullGreyColor
                                                          .withOpacity(0.2)),
                                                  child: TextFormField(
                                                    controller:
                                                        searchTextEditingController,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          primaryColor)),
                                                      hintText:
                                                          'Search for Users',
                                                      hintStyle: TextStyle(
                                                        color: blackColor,
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      ss(() {
                                                        searchResultsUsersList =
                                                            userSearch(
                                                                query:
                                                                    searchTextEditingController
                                                                        .text,
                                                                allUsersList:
                                                                    snapshot
                                                                        .data[0]);

                                                        selectedUser =
                                                            searchResultsUsersList[
                                                                0];
                                                      });
                                                    },
                                                  ),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      ss(() {
                                                        searchResultsUsersList =
                                                            userSearch(
                                                                query:
                                                                    searchTextEditingController
                                                                        .text,
                                                                allUsersList:
                                                                    snapshot
                                                                        .data[0]);

                                                        selectedUser =
                                                            searchResultsUsersList[
                                                                0];
                                                      });

                                                      // print(
                                                      //     "statebuild: ${tempSearchResults}");
                                                      // // ss(() {
                                                      // //   searchResults =
                                                      // //       tempSearchResults;
                                                      // // });
                                                      // print(
                                                      //     "statebuild bleh: ${tempSearchResults}");
                                                    },
                                                    icon: Icon(
                                                      FontAwesomeIcons.search,
                                                      color: primaryColor,
                                                    )),
                                                IconButton(
                                                    onPressed: () {
                                                      ss(() {
                                                        searchResultsUsersList
                                                            .clear();
                                                        searchTextEditingController
                                                            .clear();
                                                        selectedUser = null;
                                                      });
                                                    },
                                                    icon: Icon(
                                                      FontAwesomeIcons.times,
                                                      color: primaryColor,
                                                    ))
                                              ],
                                            ),
                                            searchResultsUsersList.length == 0
                                                ? Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            3,
                                                    padding: EdgeInsets.only(
                                                        bottom: 20),
                                                    child: Text(
                                                      "You havent searched for anything yet",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  )
                                                : Expanded(
                                                    //height: MediaQuery.of(context).size.height/1.2,
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          searchResultsUsersList
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ListTile(
                                                          title: UserCard(
                                                            user:
                                                                searchResultsUsersList[
                                                                    index],
                                                          ),
                                                          leading: Radio<User>(
                                                            value:
                                                                searchResultsUsersList[
                                                                    index],
                                                            groupValue:
                                                                selectedUser,
                                                            onChanged:
                                                                (User? value) {
                                                              ss(() {
                                                                selectedUser =
                                                                    value;
                                                              });
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                          ],
                                        ),
                                      );
                                    });
                                  }).whenComplete(() {
                                setState(() {});
                              });
                            },
                          ),
                        ),
                        selectedUser == null
                            ? Container()
                            : UserCard(user: selectedUser),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            priceTextEditingController.text == ""
                                ? "0"
                                : priceTextEditingController.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 111,
                                fontWeight: FontWeight.bold,
                                color: blackColor),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      priceTextEditingController
                                          .text = (double.parse(
                                                      priceTextEditingController
                                                          .text)
                                                  .round() -
                                              1)
                                          .toString();
                                    });
                                  },
                                  icon: Icon(FontAwesomeIcons.minus)),
                              Container(
                                margin: EdgeInsets.all(15),
                                width: MediaQuery.of(context).size.width * 0.6 -
                                    30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: dullGreyColor.withOpacity(0.2)),
                                child: TextFormField(
                                  controller: priceTextEditingController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  onSaved: (value) {
                                    if (value == null || value.trim() == "") {
                                      setState(() {
                                        priceTextEditingController.text = "0";
                                      });
                                    } else {
                                      setState(() {});
                                    }
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: primaryColor)),
                                    hintText: 'Enter Price',
                                    hintStyle: TextStyle(
                                      color: whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      priceTextEditingController
                                          .text = (double.parse(
                                                      priceTextEditingController
                                                          .text)
                                                  .round() +
                                              1)
                                          .toString();
                                    });
                                  },
                                  icon: Icon(FontAwesomeIcons.plus)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              if (int.parse(priceTextEditingController.text
                                          .trim()) !=
                                      0 &&
                                  priceTextEditingController.text != "") {
                                if (selectedUser!.isVerified) {
                                  await walletServices.addMoney(
                                      toUid: selectedUser!.uid!,
                                      value: priceTextEditingController.text);
                                  Fluttertoast.showToast(
                                      msg: "Wallet updated succesfully",
                                      toastLength: Toast.LENGTH_LONG);
                                  setState(() {
                                    selectedUser = null;
                                    searchResultsUsersList = [];
                                    priceTextEditingController.text = "0";
                                  });
                                } else if (!selectedUser!.isVerified) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Ask the selected user to verify themselves first",
                                      toastLength: Toast.LENGTH_LONG);
                                }
                              } else if (selectedUser == null) {
                                Fluttertoast.showToast(
                                    msg: "Please select a user first",
                                    toastLength: Toast.LENGTH_LONG);
                              } else if (int.parse(
                                      priceTextEditingController.text) ==
                                  0) {
                                Fluttertoast.showToast(
                                    msg: "Please enter some price first",
                                    toastLength: Toast.LENGTH_LONG);
                              }
                            },
                            child: Text("Update Wallet"))
                      ],
                    );
                  }),
                );
              } else if (snapshot.hasError) {
                //print("editWallet error: ${snapshot.error}");
                return Center(child: CustomErrorWidget());
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
