import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/screens/home/calendarPage.dart';
import 'package:pratishtha/screens/home/homePage.dart';
import 'package:pratishtha/screens/home/profilePage.dart';
import 'package:pratishtha/screens/home/searchPage.dart';
import 'package:pratishtha/screens/rules/homeRulesPage.dart';
import 'package:pratishtha/screens/rules/searchRulesPage.dart';
import 'package:pratishtha/services/authenticationServices.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/widgets/bottomNavyBar.dart';
import 'package:pratishtha/widgets/drawer.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/pratishthaLogo.dart';
import 'package:pratishtha/widgets/rulesCard.dart';
import 'package:provider/src/provider.dart';

class Home extends StatefulWidget {
  int? selectedIndex;
  Home({this.selectedIndex});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int? _selectedIndex;
  PageController? _pageController;
  DatabaseServices databaseServices = DatabaseServices();

  List<Widget> appbarAction() {
    switch (_selectedIndex) {
      case 0:
        return [rulesIconButton(context: context, popUpPage: HomeRulesPage())];

      case 1:
        return [
          rulesIconButton(context: context, popUpPage: SearchRulesPage())
        ];

      case 2:
        return [];

      case 3:
        return [
          IconButton(
            icon: Icon(FontAwesomeIcons.rightFromBracket),
            onPressed: () {
              context.read<AuthenticationService>().signOut();
            },
          )
        ];

      default:
        return [];
    }
  }

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.selectedIndex;
    _pageController = PageController();
    //_pageController.jumpToPage(_selectedIndex);
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _selectedIndex == 0 ? MyDrawer() : null,
      appBar: AppBar(
        foregroundColor: hamburgerColor,
        backgroundColor: whiteColor,
        actions: appbarAction(),
        title: pratishthaTextLogo(context: context),
        // title: Text(
        //   'Pratishtha',style: TextStyle(
        //   color: primaryColor,
        // ),
        // ),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: databaseServices.getCurrentUser(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              return SizedBox.expand(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: <Widget>[
                    HomePage(),
                    CalendarPage(),
                    SearchPage(),
                    ProfilePage(selectedUser: snapshot.data!),
                    // WalletPage(userId: snapshot.data!.uid)
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              //print("navPanel snapshot error: ${snapshot.error}");
              return Center(
                  child: Text(
                      "Oops, something seems to have gone wrong, please try again"));
            } else {
              return Center(
                  child: loadingWidget()); //CircularProgressIndicator();
            }
          }),
      bottomNavigationBar: BottomNavyBar(
          backgroundColor: navBackgroundColor,
          itemCornerRadius: 12,
          selectedIndex: _selectedIndex!,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _pageController!.jumpToPage(_selectedIndex!);
          },
          items: [
            BottomNavyBarItem(
              activeColor: bubbleColor,
              title: Text(
                'Home',
                style: TextStyle(color: unselectedColor),
              ),
              icon: Icon(
                Icons.home,
                color: unselectedColor,
              ),
            ),
            BottomNavyBarItem(
              activeColor: bubbleColor,
              title: Text(
                'Calendar',
                style: TextStyle(color: unselectedColor),
              ),
              icon: Icon(
                Icons.calendar_today_outlined,
                color: unselectedColor,
              ),
            ),
            BottomNavyBarItem(
              activeColor: bubbleColor,
              title: Text(
                'Search',
                style: TextStyle(color: unselectedColor),
              ),
              icon: Icon(
                Icons.search,
                color: unselectedColor,
              ),
            ),
            BottomNavyBarItem(
              activeColor: bubbleColor,
              title: Text(
                'Profile',
                style: TextStyle(color: unselectedColor),
              ),
              icon: Icon(
                Icons.person,
                color: unselectedColor,
              ),
            ),

            // BottomNavyBarItem(
            //     activeColor: bubbleColor,
            //     title: Text(
            //       'Wallet',
            //       style: TextStyle(color: unselectedColor),
            //     ),
            //     icon: Icon(
            //       Icons.account_balance_wallet,
            //       color: unselectedColor,
            //     )
            // ),
          ]),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   backgroundColor: cardBackgroundColor,
      //   // selectedLabelStyle: TextStyle(
      //   //   color: blackColor,
      //   //   // backgroundColor: blackColor,
      //   // ),
      //   //
      //   // unselectedLabelStyle: TextStyle(
      //   //     color: Colors.pink,
      //   // ),
      //   selectedIconTheme: IconThemeData(
      //     color: blackColor,
      //   ),
      //   unselectedIconTheme: IconThemeData(
      //     color: whiteColor,
      //   ),
      //   selectedItemColor: blackColor,
      //   unselectedItemColor: blackColor,
      //   items: <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.home,
      //         // color: blackColor,
      //       ),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.calendar_today_outlined,
      //         // color: blackColor,
      //       ),
      //       label: 'Calendar',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.search,
      //         // color: blackColor,
      //       ),
      //       label: 'Search',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.person,
      //         // color: blackColor,
      //       ),
      //       label: 'Profile',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.account_balance_wallet,
      //         // color: blackColor,
      //       ),
      //       label: 'Wallet',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   //selectedItemColor: Colors.amber[800],
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //     _pageController.jumpToPage(_selectedIndex);
      //   },
      // ),
    );
  }
}
