import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/councilModel.dart';
import 'package:pratishtha/models/infoModel.dart';
import 'package:pratishtha/models/teamModel.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/councilCard.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/infoCard.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/pratishthaLogo.dart';
import 'package:pratishtha/widgets/teamCard.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:pratishtha/widgets/aboutUsHeader.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  DatabaseServices databaseServices = DatabaseServices();
  LiquidController? _liquidController;

  List<Team> facultyMembers = [];
  List<Team> appTeamMembers = [];
  List<Team> webTeamMembers = [];

  @override
  void initState() {
    _liquidController = LiquidController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: hamburgerColor,
          backgroundColor: whiteColor,
          title: pratishthaTextLogo(context: context),
          // title: Text(
          //   'Pratishtha',style: TextStyle(
          //   color: primaryColor,
          // ),
          // ),
          centerTitle: true,
        ),
        body: FutureBuilder(
            future: Future.wait([
              databaseServices.getTeamDetails(),
              databaseServices.getCouncilDetails(),
              databaseServices.getInfo()
            ]),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //print("info: ${snapshot.data[2]}");
                return LiquidSwipe(
                    liquidController: _liquidController,
                    slideIconWidget:
                        Icon(Icons.arrow_back_ios_sharp, color: whiteColor),
                    //positionSlideIcon: 0.7,
                    enableSideReveal: true,
                    waveType: WaveType.liquidReveal,
                    pages: [
                      //sakec
                      //pratistha
                      info(infoList: (snapshot.data as List)[2]),

                      //faculty
                      faculty(teamDetails: (snapshot.data as List)[0]),

                      //App team
                      appTeam(teamDetails: (snapshot.data as List)[0]),

                      //Web team
                      webTeam(teamDetails: (snapshot.data as List)[0]),

                      //council
                      council(
                          councilDetails: (snapshot.data as List)[1],
                          year: '2024-2025'),
                      // council2(
                      //     councilDetails: (snapshot.data as List)[1],
                      //     year: '2022-2023'),
                      // council3(
                      //     councilDetails: (snapshot.data as List)[1],
                      //     year: '2023-2024'),
                    ]);
              } else if (snapshot.hasError) {
                debugPrint("council snapshot error: ${snapshot.error}");
                return CustomErrorWidget();
              } else {
                return loadingWidget();
              }
            }),
        //body: Column(),
      ),
    );
  }

  Widget info({List<Info>? infoList}) {
    return Scaffold(
      backgroundColor: goldColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Header(
                head: 'SAKEC',
                color: whiteColor,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height / 1.3,
                child: infoList?.length != 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: infoList?.length,
                        itemBuilder: (context, index) {
                          return InfoCard(info: infoList![index]);
                        })
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget faculty({List<Team>? teamDetails}) {
    facultyMembers.clear();
    facultyMembers.addAll(teamDetails!);
    facultyMembers.removeWhere((teamMember) =>
      ["App Developer", "Website Developer", "Web & App dev Secretary", "Web & App dev Coordinator"].contains(teamMember.position) ||
      teamMember.year == '2024-2025');
    return Scaffold(
      backgroundColor: secondaryColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Header(
                head: 'Faculty',
                color: whiteColor,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height / 1.3,
                child: facultyMembers.length != 0
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2),
                        itemCount: facultyMembers.length,
                        itemBuilder: (context, index) {
                          return TeamCard(teamMember: facultyMembers[index]);
                        })
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appTeam({List<Team>? teamDetails}) {
    appTeamMembers.clear();
    appTeamMembers.addAll(teamDetails!);
    appTeamMembers = teamDetails!
      .where((teamMember) => teamMember.year == '2024-2025' && teamMember.post != null)
      .toList();
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Header(
                head: 'App Team',
                color: whiteColor,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height / 1.3,
                child: appTeamMembers.length != 0
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2),
                        itemCount: appTeamMembers.length,
                        itemBuilder: (context, index) {
                          return TeamCard(teamMember: appTeamMembers[index]);
                        })
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget webTeam({List<Team>? teamDetails}) {
    webTeamMembers.clear();
    webTeamMembers.addAll(teamDetails!);
    webTeamMembers.removeWhere(
        (teamMember) => teamMember.position != "Website Developer");
    return Scaffold(
      backgroundColor: secondaryColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Header(
                head: 'Website Team',
                color: whiteColor,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height / 1.3,
                child: webTeamMembers.length != 0
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2),
                        itemCount: webTeamMembers.length,
                        itemBuilder: (context, index) {
                          return TeamCard(teamMember: webTeamMembers[index]);
                        })
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget council({List<Council>? councilDetails, required String year}) {
    List<Council> filteredCouncils = councilDetails!
      
        .toList();

    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Header(
                head: 'Student Council $year',
                color: whiteColor,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.45,
                child: filteredCouncils.length != 0
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2,
                        ),
                        itemCount: filteredCouncils.length,
                        itemBuilder: (context, index) {
                          return CouncilCard(
                              council: filteredCouncils[index], year: year);
                        },
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget council2({List<Council>? councilDetails, required String year}) {
    List<Council> filteredCouncils = councilDetails!
        .where((council) => council.year == "2022-2023")
        .toList();

    return Scaffold(
      backgroundColor: secondaryColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Header(
                head: 'Student Council $year',
                color: whiteColor,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.45,
                child: filteredCouncils.length != 0
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2,
                        ),
                        itemCount: filteredCouncils.length,
                        itemBuilder: (context, index) {
                          return CouncilCard(
                              council: filteredCouncils[index], year: year);
                        },
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget council3({List<Council>? councilDetails, required String year}) {
    List<Council> filteredCouncils = councilDetails!
        .where((council) => council.year == "2023-2024")
        .toList();

    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Header(
                head: 'Student Council $year',
                color: whiteColor,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.45,
                child: filteredCouncils.length != 0
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2,
                        ),
                        itemCount: filteredCouncils.length,
                        itemBuilder: (context, index) {
                          return CouncilCard(
                              council: filteredCouncils[index], year: year);
                        },
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
