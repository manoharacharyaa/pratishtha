import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/utils/fonts.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map? swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch as Map<int, Color>);
}

BoxShadow containerShadow = BoxShadow(
  color: Colors.grey[350]!,
  offset: const Offset(
    0.0,
    0.0,
  ),
  blurRadius: 7.0,
  spreadRadius: 2.0,
);

ThemeData mainTheme = ThemeData(
  primarySwatch: createMaterialColor(primaryColor),
  primaryColor: primaryColor,
  cardColor: cardBackgroundColor,
  canvasColor: whiteColor,
  scaffoldBackgroundColor: whiteColor,
  fontFamily: 'Roboto',
  // textTheme: const TextTheme(
  // //
  //   //Card main text
  //   headline1: TextStyle(
  //       fontSize: 20.0,
  //       // fontWeight: FontWeight.bold,
  //       color: blackColor),
  //
  //   //Card Subtext
  //   headline2: TextStyle(
  //     fontSize: 16.0,
  //     // fontWeight: FontWeight.bold,
  //     color: headline2Color,
  //   ),
  //
  //   //Event amount Style
  //   headline3: TextStyle(
  //       fontSize: 50.0,
  //       fontWeight: FontWeight.bold,
  //       color: primaryColor),
  //
  //   //Symbol Style
  //   headline4: TextStyle(
  //       fontSize: 60.0,
  //       color: blackColor),
  //
  //   subtitle1: TextStyle(
  //       fontSize: 24.0,
  //       fontWeight: FontWeight.bold,
  //       color: blackColor),
  // //
  //   bodyText1: TextStyle(
  //     fontSize: 18.0,
  //     // fontWeight: FontWeight.bold,
  //     color: whiteColor,),
  //
  //   bodyText2: TextStyle(
  //       fontSize: 40.0,
  //       // fontWeight: FontWeight.bold,
  //       color: blackColor),
  // //
  //  ),

  iconTheme: IconThemeData(color: iconColor),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: createMaterialColor(primaryColor),
  ).copyWith(secondary: secondaryColor),

  // appBarTheme: AppBarTheme(
  //   titleTextStyle: AppFonts.poppins(),
  // ),
);
