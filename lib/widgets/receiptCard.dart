import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/ewalletModel.dart';
import 'package:pratishtha/models/pointModel.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/dateTimeServices.dart';
import 'package:auto_size_text/auto_size_text.dart';

Widget ReceiptCard(
    {BuildContext? context,
    User? user,
    EWallet? wallet,
    Points? point,
    bool isWallet = true}) {
  //int noOfReceipts = 1;
  //user.registeredEvents.length;

  return GestureDetector(
    onTap: () {
      //print('tap');
    },
    child: Container(
      width: MediaQuery.of(context!).size.width,
      decoration: BoxDecoration(
          //boxShadow: [containerShadow],
          color: whiteColor,
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 10.0),
      //margin: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 2.0, 2.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: AutoSizeText(
                    isWallet ? wallet!.reason! : point!.reason!,
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: blackColor),
                    overflow: TextOverflow.clip,
                    maxLines: 2,
                    //textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                AutoSizeText(
                  isWallet
                      ? getFormattedDateAndTime(wallet!.date!)
                      : getFormattedDateAndTime(point!.date!),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: dullGreyColor,
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 4,
            padding: EdgeInsets.fromLTRB(5.0, 0.0, 10.0, 2.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                  isWallet
                      ? int.parse(wallet!.value!) > 0
                          ? '+ ₹${wallet.value!}'
                          : '- ₹${(-1) * int.parse(wallet.value!)}'
                      : int.parse(point!.value!) > 0
                          ? '+ ₹${point.value!}'
                          : point.value!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isWallet
                        ? int.parse(wallet!.value!) > 0
                            ? positiveColor
                            : negativeColor
                        : int.parse(point!.value!) > 0
                            ? positiveColor
                            : negativeColor,
                    fontSize: 20.0,
                    //fontWeight: FontWeight.bold
                  )
                  //overflow: TextOverflow.clip,
                  ),
            ),
          )
        ],
      ),
    ),
  );
}
