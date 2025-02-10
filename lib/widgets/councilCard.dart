import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/councilModel.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class CouncilCard extends StatelessWidget {
  final Council council;
  final String year;
  CouncilCard({required this.council, required this.year});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
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
                    imageUrl: council.photo != ""
                        ? council.photo
                        : "https://firebasestorage.googleapis.com/v0/b/pratishtha-2021.appspot.com/o/council%2Fdefault.png?alt=media&token=3b3b3b3b-3b3b-3b3b-3b3b-3b3b3b3b3b3b",
                    placeholder: (context, url) => loadingWidget(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      color: blackColor,
                    ),
                  ),
                ),
              ),
              //Spacer(),
              SizedBox(width: 4),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.fill,
                      child: Text(
                        council.name,
                        style: TextStyle(
                          color: blackColor,
                          // fontFamily: kFont,
                          fontWeight: FontWeight.w600,
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.fill,
                      child: Text(
                        council.post,
                        style: TextStyle(
                          color: goldColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: AutoSizeText(
                        '"${council.description.replaceAll("\\n", "\n")}"',
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
      ),
    );
  }
}
