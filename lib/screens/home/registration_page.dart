import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart' as user;
import 'package:pratishtha/screens/admin/event_approval/regristration_model.dart';
import 'package:pratishtha/utils/fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key, required this.event});

  final Event event;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool _isLoading = false;
  bool _isRegistered = false;
  bool _isApproved = false;
  File? _paymentSS;
  user.User? currentUser;
  ImagePicker picker = ImagePicker();
  TextEditingController transactionIdController = TextEditingController();

  void setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  Future isUserApproved() async {
    if (currentUser == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.id)
        .get();

    if (!docSnapshot.exists) return;

    final data = docSnapshot.data();
    if (data == null) return;

    if (data is Map && data.containsKey('approved_users')) {
      final approvedUids = data['approved_users'];

      if (approvedUids is List && approvedUids.contains(currentUser!.uid)) {
        setState(() {
          _isApproved = true;
          prefs.remove('${currentUser!.uid}_${widget.event.id}');
        });
      }
    }
  }

  Future<void> assignUser() async {
    currentUser = await getCurrentUser();
    setState(() {
      getRegistrationStatus();
    });
  }

  Future<user.User> getCurrentUser() async {
    final String curentUid = FirebaseAuth.instance.currentUser!.uid;

    final currentUser = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: curentUid)
        .get()
        .then((e) => user.User.fromMap(e.docs.first.data()));

    return currentUser;
  }

  Future<void> uploadPaymentSS() async {
    setIsLoading(true);
    String fileName =
        "${currentUser!.uid}_${DateTime.now().microsecondsSinceEpoch}.jpg";

    Reference storageRef =
        FirebaseStorage.instance.ref().child('event_payment_ss/$fileName');

    UploadTask uploadTask = storageRef.putFile(_paymentSS!);
    TaskSnapshot taskSnapshot = await uploadTask;

    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('registrations')
        .doc(widget.event.id)
        .set({
      'event_id': widget.event.id,
      'event_name': widget.event.name,
      'event_img': widget.event.bannerUrl,
      'registrations': FieldValue.arrayUnion([
        Registration(
          uid: currentUser?.uid ?? '',
          screenshot: imageUrl,
          userName: '${currentUser!.firstName} ${currentUser!.lastName}',
          phone: currentUser?.phone ?? '',
          branch: currentUser?.branch ?? '',
          transactionId: transactionIdController.text.trim(),
        ).toJson(),
      ])
    }, SetOptions(merge: true));
  }

  Future<void> getRegistrationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRegistered =
          prefs.getBool('${currentUser!.uid}_${widget.event.id}') ?? false;
    });
  }

  @override
  void initState() {
    assignUser().then((_) {
      if (currentUser != null) {
        isUserApproved();
      }
    });
    getRegistrationStatus();
    super.initState();
  }

  void uploadRegrestration() async {
    try {
      return showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDilogState) => AlertDialog(
            title: Text(
              'You are on the wait list',
              style: AppFonts.poppins(
                color: Colors.black,
                size: 20,
                weight: FontWeight.w500,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            content: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _paymentSS != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _paymentSS!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : IconButton(
                      onPressed: () async {
                        XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image == null) {
                          return;
                        } else {
                          setDilogState(() {
                            _paymentSS = File(image.path);
                          });
                        }
                      },
                      icon: Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 45,
                        color: primaryColor,
                      ),
                    ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xff32cf15),
                      ),
                    ),
                    onPressed: () {
                      _paymentSS != null
                          ? uploadPaymentSS().then((value) async {
                              setIsLoading(false);
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String registrationKey =
                                  '${currentUser!.uid}_${widget.event.id}';
                              prefs.setBool(
                                registrationKey,
                                true,
                              );
                              Fluttertoast.showToast(
                                msg: 'Uploaded Sucessfully',
                              );
                              await Duration(seconds: 3);
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).pop();
                            })
                          : Fluttertoast.showToast(
                              msg: 'Please upload payment screenshort',
                            );
                    },
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Upload',
                            style: AppFonts.poppins(
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xffee0000),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _paymentSS = null;
                        setIsLoading(false);
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: AppFonts.poppins(
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      setIsLoading(false);
      Fluttertoast.showToast(msg: 'Registration Failed $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: AppFonts.poppins(color: Colors.black),
        title: Text(
          'Regristration Page',
        ),
      ),
      body: _isApproved
          ? Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset('assets/lottie/popper.json'),
                      Lottie.asset(
                        'assets/lottie/tick.json',
                        height: 200,
                        width: 200,
                      ),
                    ],
                  ),
                  Text(
                    'Congratulations You have Been\nApproved To Play ${widget.event.name}',
                    textAlign: TextAlign.center,
                    style: AppFonts.poppins(),
                  ),
                ],
              ),
            )
          : !_isRegistered
              ? Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DetailsCard(
                        title: 'Event Name: ',
                        text: widget.event.name,
                      ),
                      DetailsCard(
                        title: 'Name: ',
                        text: '${currentUser?.firstName ?? ''}'
                            ' '
                            '${currentUser?.lastName ?? ''}',
                      ),
                      DetailsCard(
                        title: 'Branch: ',
                        text: '${currentUser?.branch ?? ''}',
                      ),
                      DetailsCard(
                        title: 'Phone: ',
                        text: '${currentUser?.phone ?? ''}',
                      ),
                      DetailsCard(
                        title: 'Email: ',
                        text: '${currentUser?.email ?? ''}',
                      ),
                      DetailsCard(
                        title: 'Regrestration Date: ',
                        text: DateFormat('dd-MM-yyyy')
                            .format(DateTime.now())
                            .toString(),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        padding: EdgeInsets.only(top: 9),
                        height: 50,
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(40, 0, 0, 0),
                              offset: Offset(0, 1.5),
                              blurRadius: 0.1,
                              spreadRadius: 0.2,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: transactionIdController,
                          cursorHeight: 18,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: secondaryColor,
                            hintText: 'Enter 12 Digits UPI Tranction Id',
                            hintStyle: AppFonts.poppins(
                              size: 15.5,
                              color: primaryColor,
                            ),
                            border: OutlineInputBorder(
                              gapPadding: 0,
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: size.height * 0.25,
                        width: size.width * 0.25,
                        child: FadeInImage(
                          placeholder: MemoryImage(kTransparentImage),
                          image: AssetImage('assets/images/sakec_qr.jpg'),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Text(
                          'Scan And Pay',
                          style: AppFonts.poppins(
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 2, 15),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(primaryColor),
                            minimumSize: WidgetStatePropertyAll(
                              Size(double.infinity, 55),
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (transactionIdController.text.isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Enter Transaction ID',
                              );
                              return;
                            }
                            if (transactionIdController.text.length != 12) {
                              Fluttertoast.showToast(
                                msg: 'Invalid Transaction ID',
                                textColor: Colors.red,
                              );
                              return;
                            }
                            uploadRegrestration();
                          },
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: secondaryColor,
                                  ),
                                )
                              : Text(
                                  'Register',
                                  style: AppFonts.poppins(
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Lottie.asset('assets/lottie/processing.json'),
                    SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Text(
                        'You are on the wait list\nProcessing your payment',
                        textAlign: TextAlign.center,
                        style: AppFonts.poppins(
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class DetailsCard extends StatelessWidget {
  const DetailsCard({
    super.key,
    this.title,
    this.text,
  });

  final String? title;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      color: secondaryColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 13, 0, 13),
        child: Row(
          children: [
            Text(
              title ?? '',
              style: AppFonts.poppins(
                color: Colors.black,
                size: 15.5,
              ),
            ),
            Expanded(
              child: SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    text ?? '',
                    style: AppFonts.poppins(
                      color: Colors.black,
                      size: 15.5,
                    ),
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
