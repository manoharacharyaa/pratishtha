import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/sponsorshipsModel.dart';
import 'package:pratishtha/widgets/comingSoonWidget.dart';

class SponsorCard extends StatelessWidget {
  Sponsorship? sponsorship;
  BuildContext? context;
  SponsorCard({this.sponsorship, this.context});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
          //margin: EdgeInsets.only(right: 10),
          // width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height/4,
          // decoration: BoxDecoration(
          //   color: cardBackgroundColor,
          //     borderRadius: BorderRadius.circular(20)
          // ),
          child: CachedNetworkImage(
        imageUrl: this.sponsorship!.imgUrl,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 4,
          decoration: BoxDecoration(
              color: blackColor, borderRadius: BorderRadius.circular(20)),
          child: ComingSoonWidget(
              waveColor: primaryColor,
              boxBackgroundColor: blackColor,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60,
                  color: secondaryColor,
                  fontFamily: 'Times New Roman')),
        ),
      )
          // Image(
          //   image: NetworkImage(this.sponsorship.imgUrl),
          //   fit: BoxFit.fitHeight,
          // ),
          ),
    );
  }
}
