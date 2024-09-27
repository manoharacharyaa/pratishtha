import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/constants/keys.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/widgets/customTextField.dart';
import 'package:pratishtha/widgets/funcLoading.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';

class EditProfile extends StatefulWidget {
  const EditProfile();

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController regNoController =
      TextEditingController(text: "0");
  final TextEditingController smartCardController = TextEditingController();
  final TextEditingController sakecIdController = TextEditingController();
  final TextEditingController rollNoController =
      TextEditingController(text: "0");
  final TextEditingController branchController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController divController = TextEditingController(text: "0");
  final ScrollController scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
  bool isFromSAKEC = false;
  String? branch;
  String? year;
  AsyncMemoizer? _memoizer;
  final DatabaseServices db = DatabaseServices();

  @override
  void initState() {
    _memoizer = AsyncMemoizer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      backgroundColor: whiteColor,
      body: FutureBuilder(
          future: _memoizer?.runOnce(() async => await db.getCurrentUser()),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              User data = snapshot.data as User ;
              emailController.text = data.email!;
              firstNameController.text = data.firstName!;
              lastNameController.text = data.lastName!;
              phoneController.text = data.phone!;
              if (data.institute == "SAKEC") {
                isFromSAKEC = true;
              }
              regNoController.text = data.regNo.toString();
              smartCardController.text = data.smartcardNo;
              sakecIdController.text = data.sakecId;
              rollNoController.text = data.rollNo.toString();
              branchController.text = data.branch;
              branch = data.branch;
              yearController.text = data.year;
              year = data.year;
              divController.text = data.div.toString();

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: buildTextFields(data),
                ),
              );
            } else {
              return Center(
                child: loadingWidget(),
              );
            }
          }),
    );
  }

  buildTextFields(User data) {
    return Column(
      children: [
        CustomTextField1(
          controller: emailController,
          hintText: 'Enter your E-mail',
          //labelText: 'Email',
          labelStyle: TextStyle(
            color: Colors.black87,
          ),
          prefixIcon: Icon(
            FontAwesomeIcons.mailBulk,
            color: headline2Color,
          ),
          keyboardType: TextInputType.emailAddress,
          // ignore: missing_return
          validator: (value) {
            if (value.isEmpty) {
              return "Email cannot be empty";
            } else if (!value.contains('@')) {
              return "Please enter a valid email address";
            }
            return null;
          },
        ),
        // CustomTextField1(
        //   controller: passwordController,
        //   hintText: 'Enter your Password',
        //   //labelText: 'Password',
        //   labelStyle: TextStyle(
        //     color: Colors.black87,
        //   ),
        //   obscureText: true,
        //   prefixIcon: Icon(
        //     FontAwesomeIcons.lock,
        //     color: headline2Color,
        //   ),
        //   // ignore: missing_return
        //   validator: (value) {
        //     // r'^
        //     //   (?=.*[A-Z])       // should contain at least one upper case
        //     //   (?=.*[a-z])       // should contain at least one lower case
        //     //   (?=.*?[0-9])      // should contain at least one digit
        //     //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
        //     //     .{8,}             // Must be at least 8 characters in length
        //     // $
        //     RegExp regex =
        //         RegExp(r'^(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$');
        //     if (value.isEmpty) {
        //       return "Password cannot be empty";
        //     } else if (!regex.hasMatch(value)) {
        //       return "Should contain atleast one digit, one special charecter and must be atleast 6 characters long";
        //     }
        //   },
        // ),
        CustomTextField1(
          controller: firstNameController,
          hintText: 'Enter your First Name',
          //labelText: 'First Name',
          labelStyle: TextStyle(
            color: Colors.black87,
          ),
          prefixIcon: Icon(
            FontAwesomeIcons.userGraduate,
            color: headline2Color,
          ),
          keyboardType: TextInputType.text,
          // ignore: missing_return
          validator: (value) {
            // r'^
            //   (?=.*[A-Z])       // should contain at least one upper case
            //   (?=.*[a-z])       // should contain at least one lower case
            //   (?=.*?[0-9])      // should contain at least one digit
            //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
            //     .{8,}             // Must be at least 8 characters in length
            // $
            RegExp regex = RegExp(r'^[a-zA-Z]+$');
            if (value.isEmpty) {
              return "First Name cannot be empty";
            } else if (!regex.hasMatch(value)) {
              return "The first name should only contain letters";
            }
            return null;
          },
        ),
        CustomTextField1(
          controller: lastNameController,
          hintText: 'Enter your Last Name',
          //labelText: 'Last Name',
          labelStyle: TextStyle(
            color: Colors.black87,
          ),
          keyboardType: TextInputType.name,
          prefixIcon: Icon(
            FontAwesomeIcons.userGraduate,
            color: headline2Color,
          ),
          // ignore: missing_return
          validator: (value) {
            // r'^
            //   (?=.*[A-Z])       // should contain at least one upper case
            //   (?=.*[a-z])       // should contain at least one lower case
            //   (?=.*?[0-9])      // should contain at least one digit
            //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
            //     .{8,}             // Must be at least 8 characters in length
            // $
            RegExp regex = RegExp(r'^[a-zA-Z]+$');
            if (value.isEmpty) {
              return "Last Name cannot be empty";
            } else if (!regex.hasMatch(value)) {
              return "The last name should only contain letters";
            }
            return null;
          },
        ),
        CustomTextField1(
          controller: phoneController,
          hintText: 'Enter your Phone No',
          //labelText: 'Phone No',
          labelStyle: TextStyle(
            color: Colors.black87,
          ),
          prefixIcon: Icon(
            FontAwesomeIcons.phoneAlt,
            color: headline2Color,
          ),
          keyboardType: TextInputType.number,
          // ignore: missing_return
          validator: (value) {
            if (value.isEmpty) {
              return "Phone number cannot be empty";
            } else if (value.length != 10) {
              return "Phone number should be 10 digits long";
            }
            return null;
          },
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text(
        //       "Are you from SAKEC?",
        //       style: TextStyle(
        //         fontSize: 16,
        //       ),
        //     ),
        //     Switch(
        //         value: isFromSAKEC,
        //         onChanged: (val) {
        //           setState(() {
        //             isFromSAKEC = val;
        //           });
        //           if (!val) {
        //             regNoController.text = "0";
        //             rollNoController.text = "0";
        //             divController.text = "0";
        //           } else {
        //             regNoController.text = "";
        //             rollNoController.text = "";
        //             divController.text = "";
        //           }
        //         }),
        //   ],
        // ),

        //institute
        // CustomTextField1(
        //     controller: instituteController,
        //     hintText: 'Enter your Institute',
        //     //labelText: 'Institute',
        //     labelStyle: TextStyle(
        //       color: Colors.black87,
        //     ),
        //     prefixIcon: Icon(
        //       FontAwesomeIcons.university,
        //       color: headline2Color,
        //     ),
        //     keyboardType: TextInputType.text,
        //     onChanged: (value) {
        //       if (value.toString().toUpperCase() == "SAKEC") {
        //         isFromSAKEC = true;
        //         instituteController.clear();
        //         setState(() {});
        //       }
        //     },
        //     // ignore: missing_return
        //     validator: (value) {
        //       // r'^
        //       //   (?=.*[A-Z])       // should contain at least one upper case
        //       //   (?=.*[a-z])       // should contain at least one lower case
        //       //   (?=.*?[0-9])      // should contain at least one digit
        //       //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
        //       //     .{8,}             // Must be at least 8 characters in length
        //       // $
        //       RegExp regex =
        //           RegExp(r'^[A-Za-z0-9_. ]+$'); //r'^[a-zA-Z0-9]+$'
        //       if (value.isEmpty) {
        //         return "Institute cannot be empty";
        //       } else if (!regex.hasMatch(value)) {
        //         return "Please enter a valid Institute Name";
        //       }
        //     },
        //   )
        !isFromSAKEC
            ? SizedBox.shrink()
            : Column(children: [
                CustomTextField1(
                  controller: regNoController,
                  hintText: 'Enter your Registration No',
                  //labelText: 'Registration No',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                  prefixIcon: Icon(
                    FontAwesomeIcons.idCard,
                    color: headline2Color,
                  ),
                  keyboardType: TextInputType.number,
                  // ignore: missing_return
                  validator: (value) {
                    // r'^
                    //   (?=.*[A-Z])       // should contain at least one upper case
                    //   (?=.*[a-z])       // should contain at least one lower case
                    //   (?=.*?[0-9])      // should contain at least one digit
                    //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
                    //     .{8,}             // Must be at least 8 characters in length
                    // $
                    RegExp regex = RegExp(r'^[0-9]+$');
                    if (value.isEmpty) {
                      return "Registration number cannot be empty";
                    } else if (!regex.hasMatch(value)) {
                      return "Please enter a valid registration number";
                    } else if (value.length != 5) {
                      return "The registration number should be 5 digits long";
                    }
                    return null;
                  },
                ),
                CustomTextField1(
                  controller: smartCardController,
                  hintText: 'Enter your Smart Card No',
                  //labelText: 'Smart Card No',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                  prefixIcon: Icon(
                    FontAwesomeIcons.idCard,
                    color: headline2Color,
                  ),
                ),
                CustomTextField1(
                  controller: sakecIdController,
                  hintText: 'Enter your Sakec Id',
                  //labelText: 'Sakec Id',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                  prefixIcon: Icon(
                    FontAwesomeIcons.mailBulk,
                    color: headline2Color,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  // ignore: missing_return
                  validator: (value) {
                    // r'^
                    //   (?=.*[A-Z])       // should contain at least one upper case
                    //   (?=.*[a-z])       // should contain at least one lower case
                    //   (?=.*?[0-9])      // should contain at least one digit
                    //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
                    //     .{8,}             // Must be at least 8 characters in length
                    // $
                    if (value.isEmpty) {
                      return "SAKEC Id cannot be empty";
                    } else if (!value.toString().contains("@sakec.ac.in")) {
                      return "Please enter a valid SAKEC Id";
                    }
                    return null;
                  },
                ),
                CustomTextField1(
                  controller: rollNoController,
                  hintText: 'Enter your Roll No',
                  //labelText: 'Roll no',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                  prefixIcon: Icon(
                    FontAwesomeIcons.userCircle,
                    color: headline2Color,
                  ),
                  keyboardType: TextInputType.number,
                  // ignore: missing_return
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Roll No cannot be empty";
                    }
                    return null;
                  },
                ),

                StatefulBuilder(builder: (context, ss) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.2),
                        )),
                    child: DropdownButton<String>(
                      underline: const SizedBox(),
                      isExpanded: true,
                      value: branch,
                      borderRadius: BorderRadius.circular(15),
                      elevation: 5,
                      icon: Icon(FontAwesomeIcons.chevronDown),
                      style: const TextStyle(color: Colors.black),
                      iconEnabledColor: headline2Color,
                      items:
                          Branch.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        );
                      }).toList(),
                      selectedItemBuilder: (context) {
                        return Branch.map((e) {
                          return Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.codeBranch,
                                color: headline2Color,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Text(
                                e,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                      hint: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.codeBranch,
                            color: headline2Color,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          const Text(
                            "Select Branch",
                            style: TextStyle(
                              color: headline2Color,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      onChanged: (String? value) {
                        ss(() {
                          branch = value ?? '';
                        });
                        //print(parentId);
                      },
                    ),
                  );
                }),
                StatefulBuilder(builder: (context, ss) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.2),
                        )),
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(15),
                    //     border: Border.all(
                    //       color: Colors.black.withOpacity(0.2),
                    //       style: BorderStyle.solid,
                    //       width: 1.5,
                    //     )),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    child: DropdownButton<String>(
                      underline: const SizedBox(),
                      isExpanded: true,
                      value: year,
                      borderRadius: BorderRadius.circular(15),
                      elevation: 5,
                      icon: Icon(FontAwesomeIcons.chevronDown),
                      style: const TextStyle(color: Colors.black),
                      iconEnabledColor: headline2Color,
                      items: Year.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        );
                      }).toList(),
                      selectedItemBuilder: (context) {
                        return Year.map((e) {
                          return Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.userCircle,
                                color: headline2Color,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Text(
                                e,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                      hint: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.userCircle,
                            color: headline2Color,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          const Text(
                            "Select Year",
                            style: TextStyle(
                              color: headline2Color,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      onChanged: (String? value) {
                        ss(() {
                          year = value ?? '';
                        });
                        //print(parentId);
                      },
                    ),
                  );
                }),
                // CustomTextField1(
                //   controller: yearController,
                //   hintText: 'Enter your Year',
                //   //labelText: 'year',
                //   labelStyle: TextStyle(
                //     color: Colors.black87,
                //   ),
                //   prefixIcon: Icon(
                //     FontAwesomeIcons.userCircle,
                //     color: headline2Color,
                //   ),
                //   // ignore: missing_return
                //   validator: (value) {
                //     // r'^
                //     //   (?=.*[A-Z])       // should contain at least one upper case
                //     //   (?=.*[a-z])       // should contain at least one lower case
                //     //   (?=.*?[0-9])      // should contain at least one digit
                //     //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
                //     //     .{8,}             // Must be at least 8 characters in length
                //     // $
                //     RegExp regex = RegExp(r'^[a-zA-Z]+$');
                //     if (value.isEmpty) {
                //       return "Year cannot be empty";
                //     } else if (!regex.hasMatch(value)) {
                //       return "Please enter a valid year";
                //     } else if (!(value == "FE" ||
                //         value == "SE" ||
                //         value == "TE" ||
                //         value == "BE")) {
                //       return "Your year should be FE,SE,TE or BE";
                //     }
                //   },
                // ),
                CustomTextField1(
                  controller: divController,
                  hintText: 'Enter your Division',
                  //labelText: 'Division',
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                  prefixIcon: Icon(
                    FontAwesomeIcons.codeBranch,
                    color: headline2Color,
                  ),
                  keyboardType: TextInputType.number,
                  // ignore: missing_return
                  validator: (value) {
                    // r'^
                    //   (?=.*[A-Z])       // should contain at least one upper case
                    //   (?=.*[a-z])       // should contain at least one lower case
                    //   (?=.*?[0-9])      // should contain at least one digit
                    //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
                    //     .{8,}             // Must be at least 8 characters in length
                    // $
                    if (value.isEmpty) {
                      return "Division cannot be empty";
                    }
                    return null;
                  },
                ),
                InkWell(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: primaryColor),
                    alignment: Alignment.center,
                    child: Text(
                      "Update",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  onTap: () async {
                    LoadingFunc.show(context);

                    if (_formKey.currentState!.validate()) {
                      if (isFromSAKEC) {
                        if (year == null) {
                          Fluttertoast.showToast(
                              msg:
                                  "Please Check if you have Entered correct Branch and Year",
                              backgroundColor: Colors.grey[700],
                              textColor: Colors.red,
                              toastLength: Toast.LENGTH_LONG);
                          return;
                        }
                      }
                      Map<String, dynamic> user = <String, dynamic>{
                        'email': emailController.text.trim(),
                        'first_name': firstNameController.text.trim(),
                        'last_name': lastNameController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'reg_no': int.parse(regNoController.text.trim() == "" ? "0" : regNoController.text.trim()),
                        'smartcard_no': smartCardController.text.trim() ?? "",
                        'sakec_id': sakecIdController.text.trim() ?? "",
                        'roll_no': int.parse(rollNoController.text.trim() == ""
                            ? "0"
                            : rollNoController.text.trim()),
                        'branch': branch ?? Branch[0],
                        'year': year ?? Year[0],
                        'div': int.parse(divController.text.trim() == ""
                            ? "0"
                            : divController.text.trim()),
                      };
                      await db.updateUser(data.uid!, user);
                      LoadingFunc.end();
                      Navigator.pop(context);
                    } else {
                      Fluttertoast.showToast(
                          msg:
                              "Some Fields are left empty!\n Please Fill the form with all Details",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey[700],
                          textColor: Colors.red,
                          fontSize: 16.0);
                      LoadingFunc.end();
                    }
                  },
                )
              ]),
      ],
    );
  }
}
