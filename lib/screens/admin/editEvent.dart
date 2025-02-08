import 'dart:io';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/constants/festIcons.dart';
import 'package:pratishtha/constants/keys.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/services/searchServices.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart';
import 'package:pratishtha/services/storageServices.dart';
import 'package:pratishtha/utils/fonts.dart';
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/customTextField.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/widgets/funcLoading.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart' as sh;

class EditEvent extends StatefulWidget {
  const EditEvent({this.event});
  final Event? event;
  @override
  _EditEventState createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  final TextEditingController name = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController dateFrom = TextEditingController();
  final TextEditingController dateTo = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController participationPoint = TextEditingController();
  final TextEditingController runnerUpPoint = TextEditingController();
  final TextEditingController winnerPoint = TextEditingController();
  final TextEditingController participationLimit =
      TextEditingController(text: "1000");
  final TextEditingController volunteerLimit =
      TextEditingController(text: "10");
  final TextEditingController volunteerPoints = TextEditingController();
  final TextEditingController eventHeadPoints = TextEditingController();
  final TextEditingController eventLogisticURL = TextEditingController();
  final TextEditingController eventMeetingURL = TextEditingController();
  final TextEditingController registrationURL = TextEditingController();
  final TextEditingController feedbackURL = TextEditingController();
  final TextEditingController searchE = TextEditingController();
  final TextEditingController searchV = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<TextEditingController> _controller = [];

  List<Widget> _children = [];

  Event? eventData;

  List rules = [];

  Map? eventTypes;

  List eh = [];
  List ev = [];
  List<User> eventhead = [];

  List<User> eventvol = [];

  int _count = 0;

  var db = DatabaseServices();
  var cs = StorageServices();

  String? _dropdown;

  List<String> typ = [];

  Icon? festIcon;
  String parentId = '';
  File? img;
  bool hasImage = false;
  bool isFest = false;
  String bannerUrl = "";
  int? index;
  bool forSakec = false;
  int? type;
  String? eventType;
  String locationType = "";

  Map? features;
  User? user;

  @override
  void initState() {
    super.initState();
    //eventData = widget.event;

    name.text = widget.event!.name!;
    bannerUrl = widget.event!.bannerUrl;
    description.text = widget.event!.description;
    eh = widget.event!.eventHeads!;
    ev = widget.event!.volunteers!;
    type = widget.event!.type != null ? widget.event!.type : 0;
    dateFrom.text = widget.event!.dateFrom.toString();
    dateTo.text = widget.event!.dateTo.toString();
    location.text = widget.event!.location;
    price.text = widget.event!.price.toString();
    participationPoint.text = widget.event!.participationPoints.toString();
    runnerUpPoint.text = widget.event!.runnerUpPoints.toString();
    winnerPoint.text = widget.event!.winnerPoints.toString();
    participationLimit.text = widget.event!.participantsLimit.toString();
    volunteerLimit.text = widget.event!.volunteersLimit.toString();
    eventHeadPoints.text = widget.event!.eventHeadPoints.toString();
    volunteerPoints.text = widget.event!.volunteerPoints.toString();
    locationType = widget.event!.locationType != ""
        ? widget.event!.locationType
        : "Offline";
    forSakec = widget.event!.forSakec;
    parentId = widget.event!.parentId;
    eventMeetingURL.text = widget.event!.meetLink;
    eventLogisticURL.text = widget.event!.eventLogisticsUrl;
    registrationURL.text = widget.event!.registrationUrl;
    feedbackURL.text = widget.event!.feedbackUrl;
    if (widget.event!.parentId != "") {
      isFest = false;
      fetchHnV();
    } else {
      isFest = true;
      index = widget.event!.icon;
      festIcon = festIcons![index!];
    }
    widget.event!.rules!.forEach((i) {
      _controller.add(TextEditingController());
      _controller.last.text = i;
      _children.add(Container(
          child: CustomTextField1(
        hintText: "Rule $_count",
        validator: validateIsEmpty,
        controller: _controller[_count],
      )));
      _count++;
    });
  }

