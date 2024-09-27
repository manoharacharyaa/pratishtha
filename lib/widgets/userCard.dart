import 'package:flutter/material.dart';
import 'package:pratishtha/constants/avatars.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/screens/home/profilePage.dart';
import 'package:pratishtha/styles/mainTheme.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserCard extends StatefulWidget {
  User? user;
  UserCard({this.user});

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(selectedUser: this.widget.user)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: whiteColor,
          boxShadow: [containerShadow],
          //borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              child: SvgPicture.asset(avatarMap[this.widget.user?.avatar]!),
            ),
            //FluttermojiCircleAvatar(radius: 25),
            SizedBox(width: 10),
            Expanded(
                //width: MediaQuery.of(context).size.width,
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AutoSizeText(
                      '${this.widget.user!.firstName} ${this.widget.user!.lastName}',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: blackColor),
                    ),
                    SizedBox(width: 5),
                    !this.widget.user!.isVerified ? Icon(Icons.warning, color: secondaryColor) :
                    [3,5,6].contains(this.widget.user!.role) ? Icon(Icons.verified, color: primaryColor) : Container()
                  ],
                ),
                AutoSizeText(
                  '${this.widget.user!.institute}',
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: dullGreyColor,
                    fontStyle: FontStyle.italic,
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
