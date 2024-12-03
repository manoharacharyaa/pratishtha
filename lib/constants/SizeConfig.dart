import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidht;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenHeight = _mediaQueryData?.size.height; //707
    screenWidht = _mediaQueryData?.size.width; //411
    blockSizeHorizontal = (screenWidht! / 100); //4.11
    blockSizeVertical = (screenHeight! / 100); //7.07
  }
}
