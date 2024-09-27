import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/models/sponsorshipsModel.dart';
import 'package:pratishtha/screens/admin/addSponsorship.dart';
import 'package:pratishtha/screens/rules/manageSponsorshipRulesPage.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/funcLoading.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/rulesCard.dart';

class ManageSponsorship extends StatefulWidget {
  const ManageSponsorship();

  @override
  _ManageSponsorshipState createState() => _ManageSponsorshipState();
}

class _ManageSponsorshipState extends State<ManageSponsorship> {
  DatabaseServices db = DatabaseServices();
  GlobalKey<RefreshIndicatorState> rf = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: RefreshIndicator(
        key: rf,
        onRefresh: () {
          setState(() {});
          return Future.delayed(
            Duration(seconds: 1),
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Manage Sponsorships"),
            actions: [
              rulesIconButton(
                  context: context, popUpPage: ManageSponsorshipRulesPage())
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddSponsorship()));
            },
          ),
          body: FutureBuilder<List<Sponsorship>>(
            future: db.getSponsors(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          data[index].name!,
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          data[index].description +
                              "\nContribution:  " +
                              data[index].value.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),

                        trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                          "Are you sure you want to delete this sponsor Details"),
                                      content: Text(
                                          "This will delete the data permanantly"),
                                      actions: [
                                        TextButton(
                                          child: Text("Continue"),
                                          onPressed: () async {
                                            LoadingFunc.show(context);
                                            await db.deleteSponsor(data[index]);
                                            // await db.updateSponsor({
                                            //   "soft_delete": true,
                                            // }, data[index].id);
                                            LoadingFunc.end();
                                            rf.currentState?.show();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },
                            icon: Icon(
                              FontAwesomeIcons.trashAlt,
                              color: Colors.black,
                              size: 20,
                            )),

                        // Text(
                        //   data[index].value.toString(),
                        //   style: TextStyle(fontSize: 20),
                        // ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddSponsorship(
                                        sponsor: data[index],
                                      )));
                        },
                      ),
                    );
                  },
                );
              } else
                return loadingWidget();
            },
          ),
        ),
      ),
    );
  }
}
