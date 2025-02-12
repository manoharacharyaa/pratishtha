import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static TextStyle poppins({double? size, FontWeight? weight, Color? color}) {
    return GoogleFonts.poppins(
      fontSize: size ?? 18,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? Colors.black,
    );
  }
}
