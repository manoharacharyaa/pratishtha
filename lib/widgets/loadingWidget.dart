import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:loading_indicator/loading_indicator.dart';

Widget loadingWidget() {
  return Container(
    padding: EdgeInsets.all(10),
    width: 200,
    alignment: Alignment.center,
    child: LoadingIndicator(
        indicatorType: Indicator.pacman, /// Required, The loading type of the widget
        colors: const [primaryColor, secondaryColor, purpleAccentColor, goldColor],       /// Optional, The color collections
        strokeWidth: 1,                     /// Optional, The stroke of the line, only applicable to widget which contains line
        pathBackgroundColor: blackColor   /// Optional, the stroke backgroundColor
    ),
  );
}
