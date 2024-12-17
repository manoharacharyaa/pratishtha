import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/constants/keys.dart';
import 'package:pratishtha/services/authenticationServices.dart';
import 'package:pratishtha/screens/authentication/loginPage.dart';
import 'package:pratishtha/screens/authenticationWrapper.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/styles/mainTheme.dart';
import 'package:provider/provider.dart';
import 'package:pratishtha/widgets/customTextField.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_slimy_card/flutter_slimy_card.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController instituteController = TextEditingController();
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

  Future<List<String>> fetchColleges() async {
    List<String> colleges = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('colleges').get();

      querySnapshot.docs.forEach((doc) {
        colleges.add(doc['collegeName']);
      });
    } catch (e) {
      print('Error fetching colleges: $e');
    }

    return colleges;
  }

  @override
  void initState() {
    super.initState();
    fetchColleges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.width / 15),
              Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(5),
                child: Image.asset('assets/images/SakecLogoFull.png'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 5, 10, 5),
                child: FlutterSlimyCard(
                  color: primaryColor,
                  cardWidth: MediaQuery.of(context).size.width,
                  topCardHeight: MediaQuery.of(context).size.height * 0.6,
                  bottomCardHeight:
                      150, //MediaQuery.of(context).size.height * 0.2,
                  borderRadius: 15,
                  topCardWidget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(3),
                        margin: EdgeInsets.all(3),
                        height: MediaQuery.of(context).size.height / 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/images/PratishthaLogo.png'),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          10.0,
                          0.0,
                          10.0,
                          0.0,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: dullGreyColor,
                                  blurRadius: 20,
                                )
                              ]),
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: buildTextFields(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  bottomCardWidget: ListView(
                    shrinkWrap: true,
                    children: [
                      TextButton(
                        onPressed: () {
                          launch(
                              'https://www.shahandanchor.com/privacy/privacyPolicy.html');
                        },
                        child: RichText(
                            text: TextSpan(
                                text:
                                    "By clicking on Sign Up you agree to all the terms and conditions mentioned in our ",
                                children: [
                                  TextSpan(
                                      text: "Privacy Policy",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontWeight: FontWeight.bold))
                                ],
                                style: TextStyle(color: whiteColor))),
                      ),
                      OverflowBar(
                          alignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                try {
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
                                    await context
                                        .read<AuthenticationService>()
                                        .signup(
                                          email: emailController.text.trim(),
                                          password:
                                              passwordController.text.trim(),
                                          firstName:
                                              firstNameController.text.trim(),
                                          lastName:
                                              lastNameController.text.trim(),
                                          phone: phoneController.text.trim(),
                                          institute: isFromSAKEC
                                              ? "SAKEC"
                                              : instituteController.text.trim(),
                                          regNo: int.parse(
                                              regNoController.text.trim() == ""
                                                  ? "0"
                                                  : regNoController.text
                                                      .trim()),
                                          smartCardNo:
                                              smartCardController.text.trim() ??
                                                  "",
                                          sakecId:
                                              sakecIdController.text.trim() ??
                                                  "",
                                          rollNo: int.parse(
                                              rollNoController.text.trim() == ""
                                                  ? "0"
                                                  : rollNoController.text
                                                      .trim()),
                                          branch: branch ?? Branch[0],
                                          year: year ?? Year[0],
                                          div: int.parse(
                                              divController.text.trim() == ""
                                                  ? "0"
                                                  : divController.text.trim()),
                                        );

                                    await showVerificationPopup(context);

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AuthenticationWrapper(),
                                      ),
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "There seems to be something wrong with the data you have entered, please enter the correct data and try again.",
                                        toastLength: Toast.LENGTH_LONG);
                                  }
                                } catch (e) {
                                  //print(e);
                                }
                              },
                              child: Text(
                                "Sign Up",
                                style: mainTheme.textTheme.displayLarge,
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                ),
                                backgroundColor: cardBackgroundColor,
                                padding: EdgeInsets.all(15),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignIn()),
                                );
                              },
                              child: Text(
                                "Sign In",
                                style: mainTheme.textTheme.displayLarge,
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                ),
                                backgroundColor: cardBackgroundColor,
                                padding: EdgeInsets.all(15),
                              ),
                            )
                          ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildTextFields() {
    return Column(
      children: [
        CustomTextField(
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
        CustomTextField(
          controller: passwordController,
          hintText: 'Enter your Password',
          //labelText: 'Password',
          labelStyle: TextStyle(
            color: Colors.black87,
          ),
          obscureText: true,
          prefixIcon: Icon(
            FontAwesomeIcons.lock,
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
            RegExp regex =
                RegExp(r'^(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$');
            if (value.isEmpty) {
              return "Password cannot be empty";
            } else if (!regex.hasMatch(value)) {
              return "Should contain atleast one digit, one special charecter and must be atleast 6 characters long";
            }
            return null;
          },
        ),
        CustomTextField(
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
        CustomTextField(
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
        CustomTextField(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Are you from SAKEC?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Switch(
                inactiveTrackColor: greyColor,
                value: isFromSAKEC,
                onChanged: (val) {
                  setState(() {
                    isFromSAKEC = val;
                  });
                  if (!val) {
                    regNoController.text = "0";
                    rollNoController.text = "0";
                    divController.text = "0";
                  } else {
                    regNoController.text = "";
                    rollNoController.text = "";
                    divController.text = "";
                  }
                }),
          ],
        ),
        !isFromSAKEC
            // ? CustomTextField(
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
            //  instituteController.clear();
            //       setState(() {});
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
            //      RegExp regex =
            //                  RegExp(r'^[A-Za-z0-9_. ]+$'); //r'^[a-zA-Z0-9]+$'
            //       if (value.isEmpty) {
            //         return "Institute cannot be empty";
            //       } else if (!regex.hasMatch(value)) {
            //         return "Please enter a valid Institute Name";
            //       }
            //       return null;
            //     },
            //   )
            ? FutureBuilder<List<String>>(
                future: fetchColleges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // or any loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error loading colleges');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No colleges available');
                  } else {
                    List<String>? colleges = snapshot.data;

                    return Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Icon(
                            FontAwesomeIcons.buildingColumns,
                            color: headline2Color,
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonFormField(
                            items: colleges?.map((String college) {
                              return DropdownMenuItem(
                                value: college,
                                child: Text(college),
                              );
                            }).toList(),
                            onChanged: (value) {
                              // Handle the selected college
                              print('Selected College: $value');
                            },
                            decoration: InputDecoration(
                              hintText: 'Select your College',
                              // prefixIcon: Icon(
                              //   FontAwesomeIcons.university,
                              //   color: headline2Color,
                              // ),
                              labelStyle: TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "College cannot be empty";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              )
            : Column(children: [
                CustomTextField(
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
                CustomTextField(
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
                  // ignore: missing_return
                  // validator: (value) {
                  //   // r'^
                  //   //   (?=.*[A-Z])       // should contain at least one upper case
                  //   //   (?=.*[a-z])       // should contain at least one lower case
                  //   //   (?=.*?[0-9])      // should contain at least one digit
                  //   //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
                  //   //     .{8,}             // Must be at least 8 characters in length
                  //   // $
                  //   RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
                  //   if (!regex.hasMatch(value)) {
                  //     return "Please enter a valid smartcard number";
                  //   }
                  // },
                ),
                CustomTextField(
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
                CustomTextField(
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
                // CustomTextField(
                //   controller: branchController,
                //   hintText: 'Enter your Branch',
                //   //labelText: 'Branch',
                //   labelStyle: TextStyle(
                //     color: Colors.black87,
                //   ),
                //   prefixIcon: Icon(
                //     FontAwesomeIcons.codeBranch,
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
                //       return "Branch cannot be empty";
                //     } else if (!regex.hasMatch(value)) {
                //       return "Please enter a valid Branch Name";
                //     } else if (!(value == "COMPS" ||
                //         value == "IT" ||
                //         value == "EXTC" ||
                //         value == "ETRX" ||
                //         value == "AIDS" ||
                //         value == "CYSC")) {
                //       return "Your Branch should be COMPS, IT, EXTC, ETRX, AIDS or CYSC";
                //     }
                //   },
                // ),
                StatefulBuilder(builder: (context, ss) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(15),
                    //     border: Border.all(
                    //       color: Colors.black.withOpacity(0.2),
                    //       style: BorderStyle.solid,
                    //       width: 1.5,
                    //     )),
                    margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
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
                          branch = value;
                        });
                        //print(parentId);
                      },
                    ),
                  );
                }),
                StatefulBuilder(builder: (context, ss) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(15),
                    //     border: Border.all(
                    //       color: Colors.black.withOpacity(0.2),
                    //       style: BorderStyle.solid,
                    //       width: 1.5,
                    //     )),
                    margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
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
                          year = value;
                        });
                        //print(parentId);
                      },
                    ),
                  );
                }),
                // CustomTextField(
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
                CustomTextField(
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
              ]),
      ],
    );
  }

  showVerificationPopup(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "An Verification email has been sent to you\n"
            "Please verify yourself",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
