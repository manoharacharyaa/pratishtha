import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/teamModel.dart';

import 'loadingWidget.dart';

class TeamCard extends StatelessWidget {
  TeamCard({this.teamMember});

  Team? teamMember;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: whiteColor, //Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(10.0),
        //boxShadow: [containerShadow]
      ),
      child: Container(
        padding: EdgeInsets.only(right: 10),
        height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width / 2,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CachedNetworkImage(
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      //shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  imageUrl: teamMember!.photo,
                  placeholder: (context, url) => loadingWidget(),
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    teamMember!.name,
                    style: TextStyle(
                      color: blackColor,
                      // fontFamily: kFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 25.0,
                    ),
                  ),
                  Text(
                    teamMember!.position,
                    style: TextStyle(
                      color: goldColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                    ),
                  ),
                  teamMember!.description == "" ? Container() :
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: AutoSizeText(
                      '"${teamMember!.description}"',
                      maxLines: 7,
                      minFontSize: 7,
                      maxFontSize: 12,
                      style: TextStyle(
                        color: greyColor,
                        fontWeight: FontWeight.w600,
                      ),
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
}
