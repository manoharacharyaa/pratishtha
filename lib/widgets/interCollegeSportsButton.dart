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
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF222232),
             radius: MediaQuery.of(context).size.width * 0.09,
            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.05,
                backgroundImage: sportsIcon.image,  
                  backgroundColor: Color(0xFF222232),
                 
                
                ),
               
              
              ],
            ),
          ),
          SizedBox(height: 5),
            AutoSizeText(
              sportsName,
              maxLines: 1,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.sourceSans3(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
        ],
        
      ),
    ),
  );
}