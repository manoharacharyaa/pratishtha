import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/services/interCollegeServices.dart';

class AddCollege extends StatefulWidget {
  const AddCollege({super.key});

  @override
  State<AddCollege> createState() => _AddCollegeState();
}

class _AddCollegeState extends State<AddCollege> {
  String? selectedCollege;

  final FocusNode _collegeFocusNode = FocusNode();
  final FocusNode _scoreFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController collegecontroller = TextEditingController();
  final TextEditingController participantcontroller = TextEditingController();
  final TextEditingController teamcontroller = TextEditingController();
  final TextEditingController scorecontroller = TextEditingController();
  final TextEditingController updatedscorecontroller = TextEditingController();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController collegeShortNameController =
      TextEditingController();
  final TextEditingController collegeLocation = TextEditingController();

  File? _pickedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error picking image: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[700],
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: dullGreyColor,
                        blurRadius: 20,
                      )
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Add College',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: MyTextField(
                          focusNode:
                              _collegeFocusNode, // Associate the FocusNode
                          hinttext: 'Enter College Name',
                          keyboard: TextInputType.text,
                          obscuretext: false,
                          controller: collegecontroller,
                          icon: Icon(
                            Icons.school_rounded,
                            color: headline2Color,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: MyTextField(
                          focusNode: _scoreFocusNode,
                          hinttext: 'Enter College Short Name',
                          keyboard: TextInputType.number,
                          obscuretext: false,
                          controller: scorecontroller,
                          icon: Icon(
                            Icons.score,
                            color: headline2Color,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a short name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: MyTextField(
                          focusNode: _scoreFocusNode,
                          hinttext: 'Enter College Location',
                          keyboard: TextInputType.number,
                          obscuretext: false,
                          controller: scorecontroller,
                          icon: Icon(
                            Icons.score,
                            color: headline2Color,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a location';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: AbsorbPointer(
                            child: MyTextField(
                              hinttext: 'Enter College Logo',
                              obscuretext: false,
                              controller: TextEditingController(
                                text: _pickedImage != null
                                    ? _pickedImage!.path.split('/').last
                                    : '',
                              ),
                              icon: Icon(
                                Icons.upload_file,
                                color: headline2Color,
                              ),
                              validator: (value) {
                                if (_pickedImage == null) {
                                  return 'Please enter a logo';
                                }
                                return null;
                              },
                              focusNode: _scoreFocusNode,
                            ),
                          ),
                        ),
                      ),
                      if (_pickedImage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Image.file(
                            _pickedImage!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(
                        height: 30,
                      ),
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(30),
                        color: cardBackgroundColor,
                        child: MaterialButton(
                          minWidth: 275,
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String result = await InterCollegeServices()
                                  .addCollegeForInter(
                                collegeNameController.text,
                                collegeShortNameController.text,
                                collegeLocation.text,
                                _pickedImage!,
                              );

                              if (result == 'Success') {
                                Fluttertoast.showToast(
                                  msg: "Volunteer added successfully",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green[700],
                                  textColor: Colors.white,
                                );
                              }
                            } else {
                              Fluttertoast.showToast(
                                msg: "Failed to add member(s)",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red[700],
                                textColor: Colors.white,
                              );
                            }
                          },
                          child: Text(
                            'Submit',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final FocusNode focusNode;
  final String hinttext;
  final bool obscuretext;
  final TextEditingController controller;
  final TextInputType keyboard;
  final Icon icon;
  final String? Function(String?)? validator;

  const MyTextField({
    Key? key,
    required this.hinttext,
    required this.obscuretext,
    required this.controller,
    required this.icon,
    required this.validator,
    this.keyboard = TextInputType.text,
    required this.focusNode, // Provide a default value for keyboard
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      keyboardType: keyboard,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 4),
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: hinttext,
        prefixIcon: icon,
      ),
      obscureText: obscuretext,
      validator: validator,
    );
  }
}