  void fetchHnV() async {
    widget.event!.eventHeads!.forEach((i) async {
      eventhead.add(await db.getUser(i));
    });

    widget.event!.volunteers!.forEach((i) async {
      eventvol.add(await db.getUser(i));
    });
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Edit Event"),
          ),
          body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: FutureBuilder(
                  future: Future.wait([
                    sh.getFeatureListValuesFromPrefs(),
                    sh.getUserFromPrefs(),
                  ]),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      features = (snap.data as List)[0];

                      user = (snap.data as List)[1];
                      //print(user.role);
                      return FutureBuilder(
                          future: db.getFest(widget.event!.parentId),
                          builder: (context, snaps) {
                            if (snaps.hasData) {
                              _dropdown = snaps.data!.name!;
                            }
                            return StatefulBuilder(builder: (context, ss) {
                              return Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    CustomTextField1(
                                      controller: name,
                                      hintText: 'Enter Event Name',
                                      labelText: 'Event Name',

                                      labelStyle: TextStyle(
                                        color: Colors.black87,
                                      ),
                                      // ignore: missing_return
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "Event name cannot be empty";
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomTextField1(
                                      controller: description,
                                      hintText: 'Enter Event Description',
                                      labelText: 'Event Description',
                                      labelStyle: TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    !isFest
                                        ? FutureBuilder<Map<dynamic, dynamic>>(
                                            future:
                                                getEventTypesListFromPrefs(),
                                            builder: (context, snap) {
                                              if (snap.hasData) {
                                                eventTypes = snap.data;
                                                typ.clear();
                                                eventTypes!.forEach((i, j) {
                                                  if (type == int.parse(i)) {
                                                    eventType = j["name"];
                                                  }
                                                  typ.add(j["name"]);
                                                });

                                                return StatefulBuilder(
                                                    builder: (context, ss) {
                                                  return Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        border: Border.all(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
                                                          style:
                                                              BorderStyle.solid,
                                                          width: 1.5,
                                                        )),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 8),
                                                    child:
                                                        DropdownButton<String>(
                                                      underline:
                                                          const SizedBox(),
                                                      isExpanded: true,
                                                      value: eventType,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      elevation: 5,
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      iconEnabledColor:
                                                          Colors.black,
                                                      items: typ.map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(
                                                            value,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      hint: const Text(
                                                        "Select Type of Event",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      onChanged:
                                                          (String? value) {
                                                        ss(() {
                                                          eventType = value;
                                                        });
                                                        //print(parentId);
                                                      },
                                                    ),
                                                  );
                                                });
                                              } else
                                                return CircularProgressIndicator();
                                            })
                                        : SizedBox.shrink(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 10, 20, 0),
                                      child: DateTimePicker(
                                        timeFieldWidth: 150,
                                        type:
                                            DateTimePickerType.dateTimeSeparate,
                                        dateMask: 'd MMMM, yyyy',
                                        initialTime: TimeOfDay.fromDateTime(
                                            widget.event!.dateFrom!),
                                        dateHintText: "Enter Start Date",
                                        dateLabelText: 'Event Start Date',
                                        controller: dateFrom,
                                        timeHintText: "Enter Start Time",
                                        timeLabelText: "Enter Start Time",

                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100),

                                        //icon: Icon(Icons.event),
                                        use24HourFormat: true,
                                        locale: Locale('en', 'US'),

                                        // onChanged: (val) => setState(() => _valueChanged2 = val),
                                        // validator: (val) {
                                        //   setState(() => _valueToValidate2 = val ?? '');
                                        //   return null;
                                        // },
                                        // onSaved: (val) => setState(() => _valueSaved2 = val ?? ''),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 10, 20, 10),
                                      child: DateTimePicker(
                                        timeFieldWidth: 150,
                                        type:
                                            DateTimePickerType.dateTimeSeparate,
                                        dateMask: 'd MMMM, yyyy',
                                        initialTime: TimeOfDay.fromDateTime(
                                            widget.event!.dateTo!),
                                        dateHintText: "Enter End Date",
                                        dateLabelText: 'Event End Date',
                                        controller: dateTo,
                                        timeHintText: "Enter End Time",
                                        timeLabelText: "Enter End Time",

                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100),

                                        //icon: Icon(Icons.event),
                                        use24HourFormat: true,
                                        locale: Locale('en', 'US'),

                                        // onChanged: (val) {
                                        //   setState(() => _valueChanged2 = val);
                                        // },
                                        // validator: (val) {
                                        //   setState(() => _valueToValidate2 = val ?? '');
                                        //   return null;
                                        // },
                                        // onSaved: (val) {
                                        //   //print("yrfgh" + val);
                                        //   setState(() => _valueSaved2 = val ?? '');
                                        // },
                                      ),
                                    ),
                                    !isFest
                                        ? CustomTextField1(
                                            controller: location,
                                            hintText: 'Enter Location',
                                            labelText: 'Event Location',
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    StatefulBuilder(builder: (context, ss) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              style: BorderStyle.solid,
                                              width: 1.5,
                                            )),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 8),
                                        child: DropdownButton<String>(
                                          underline: const SizedBox(),
                                          isExpanded: true,
                                          value: locationType,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          elevation: 5,
                                          style: const TextStyle(
                                              color: Colors.black),
                                          iconEnabledColor: Colors.black,
                                          items: LocationType.map<
                                                  DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16),
                                              ),
                                            );
                                          }).toList(),
                                          hint: const Text(
                                            "Select Location type",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                          onChanged: (String? value) {
                                            ss(() {
                                              locationType = value!;
                                            });
                                            //print(parentId);
                                          },
                                        ),
                                      );
                                    }),
                                    !isFest
                                        ? CustomTextField1(
                                            controller: price,
                                            hintText: 'Enter Event Price',
                                            labelText: 'Event Price',
                                            validator: validateIsEmpty,
                                            keyboardType: TextInputType.number,
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    !isFest
                                        ? CustomTextField1(
                                            controller: participationPoint,
                                            hintText:
                                                'Enter Participation Points',
                                            labelText: 'Participation Points',
                                            keyboardType: TextInputType.number,
                                            validator: validateIsEmpty,
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    !isFest
                                        ? CustomTextField1(
                                            controller: runnerUpPoint,
                                            hintText: 'Enter Runner Up Points',
                                            labelText: 'Runner Up Points',
                                            keyboardType: TextInputType.number,
                                            validator: validateIsEmpty,
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    Container(
                                      margin:
                                          EdgeInsets.fromLTRB(16, 16, 16, 16),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                16, 10, 16, 10),
                                            child: Text(
                                              "Enter Rules",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                          Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: _children +
                                                  [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        IconButton(
                                                            onPressed: () {
                                                              _controller.add(
                                                                  TextEditingController());
                                                              _children = List
                                                                  .from(
                                                                      _children)
                                                                ..add(Container(
                                                                    child:
                                                                        CustomTextField1(
                                                                  hintText:
                                                                      "Rule $_count",
                                                                  validator:
                                                                      validateIsEmpty,
                                                                  // onChanged: (v) {
                                                                  //   rules.clear();
                                                                  //   setState(() {
                                                                  //     for (var element in _controller) {
                                                                  //       rules.add(element.text);
                                                                  //     }
                                                                  //   });
                                                                  // },
                                                                  // decoration:
                                                                  //     ThemeText().inputfield("Option : $_count"),
                                                                  controller:
                                                                      _controller[
                                                                          _count],
                                                                )));
                                                              setState(() =>
                                                                  ++_count);
                                                            },
                                                            icon: Icon(
                                                              Icons.add_box,
                                                            )),
                                                        IconButton(
                                                            onPressed: () {
                                                              if (_count > 0) {
                                                                setState(() {
                                                                  _children
                                                                      .removeLast();
                                                                  // if (rules.isNotEmpty) {
                                                                  //   rules.removeLast();
                                                                  // }
                                                                  --_count;
                                                                  _controller
                                                                      .removeLast();
                                                                });
                                                              }
                                                            },
                                                            icon: Icon(
                                                              Icons.cancel,
                                                              // color: ThemeColors().secondaryButtoncolor,
                                                            )),
                                                      ],
                                                    )
                                                  ]),
                                        ],
                                      ),
                                    ),
                                    !isFest
                                        ? CustomTextField1(
                                            controller: winnerPoint,
                                            hintText: 'Enter Winner Points',
                                            labelText: 'Winner Points',
                                            keyboardType: TextInputType.number,
                                            validator: validateIsEmpty,
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    !isFest
                                        ? CustomTextField1(
                                            controller: participationLimit,
                                            hintText:
                                                'Enter Participation Limit',
                                            labelText: 'Participation Limit',
                                            keyboardType: TextInputType.number,
                                            validator: validateIsEmpty,
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    !isFest
                                        ? features!['8']['roles']
                                                .contains(user!.role)
                                            ? CustomTextField1(
                                                controller: volunteerLimit,
                                                hintText:
                                                    'Enter Volunteer Limit',
                                                labelText: 'Volunteer Limit',
                                                validator: validateIsEmpty,
                                                keyboardType:
                                                    TextInputType.number,
                                                labelStyle: TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              )
                                            : SizedBox.shrink()
                                        : SizedBox.shrink(),
                                    features!['8']['roles'].contains(user!.role)
                                        ? CustomTextField1(
                                            controller: volunteerPoints,
                                            hintText: 'Enter Volunteer Points',
                                            labelText: 'Volunteer Points',
                                            validator: validateIsEmpty,
                                            keyboardType: TextInputType.number,
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    features!['7']['roles'].contains(user!.role)
                                        ? CustomTextField1(
                                            controller: eventHeadPoints,
                                            hintText: 'Enter Event Head Points',
                                            labelText: 'Event Head Points',
                                            validator: validateIsEmpty,
                                            keyboardType: TextInputType.number,
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    !isFest
                                        ? CustomTextField1(
                                            controller: eventMeetingURL,
                                            hintText: 'Enter Meeting URL',
                                            labelText: 'Event Meeting URL',
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    !isFest
                                        ? CustomTextField1(
                                            controller: eventLogisticURL,
                                            hintText: 'Enter Logistics URL',
                                            labelText: 'Event Logistics URL',
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    !isFest
                                        ? CustomTextField1(
                                            controller: registrationURL,
                                            hintText: 'Enter Registration URL',
                                            labelText: 'Event Registration URL',
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    !isFest
                                        ? CustomTextField1(
                                            controller: feedbackURL,
                                            hintText: 'Enter Feedback URL',
                                            labelText: 'Event Feedback URL',
                                            labelStyle: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    Container(
                                      margin: EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          !isFest
                                              ? FutureBuilder<List<Event>>(
                                                  future: db.getFests(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      var events =
                                                          snapshot.data;
                                                      List<String> e = [];
                                                      events?.forEach((i) {
                                                        //if (widget.event.name != i.name)
                                                        e.add(i.name!);
                                                      });

                                                      return StatefulBuilder(
                                                          builder:
                                                              (context, ss) {
                                                        return DropdownButton<
                                                            String>(
                                                          focusColor:
                                                              Colors.black,
                                                          underline:
                                                              const SizedBox(),
                                                          value: _dropdown,
                                                          elevation: 5,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                          iconEnabledColor:
                                                              Colors.black,
                                                          items: e.map<
                                                              DropdownMenuItem<
                                                                  String>>((String
                                                              value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: Text(
                                                                value,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            );
                                                          }).toList(),
                                                          hint: const Text(
                                                            "Select Event",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          onChanged:
                                                              (String? value) {
                                                            ss(() {
                                                              _dropdown = value;
                                                              parentId = events![
                                                                      e.indexOf(
                                                                          value!)]
                                                                  .id!;
                                                              eventData = events[
                                                                  e.indexOf(
                                                                      value)];
                                                            });
                                                            //print(parentId);
                                                          },
                                                        );
                                                      });
                                                    } else
                                                      return CircularProgressIndicator();
                                                  })
                                              : DropdownButton<Icon>(
                                                  focusColor: Colors.black,
                                                  underline: const SizedBox(),
                                                  value: festIcon,
                                                  elevation: 5,
                                                  //dropdownColor: primaryColor,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                  iconEnabledColor:
                                                      Colors.black,
                                                  items: festIcons!.map<
                                                      DropdownMenuItem<
                                                          Icon>>((Icon value) {
                                                    return DropdownMenuItem<
                                                            Icon>(
                                                        value: value,
                                                        child: Center(
                                                            child: Icon(
                                                          value.icon,
                                                          size: value.size,
                                                          color: Colors.black,
                                                        )));
                                                  }).toList(),
                                                  hint: const Text(
                                                    "Select Event Icon",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  onChanged: (Icon? value) {
                                                    setState(() {
                                                      festIcon = value;
                                                      parentId = "";
                                                      index = festIcons!
                                                          .indexOf(value!);
                                                    });
                                                  },
                                                )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "SAKEC Event only",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          Switch(
                                              value: forSakec,
                                              onChanged: (val) {
                                                setState(() {
                                                  forSakec = val;
                                                });
                                              }),
                                        ],
                                      ),
                                    ),
                                    features!['7']['roles'].contains(user!.role)
                                        ? Container(
                                            margin: EdgeInsets.fromLTRB(
                                                16, 10, 16, 10),
                                            padding: EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Event Heads",
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    Spacer(),
                                                    IconButton(
                                                        onPressed: () {
                                                          showModalBottomSheet(
                                                              context: context,
                                                              elevation: 10,
                                                              isScrollControlled:
                                                                  true,
                                                              clipBehavior: Clip
                                                                  .antiAlias,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                              ),
                                                              builder:
                                                                  (context) {
                                                                return Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      1.5,
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .vertical(
                                                                      top: Radius
                                                                          .circular(
                                                                              10),
                                                                    ),
                                                                    child: FutureBuilder<
                                                                            List<
                                                                                User>>(
                                                                        future: db
                                                                            .getSakecUsers(),
                                                                        builder:
                                                                            (context,
                                                                                snapshot) {
                                                                          if (snapshot
                                                                              .hasData) {
                                                                            var data =
                                                                                snapshot.data;
                                                                            List
                                                                                srch =
                                                                                [];
                                                                            srch.addAll(data!);
                                                                            List
                                                                                istapped =
                                                                                List.generate(data.length, (index) => false);
                                                                            return StatefulBuilder(builder:
                                                                                (context, ss) {
                                                                              return Column(
                                                                                children: [
                                                                                  Container(
                                                                                    color: Colors.white,
                                                                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          "Select Event Head",
                                                                                          style: TextStyle(fontSize: 16),
                                                                                        ),
                                                                                        Spacer(),
                                                                                        InkWell(
                                                                                          onTap: () {
                                                                                            Navigator.pop(context);
                                                                                            setState(() {});
                                                                                          },
                                                                                          child: Container(
                                                                                            padding: EdgeInsets.fromLTRB(4, 2, 4, 3),
                                                                                            decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                              color: primaryColor,
                                                                                            ),
                                                                                            child: Text(
                                                                                              "Save",
                                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    color: Colors.white,
                                                                                    child: CustomTextField1(
                                                                                      controller: searchE,
                                                                                      hintText: 'Enter User Name',
                                                                                      labelText: 'Enter User Name',
                                                                                      labelStyle: TextStyle(
                                                                                        color: Colors.black87,
                                                                                      ),
                                                                                      // onChanged: (v) {
                                                                                      //   print(userSearch(
                                                                                      //       allUsersList: data,
                                                                                      //       query: v));
                                                                                      // },
                                                                                      suffix: InkWell(
                                                                                          onTap: () {
                                                                                            srch.clear();
                                                                                            ss(() {
                                                                                              srch.addAll(userSearch(allUsersList: data, query: searchE.text.trim()));
                                                                                            });
                                                                                          },
                                                                                          child: Icon(
                                                                                            Icons.search,
                                                                                            color: Colors.black87,
                                                                                            size: 24,
                                                                                          )),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: ListView.builder(
                                                                                        shrinkWrap: true,
                                                                                        physics: AlwaysScrollableScrollPhysics(),
                                                                                        itemCount: srch.length,
                                                                                        itemBuilder: (context, index) {
                                                                                          return ListTile(
                                                                                            tileColor: istapped[index] ? purpleAccentColor : whiteColor,
                                                                                            title: Text("${srch[index].firstName} ${srch[index].lastName}"),
                                                                                            onTap: () {
                                                                                              if (!istapped[index]) {
                                                                                                var contain = eventhead.where((element) => element.smartcardNo == srch[index].smartcardNo);
                                                                                                if (contain.isEmpty) {
                                                                                                  eventhead.add(srch[index]);
                                                                                                  eh.add(srch[index].uid);
                                                                                                }
                                                                                              } else {
                                                                                                eventhead.remove(srch[index]);
                                                                                              }
                                                                                              ss(() {
                                                                                                istapped[index] = !istapped[index];
                                                                                              });
                                                                                            },
                                                                                          );
                                                                                        }),
                                                                                  )
                                                                                ],
                                                                              );
                                                                            });
                                                                          } else {
                                                                            return Center(
                                                                              child: CircularProgressIndicator(),
                                                                            );
                                                                          }
                                                                        }),
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                        icon: Icon(Icons.add))
                                                  ],
                                                ),
                                                StatefulBuilder(
                                                    builder: (context, ss) {
                                                  return ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          eventhead.length,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ListTile(
                                                          title: Text(
                                                            "${eventhead[index].firstName} ${eventhead[index].lastName}",
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ),
                                                          trailing: InkWell(
                                                              onTap: () {
                                                                ss(() {
                                                                  eventhead
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              child: Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .black,
                                                              )),
                                                        );
                                                      });
                                                })
                                              ],
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    features!['8']['roles'].contains(user!.role)
                                        ? Container(
                                            margin: EdgeInsets.fromLTRB(
                                                16, 10, 16, 10),
                                            padding: EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Event Volunteers",
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    Spacer(),
                                                    IconButton(
                                                        onPressed: () {
                                                          if (eventvol.length <
                                                              widget.event!
                                                                  .volunteersLimit)
                                                            showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                elevation: 10,
                                                                isScrollControlled:
                                                                    true,
                                                                clipBehavior: Clip
                                                                    .antiAlias,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                builder:
                                                                    (context) {
                                                                  return FutureBuilder<
                                                                          List<
                                                                              User>>(
                                                                      future: db
                                                                          .getSakecUsers(),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        if (snapshot
                                                                            .hasData) {
                                                                          var data =
                                                                              snapshot.data;
                                                                          List<User>
                                                                              srch =
                                                                              [];
                                                                          srch.addAll(
                                                                              data!);
                                                                          List istapped = List.generate(
                                                                              data.length,
                                                                              (index) => false);
                                                                          return StatefulBuilder(builder:
                                                                              (context, ss) {
                                                                            return Container(
                                                                              height: MediaQuery.of(context).size.height / 1.5,
                                                                              child: Column(
                                                                                children: [
                                                                                  Container(
                                                                                    color: Colors.white,
                                                                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          "Select Event Volunteer",
                                                                                          style: TextStyle(fontSize: 16),
                                                                                        ),
                                                                                        Spacer(),
                                                                                        InkWell(
                                                                                          onTap: () {
                                                                                            Navigator.pop(context);
                                                                                            setState(() {});
                                                                                          },
                                                                                          child: Container(
                                                                                            decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                              color: primaryColor,
                                                                                            ),
                                                                                            padding: EdgeInsets.fromLTRB(4, 2, 4, 3),
                                                                                            child: Text(
                                                                                              "Save",
                                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    color: Colors.white,
                                                                                    child: CustomTextField1(
                                                                                      controller: searchV,
                                                                                      hintText: 'Enter User Name',
                                                                                      labelText: 'Enter User Name',
                                                                                      labelStyle: TextStyle(
                                                                                        color: Colors.black87,
                                                                                      ),
                                                                                      // onChanged: (v) {
                                                                                      //   print(userSearch(
                                                                                      //       allUsersList: data,
                                                                                      //       query: v));
                                                                                      // },
                                                                                      suffix: InkWell(
                                                                                          onTap: () {
                                                                                            srch.clear();
                                                                                            ss(() {
                                                                                              srch.addAll(userSearch(allUsersList: data, query: searchV.text.trim()));
                                                                                            });
                                                                                          },
                                                                                          child: Icon(
                                                                                            Icons.search,
                                                                                            color: Colors.black87,
                                                                                            size: 24,
                                                                                          )),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Container(
                                                                                      child: ListView.builder(
                                                                                          shrinkWrap: true,
                                                                                          itemCount: srch.length,
                                                                                          itemBuilder: (context, index) {
                                                                                            return ListTile(
                                                                                              tileColor: istapped[index] ? purpleAccentColor : Colors.white,
                                                                                              title: Text("${srch[index].firstName} ${srch[index].lastName}"),
                                                                                              onTap: () {
                                                                                                if (!istapped[index]) {
                                                                                                  var contain = eventvol.where((element) => element.smartcardNo == srch[index].smartcardNo);
                                                                                                  if (contain.isEmpty && eventvol.length < widget.event!.volunteersLimit) {
                                                                                                    eventvol.add(srch[index]);
                                                                                                    ev.add(srch[index].uid);
                                                                                                  }
                                                                                                } else {
                                                                                                  eventvol.remove(srch[index]);
                                                                                                }
                                                                                                if (eventvol.length < widget.event!.volunteersLimit) {
                                                                                                  ss(() {
                                                                                                    istapped[index] = !istapped[index];
                                                                                                  });
                                                                                                }
                                                                                              },
                                                                                            );
                                                                                          }),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            );
                                                                          });
                                                                        } else {
                                                                          return Center(
                                                                            child:
                                                                                CircularProgressIndicator(),
                                                                          );
                                                                        }
                                                                      });
                                                                });
                                                          else
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Volunteer Limit Reached",
                                                                backgroundColor:
                                                                    Colors.grey[
                                                                        800],
                                                                fontSize: 16,
                                                                textColor:
                                                                    Colors.red,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM);
                                                        },
                                                        icon: Icon(Icons.add))
                                                  ],
                                                ),
                                                StatefulBuilder(
                                                    builder: (context, ss) {
                                                  return ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          eventvol.length,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ListTile(
                                                          title: Text(
                                                            "${eventvol[index].firstName} ${eventvol[index].lastName}",
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ),
                                                          trailing: InkWell(
                                                              onTap: () {
                                                                ss(() {
                                                                  eventvol
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              child: Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .black,
                                                              )),
                                                        );
                                                      });
                                                })
                                              ],
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    StatefulBuilder(builder: (context, ss) {
                                      return Column(
                                        children: [
                                          InkWell(
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 20, 0, 20),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                                    "Change Event Image",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: primaryColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () async {
                                              img = await cs.pickImage();
                                              ss(() {
                                                hasImage = true;
                                              });
                                            },
                                          ),
                                          bannerUrl.isEmpty
                                              ? AspectRatio(
                                                  aspectRatio: 16 / 9,
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'No Banner Found',
                                                        style:
                                                            AppFonts.poppins(),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : hasImage
                                                  ? AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 15,
                                                        ),
                                                        child: Image.file(img!),
                                                      ),
                                                    )
                                                  : AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 15),
                                                        child: Image.network(
                                                          widget
                                                              .event!.bannerUrl,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                        ],
                                      );
                                    }),
                                    InkWell(
                                      child: Container(
                                        margin:
                                            EdgeInsets.fromLTRB(16, 20, 16, 20),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: primaryColor),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Edit Event",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                      onTap: () async {
                                        LoadingFunc.show(context);
                                        if (_formKey.currentState!.validate()) {
                                          isFest
                                              ? await updateFest()
                                              : eventType != null
                                                  ? await updateChildEvent()
                                                  : Fluttertoast.showToast(
                                                      msg:
                                                          "Some Fields are left empty!\n Please Fill the form with all Details",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          Colors.grey[700],
                                                      textColor: Colors.red,
                                                      fontSize: 16.0);
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
                                        }
                                        LoadingFunc.end();
                                      },
                                    )
                                  ],
                                ),
                              );
                            });
                          });
                    } else
                      return loadingWidget();
                  }))),
    );
  }

  updateChildEvent() async {
    eventData = await db.getFest(parentId);

    //print(eh);

    // print(
    //     "${eventData.dateFrom} ${DateTime.parse(dateFrom.text)}");
    if ((DateTime.parse(dateFrom.text).isAfter(eventData!.dateFrom!) ||
                DateTime.parse(dateFrom.text)
                    .isAtSameMomentAs(eventData!.dateFrom!)) &&
            (DateTime.parse(dateTo.text).isBefore(eventData!.dateTo!)) ||
        DateTime.parse(dateTo.text).isAtSameMomentAs(eventData!.dateTo!)) {
      _controller.forEach((i) {
        rules.add(i.text.trim());
      });
      List<String> headIds = [];
      List<String> volIds = [];
//Update Roles
      if (eventhead.isNotEmpty) {
        eventhead.forEach((h) {
          headIds.add(h.uid!);
        });
      }
      eh.forEach((h) {
        db.updateRoles(h, widget.event!, headIds, 2);
      });
      if (eventvol.isNotEmpty) {
        eventvol.forEach((h) {
          volIds.add(h.uid!);
        });
      }
      ev.forEach((h) {
        db.updateRoles(h, widget.event!, volIds, 1);
      });
      int? typei,
          _price,
          participationPoints,
          runnerUpPoints,
          winnerPoints,
          participantsLimit,
          volunteersLimit,
          volunteersPoints,
          eventHeadsPoints;

      try {
        eventTypes!.values.forEach((value) {
          if (value["name"] == eventType) {
            typei = value['id'];
          }
        });
        _price = int.parse(price.text.trim());
        participationPoints = int.parse(participationPoint.text.trim());
        runnerUpPoints = int.parse(runnerUpPoint.text.trim());
        winnerPoints = int.parse(winnerPoint.text.trim());
        participantsLimit = int.parse(participationLimit.text.trim());
        volunteersLimit = int.parse(volunteerLimit.text.trim());
        volunteersPoints = int.parse(volunteerPoints.text.trim());
        eventHeadsPoints = int.parse(eventHeadPoints.text.trim());
      } catch (e) {
        typei = 0;
        _price = 0;
        participationPoints = 0;
        runnerUpPoints = 0;
        winnerPoints = 0;
        participantsLimit = 1000;
        volunteersLimit = 20;
        volunteersPoints = 0;
        eventHeadsPoints = 0;
      }
      if (hasImage) {
        bannerUrl = await cs.uploadEventImage(
            '${name.text.trim().replaceAll(" ", "_")}-${DateTime.now().year}',
            img!);
      }
      // var pref = await SharedPreferences.getInstance();
      // var userId = pref.get(UID_KEY);

      var eventdata = {
        "name": name.text.trim(),
        "banner_url": bannerUrl,
        "description": description.text.trim(),
        "date_from": DateTime.parse(dateFrom.text),
        "date_to": DateTime.parse(dateTo.text),
        "location_type": locationType,
        "type": typei,
        "price": _price,
        "rules": rules,
        "location": location.text.trim(),
        "participation_points": participationPoints,
        "runner_up_points": runnerUpPoints,
        "winner_points": winnerPoints,
        "participants_limit": participantsLimit == 0 ? 1000 : participantsLimit,
        "volunteers_limit": volunteersLimit == 0 ? 20 : volunteersLimit,
        "volunteer_points": volunteersPoints,
        "event_head_points": eventHeadsPoints,
        "meet_link": eventMeetingURL.text.trim(),
        "event_logistics_url": eventLogisticURL.text.trim(),
        "registration_url": registrationURL.text.trim(),
        "feedback_url": feedbackURL.text.trim(),
        "event_heads": headIds,
        "volunteers": volIds,
        "for_sakec": forSakec,
        "parent_id": parentId
      };

      db.updateEvent(eventdata, widget.event!.id!);

      if (parentId != widget.event!.parentId) {
        db.updateChildEvent(parentId, widget.event!.id!);
        var parentData = await db.getFest(widget.event!.parentId);
        parentData.childId?.remove(widget.event!.id);
        db.updateFest(Map<String, Object?>.from(festToJson(parentData)),
            widget.event!.parentId);
      }
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Update Successful",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Invalid data",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[700],
          textColor: Colors.red,
          fontSize: 16.0);
    }
  }

  updateFest() async {
    _controller.forEach((i) {
      rules.add(i.text.trim());
    });
    List<String> headIds = [];
    List<String> volIds = [];
//Update Roles
    if (eventhead.isNotEmpty) {
      eventhead.forEach((h) {
        headIds.add(h.uid!);
      });
    }
    eh.forEach((h) {
      db.updateRoles(h, widget.event!, headIds, 2);
    });
    if (eventvol.isNotEmpty) {
      eventvol.forEach((h) {
        volIds.add(h.uid!);
      });
    }
    ev.forEach((h) {
      db.updateRoles(h, widget.event!, volIds, 1);
    });
    int volunteersPoints, eventHeadsPoints;

    try {
      volunteersPoints = int.parse(volunteerPoints.text.trim());
      eventHeadsPoints = int.parse(eventHeadPoints.text.trim());
    } catch (e) {
      volunteersPoints = 0;
      eventHeadsPoints = 0;
    }
    if (hasImage) {
      bannerUrl = await cs.uploadFestImage(
          '${name.text.trim().replaceAll(" ", "_")}-${DateTime.now().year}',
          img!);
    }
    // var pref = await SharedPreferences.getInstance();
    // var userId = pref.get(UID_KEY);

    var eventdata = {
      "name": name.text.trim(),
      "icon": index,
      "banner_url": bannerUrl,
      "description": description.text.trim(),
      "date_from": DateTime.parse(dateFrom.text),
      "date_to": DateTime.parse(dateTo.text),
      "location_type": locationType,
      "rules": rules,
      "volunteer_points": volunteersPoints,
      "event_head_points": eventHeadsPoints,
      "event_heads": headIds,
      "volunteers": volIds,
      "for_sakec": forSakec,
    };

    db.updateFest(eventdata, widget.event!.id!);
    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: "Update Successful",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}

String? validateIsEmpty(value) {
  if (value.isEmpty) {
    return "Field Cannot be Empty";
  }
  return null;
}

/*
name
description
datefrom
dateto
type
rules
price
event heads
volunteers
location
participation points
runnerup points
winner points
participation limit
volunteer limit


createdby


*/