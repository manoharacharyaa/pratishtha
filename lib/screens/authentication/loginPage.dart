import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/screens/authentication/signupPage.dart';
import 'package:pratishtha/services/authenticationServices.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/styles/mainTheme.dart';
import 'package:pratishtha/widgets/customTextField.dart';
import 'package:provider/provider.dart';
// import 'package:slimy_card/slimy_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_slimy_card/flutter_slimy_card.dart';
class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  String errorText = "";

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
              child: 
              FlutterSlimyCard(
                color: primaryColor,
                cardWidth: MediaQuery.of(context).size.width,
                topCardHeight: MediaQuery.of(context).size.height * 0.5,
                bottomCardHeight: MediaQuery.of(context).size.height / 3,
                borderRadius: 15,
                topCardWidget: 
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/PratishthaLogo.png',
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                    ),
                    Container(
                      //padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(5),
                      child:
                          Image.asset('assets/images/PratishthaLogoText.png'),
                    ),
                  ],
                ),
                bottomCardWidget: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: Form(
                        key: _formKey,
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
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: CustomTextField(
                                  controller: emailController,
                                  hintText: 'Email',
                                  prefixIcon: Icon(
                                    FontAwesomeIcons.mailBulk,
                                    color: headline2Color,
                                  ),
                                  // ignore: missing_return
                                  validator: (value) {
                                    if (!value.contains('@')) {
                                      return "Please enter a valid email address";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: CustomTextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  prefixIcon: Icon(
                                    FontAwesomeIcons.lock,
                                    color: headline2Color,
                                  ),
                                  hintText: 'Password',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextButton(
                        onPressed: (){
                          launch(
                              'https://www.shahandanchor.com/privacy/privacyPolicy.html'
                          );
                        },
                        child: RichText(
                            text: TextSpan(
                                text: "By clicking on Sign In you agree to all the terms and conditions mentioned in our ",
                                children: [
                                  TextSpan(text: "Privacy Policy", style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold))
                                ],
                                style: TextStyle(
                                    color: whiteColor
                                )
                            )
                        ),
                    ),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String result = await context
                                  .read<AuthenticationService>()
                                  .signIn(emailController.text.trim(),
                                      passwordController.text.trim());
                              if (result != "Signed In") {
                                Fluttertoast.showToast(
                                    msg: result.split('.')[0],
                                    toastLength: Toast.LENGTH_LONG,
                                    textColor: secondaryColor,
                                    backgroundColor: whiteColor);
                              }
                              //print("signin result: ${result}");
                            } else {
                              //print("printing else");
                            }
                          },
                          child: Text(
                            "Sign In",
                            style: mainTheme.textTheme.displayLarge,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0),
                            ), backgroundColor: cardBackgroundColor,
                            padding: EdgeInsets.all(15),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUp(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: mainTheme.textTheme.displayLarge,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0),
                            ), backgroundColor: cardBackgroundColor,
                            padding: EdgeInsets.all(15),
                            //textStyle: mainTheme.textTheme.headline1,
                          ),
                        )
                      ],
                    ),
                    Container(
                      //padding: EdgeInsets.all(5),
                      child: TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            FirebaseAuth auth = FirebaseAuth.instance;
                            auth.sendPasswordResetEmail(
                                email: emailController.text.trim());
                            //print("signin result: ${result}");
                            Fluttertoast.showToast(
                              msg:
                                  "An email has been sent to the registered Id",
                              gravity: ToastGravity.TOP,
                              toastLength: Toast.LENGTH_LONG,
                              textColor: secondaryColor,
                              backgroundColor: whiteColor,
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: "Please enter your email",
                              toastLength: Toast.LENGTH_LONG,
                              textColor: secondaryColor,
                              backgroundColor: whiteColor,
                            );
                          }
                        },
                        child: Text(
                          'Forgot your Password?',
                          style:
                              TextStyle(color: secondaryColor, fontSize: 14.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                slimeEnabled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
