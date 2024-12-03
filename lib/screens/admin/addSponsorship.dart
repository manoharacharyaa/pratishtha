import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/sponsorshipsModel.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/services/storageServices.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/customTextField.dart';
import 'package:pratishtha/widgets/funcLoading.dart';
import 'package:uuid/uuid.dart';

class AddSponsorship extends StatefulWidget {
  final Sponsorship? sponsor;
  AddSponsorship({this.sponsor});

  @override
  _AddSponsorshipState createState() => _AddSponsorshipState();
}

class _AddSponsorshipState extends State<AddSponsorship> {
  DatabaseServices db = DatabaseServices();
  StorageServices cs = StorageServices();

  final TextEditingController name = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController value = TextEditingController();
  File? fBanner;
  File? fLogo;
  String? ibanner;
  String? iLogo;
  bool isBanner = false;
  bool isLogo = false;

  GlobalKey<FormState> form = GlobalKey<FormState>();

  @override
  void initState() {
    name.text = widget.sponsor!.name!;
    description.text = widget.sponsor!.description;
    value.text = widget.sponsor!.value.toString();
    if (widget.sponsor!.imgUrl != "") {
      ibanner = widget.sponsor!.imgUrl;
      setState(() {
        isBanner = true;
      });
    }
    if (widget.sponsor!.logoUrl != "") {
      iLogo = widget.sponsor!.logoUrl;
      setState(() {
        isLogo = true;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.sponsor == null
              ? "Add Sponsorship"
              : "Update Sponsorship"),
        ),
        body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Form(
              key: form,
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  CustomTextField1(
                    controller: name,
                    hintText: 'Enter Sponsor Name',
                    labelText: 'Sponsor Name',
                    validator: isEmptycheck,
                    labelStyle: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  CustomTextField1(
                    controller: description,
                    hintText: 'Enter Sponsor Description',
                    labelText: 'Sponsor Description',
                    validator: isEmptycheck,
                    labelStyle: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  CustomTextField1(
                    controller: value,
                    hintText: 'Enter Value',
                    labelText: 'Sponsor Value',
                    validator: isEmptycheck,
                    labelStyle: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  StatefulBuilder(builder: (context, ss) {
                    return Column(
                      children: [
                        InkWell(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              //color: Colors.blue
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: primaryColor,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  isBanner ? "Change Banner" : "Add Banner",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor),
                                ),
                              ],
                            ),
                          ),
                          onTap: () async {
                            fBanner = await cs.pickImage();
                            ss(() {
                              isBanner = true;
                              ibanner = "";
                            });
                          },
                        ),
                        isBanner
                            ? ibanner != ""
                                ? AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.network(ibanner!))
                                : AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.file(fBanner!))
                            : Container(),
                      ],
                    );
                  }),
                  StatefulBuilder(builder: (context, ss) {
                    return Column(
                      children: [
                        InkWell(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              //color: Colors.blue
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: primaryColor,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  isBanner ? "Change Logo" : "Add Logo",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor),
                                ),
                              ],
                            ),
                          ),
                          onTap: () async {
                            fLogo = await cs.pickImage();
                            ss(() {
                              isLogo = true;
                              iLogo = "";
                            });
                          },
                        ),
                        isLogo
                            ? iLogo != ""
                                ? AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.network(iLogo!))
                                : AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.file(fLogo!))
                            : Container(),
                      ],
                    );
                  }),
                  InkWell(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor),
                      alignment: Alignment.center,
                      child: Text(
                        widget.sponsor == null
                            ? "Add Sponsor"
                            : "Update Sponsor",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: whiteColor),
                      ),
                    ),
                    onTap: () async {
                      if (form.currentState!.validate()) {
                        LoadingFunc.show(context);
                        if (widget.sponsor == null) {
                          await addSponsor();
                        } else {
                          await updateSponsor();
                        }
                        LoadingFunc.end();
                      }
                    },
                  )
                ],
              ),
            )),
      ),
    );
  }

  addSponsor() async {
    var uid = Uuid();
    String id = uid.v4().split("-").join("");
    double val;
    try {
      val = double.parse(value.text);
      if (isBanner) {
        ibanner = await cs.uploadSponsorImage(
            'Banner_${name.text.trim().replaceAll(" ", "_")}-${DateTime.now().year}',
            fBanner!,
            false);
      }
      if (isLogo) {
        iLogo = await cs.uploadSponsorImage(
            'Logo_${name.text.trim().replaceAll(" ", "_")}-${DateTime.now().year}',
            fLogo!,
            true);
      }
    } catch (e) {
      //print(e);
      val = 0.0;
    }
    Sponsorship sponsor = Sponsorship(
        id: id,
        name: name.text.trim(),
        description: description.text.trim(),
        value: val,
        imgUrl: ibanner!,
        softDelete: false,
        logoUrl: iLogo!);

    db.addSponsor(sponsor, id);
    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: "Sponsor Added Successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  updateSponsor() async {
    double val;
    try {
      val = double.parse(value.text);
      if (isBanner) {
        ibanner = await cs.uploadSponsorImage(
            'Banner_${name.text.trim().replaceAll(" ", "_")}-${DateTime.now().year}',
            fBanner!,
            false);
      }
      if (isLogo) {
        iLogo = await cs.uploadSponsorImage(
            'Logo_${name.text.trim().replaceAll(" ", "_")}-${DateTime.now().year}',
            fLogo!,
            true);
      }
    } catch (e) {
      //print(e);
      val = 0.0;
    }
    Map<String, dynamic> sponsor = {
      //"id": widget.sponsor.id,
      "name": name.text.trim(),
      "description": description.text.trim(),
      "value": val,
      "img_url": ibanner,
      "soft_delete": false,
      "logo_url": iLogo
    };

    db.updateSponsor(sponsor, widget.sponsor!.id!);
    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: "Sponsor Updated Successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}

String? isEmptycheck(i) {
  if (i == null || i == "") {
    return "Field Cannot be Empty";
  }
  return null;
}

//   String id;
//   String name;
//   String description;
//   double value;
//   String imgUrl;
//   String logoUrl;