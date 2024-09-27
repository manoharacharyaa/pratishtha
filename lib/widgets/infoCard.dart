import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/infoModel.dart';

import 'loadingWidget.dart';

class InfoCard extends StatelessWidget {

  Info? info;
  InfoCard({this.info});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        margin: EdgeInsets.only(bottom: 10, top: 10),
        child: Text(
            info!.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          info!.photo != "" ?
          Container(
            margin: EdgeInsets.only(bottom: 10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  imageUrl: info!.photo,
                  placeholder: (context, url) => loadingWidget(),
                ),
              ),
          ) : Container(),
          Text(
              info!.description.replaceAll("\\n", "\n"),
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: whiteColor,
            ),
          )
        ],
      ),
    );
  }
}
