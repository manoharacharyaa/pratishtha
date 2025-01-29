import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget InterCollegeSportsButton({
  required BuildContext context,
  required Image sportsIcon,
  required String sportsName,
  required MaterialPageRoute navigator,
}) {
  return GestureDetector(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.225,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
        color: Color(0xFF222232),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          sportsIcon,
          SizedBox(
            height: MediaQuery.of(context).size.height / 100,
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 8.0), // Add horizontal padding
            child: AutoSizeText(
              sportsName,
              maxLines: 1,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.sourceSans3(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}
