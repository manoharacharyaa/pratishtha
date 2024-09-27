import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';

Widget DealsButton(
    {String? dealName,
      BuildContext? context}
    ){
  return Container(
    padding: EdgeInsets.fromLTRB(5.0,0.0,5.0,0.0),
    child: Column(
      children: [
        GestureDetector(
          onTap: (){
            //print('tap');
          },
          child: Container(
            // width: MediaQuery.of(context).size.width/7,
            width: 140,
            height: 150,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(dealName!, style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: whiteColor,),
                textAlign: TextAlign.center,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: primaryColor,
            ),
          ),
        ),
      ],
    ),
  );
}

