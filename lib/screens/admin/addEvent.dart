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
import 'package:pratishtha/widgets/connectivityChecker.dart';
import 'package:pratishtha/widgets/customTextField.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/widgets/funcLoading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AddEvent extends StatefulWidget {
  const AddEvent();

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
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

  final TextEditingController search = TextEditingController();

  List<TextEditingController> _controller = [];

  List<Widget> _children = [];

  Event? eventData;

  List rules = [];

  List<String> typ = [];

  bool forSakec = false;

  int _count = 0;

  bool isFest = false;

  bool isIndivisual = false;

  var db = DatabaseServices();
  var cs = StorageServices();

  List<User> eventhead = [];

  String? _dropdown;

  Map? eventTypes;

  Icon? festIcon;
  String parentId = '';
  bool hasImage = false;
  File? img;
  String bannerUrl = "";
  int? index;
  String? type;
  String? locationType;
  final addkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // dateFrom.text = DateTime.now().toString();
    // dateTo.text = DateTime.now().toString();
    _controller.add(TextEditingController());
    _children.add(Container(
        child: CustomTextField1(
      hintText: "Rule $_count",
      validator: validateIsEmpty,
      controller: _controller[_count],
    )));
    setState(() => ++_count);
  }

  @override
  Widget build(BuildContext context) {
    return checkConection(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Event"),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Form(
            key: addkey,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Event is a Fest? ",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Switch(
                            focusColor: Colors.amber,
                            thumbColor: WidgetStatePropertyAll(Colors.white),
                            trackColor: WidgetStatePropertyAll(primaryColor),
                            value: isFest,
                            onChanged: (val) {
                              setState(() {
                                isFest = val;
                                print(isFest);
                                if (!val) isIndivisual = false;
                                if (!val) parentId = "";
                              });
                            },
                          ),
                        ],
                      ),
                      isFest
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Individual Event? ",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Switch(
                                    value: isIndivisual,
                                    onChanged: (val) {
                                      setState(() {
                                        isIndivisual = val;
                                      });
                                    }),
                              ],
                            )
                          : SizedBox.shrink(),
                      !isFest
                          ? FutureBuilder<List<Event>>(
                              future: db.getFests(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var events = snapshot.data;

                                  List<String> e = [];
                                  events?.forEach((i) {
                                    e.add(i.name!);
                                  });

                                  return DropdownButton<String>(
                                    focusColor: Colors.black,
                                    underline: const SizedBox(),
                                    value: _dropdown,
                                    elevation: 5,
                                    style: const TextStyle(color: Colors.black),
                                    iconEnabledColor: Colors.black,
                                    items: e.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    hint: const Text(
                                      "Select Parent Event",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() {
                                        _dropdown = value;
                                        parentId =
                                            events![e.indexOf(value!)].id!;
                                        eventData = events[e.indexOf(value)];
                                      });
                                      //print(parentId);
                                    },
                                  );
                                } else
                                  return CircularProgressIndicator();
                              })
                          : DropdownButton<Icon>(
                              focusColor: Colors.black,
                              underline: const SizedBox(),
                              value: festIcon,
                              elevation: 5,
                              //dropdownColor: primaryColor,
                              style: const TextStyle(color: Colors.black),
                              iconEnabledColor: Colors.black,
                              items: festIcons
                                  ?.map<DropdownMenuItem<Icon>>((Icon value) {
                                return DropdownMenuItem<Icon>(
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
                                    fontWeight: FontWeight.w500),
                              ),
                              onChanged: (Icon? value) {
                                setState(() {
                                  festIcon = value;
                                  parentId = "";
                                  index = festIcons?.indexOf(value!);
                                });
                              },
                            )
                    ],
                  ),
                ),
                CustomTextField1(
                  controller: name,
                  hintText: 'Enter Event Name',
                  labelText: 'Event Name',
                  validator: validateIsEmpty,
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                ),
                CustomTextField1(
                  controller: description,
                  hintText: 'Enter Event Description',
                  labelText: 'Event Description',
                  validator: validateIsEmpty,
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                ),
                !isFest || isIndivisual
                    ? FutureBuilder<Map<dynamic, dynamic>>(
                        future: getEventTypesListFromPrefs(),
                        builder: (context, snap) {
                          if (snap.hasData) {
                            eventTypes = snap.data;
                            typ.clear();
                            eventTypes?.forEach((i, j) {
                              typ.add(j["name"]);
                            });
                            return StatefulBuilder(builder: (context, ss) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.2),
                                      style: BorderStyle.solid,
                                      width: 1.5,
                                    )),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: DropdownButton<String>(
                                  underline: const SizedBox(),
                                  isExpanded: true,
                                  value: type,
                                  borderRadius: BorderRadius.circular(15),
                                  elevation: 5,
                                  style: const TextStyle(color: Colors.black),
                                  iconEnabledColor: Colors.black,
                                  items: typ.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),
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
                                  onChanged: (String? value) {
                                    setState(() {
                                      type = value;
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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: DateTimePicker(
                    timeFieldWidth: 150,
                    type: DateTimePickerType.dateTimeSeparate,
                    dateMask: 'd MMMM, yyyy',
                    initialTime: TimeOfDay.now(),
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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: DateTimePicker(
                    timeFieldWidth: 150,
                    type: DateTimePickerType.dateTimeSeparate,
                    dateMask: 'd MMMM, yyyy',

                    initialTime: TimeOfDay.now(),
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
                !isFest || isIndivisual
                    ? CustomTextField1(
                        controller: location,
                        hintText: 'Enter Location',
                        labelText: 'Event Location',
                        validator: validateIsEmpty,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      )
                    : SizedBox.shrink(),
                StatefulBuilder(builder: (context, ss) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.2),
                          style: BorderStyle.solid,
                          width: 1.5,
                        )),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: DropdownButton<String>(
                      underline: const SizedBox(),
                      isExpanded: true,
                      value: locationType,
                      borderRadius: BorderRadius.circular(15),
                      elevation: 5,
                      style: const TextStyle(color: Colors.black),
                      iconEnabledColor: Colors.black,
                      items: LocationType.map<DropdownMenuItem<String>>(
                          (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
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
                          locationType = value;
                        });
                        //print(parentId);
                      },
                    ),
                  );
                }),
                !isFest || isIndivisual
                    ? CustomTextField1(
                        controller: price,
                        hintText: 'Enter Event Price',
                        labelText: 'Event Price',
                        keyboardType: TextInputType.number,
                        validator: validateIsEmpty,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      )
                    : SizedBox.shrink(),
                !isFest || isIndivisual
                    ? CustomTextField1(
                        controller: participationPoint,
                        hintText: 'Enter Participation Points',
                        labelText: 'Participation Points',
                        keyboardType: TextInputType.number,
                        validator: validateIsEmpty,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      )
                    : SizedBox.shrink(),
                !isFest || isIndivisual
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
                  margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Text(
                          "Enter Rules",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _children +
                              [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          _controller
                                              .add(TextEditingController());
                                          _children = List.from(_children)
                                            ..add(Container(
                                                child: CustomTextField1(
                                              hintText: "Rule $_count",
                                              validator: validateIsEmpty,
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
                                              controller: _controller[_count],
                                            )));
                                          setState(() => ++_count);
                                        },
                                        icon: Icon(
                                          Icons.add_box,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          if (_count > 0) {
                                            setState(() {
                                              _children.removeLast();
                                              // if (rules.isNotEmpty) {
                                              //   rules.removeLast();
                                              // }
                                              --_count;
                                              _controller.removeLast();
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
                !isFest || isIndivisual
                    ? CustomTextField1(
                        controller: winnerPoint,
                        hintText: 'Enter Winner Points',
                        labelText: 'Winner Points',
                        validator: validateIsEmpty,
                        keyboardType: TextInputType.number,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      )
                    : SizedBox.shrink(),
                !isFest || isIndivisual
                    ? CustomTextField1(
                        controller: participationLimit,
                        hintText: 'Enter Participation Limit',
                        labelText: 'Participation Limit',
                        validator: validateIsEmpty,
                        keyboardType: TextInputType.number,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      )
                    : SizedBox.shrink(),
                !isFest || isIndivisual
                    ? CustomTextField1(
                        controller: volunteerLimit,
                        hintText: 'Enter Volunteer Limit',
                        labelText: 'Volunteer Limit',
                        validator: validateIsEmpty,
                        keyboardType: TextInputType.number,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      )
                    : SizedBox.shrink(),
                CustomTextField1(
                  controller: volunteerPoints,
                  hintText: 'Enter Volunteer Points',
                  labelText: 'Volunteer Points',
                  validator: validateIsEmpty,
                  keyboardType: TextInputType.number,
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                ),
                CustomTextField1(
                  controller: eventHeadPoints,
                  hintText: 'Enter Event Head Points',
                  labelText: 'Event Head Points',
                  validator: validateIsEmpty,
                  keyboardType: TextInputType.number,
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                ),
                !isFest || isIndivisual
                    ? CustomTextField1(
                        controller: eventMeetingURL,
                        hintText: 'Enter Meeting URL',
                        labelText: 'Event Meeting URL',
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      )
                    : SizedBox.shrink(),
                !isFest || isIndivisual
                    ? CustomTextField1(
                        controller: eventLogisticURL,
                        hintText: 'Enter Logistics URL',
                        labelText: 'Event Logistics URL',
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      )
                    : SizedBox.shrink(),
                !isFest || isIndivisual
                    ? CustomTextField1(
                        controller: registrationURL,
                        hintText: 'Enter Registration URL',
                        labelText: 'Event Registration URL',
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ),
                      )
                    : SizedBox.shrink(),
                !isFest || isIndivisual
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
                  margin: EdgeInsets.fromLTRB(16, 10, 16, 10),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: StatefulBuilder(builder: (context, setS) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Event Heads",
                              style: TextStyle(fontSize: 16),
                            ),
                            Spacer(),
                            IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    elevation: 10,
                                    isScrollControlled: true,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                    ),
                                    builder: (context) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                1.5,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(10),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(10),
                                          ),
                                          child: FutureBuilder<List<User>>(
                                              future: db.getSakecUsers(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  var data = snapshot.data;
                                                  List<User> srch = [];
                                                  srch.addAll(data!);
                                                  List istapped = List.generate(
                                                      data.length,
                                                      (index) => false);
                                                  return StatefulBuilder(
                                                      builder: (context, ss) {
                                                    return Column(
                                                      children: [
                                                        Container(
                                                          color: Colors.white,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 15,
                                                                  horizontal:
                                                                      10),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "Select Event Head",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                              Spacer(),
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  setS(() {
                                                                    srch.clear();
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  color: Colors
                                                                      .lightBlue,
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          4,
                                                                          2,
                                                                          4,
                                                                          3),
                                                                  child: Text(
                                                                    "Save",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          color: Colors.white,
                                                          child:
                                                              CustomTextField1(
                                                            controller: search,
                                                            hintText:
                                                                'Enter User Name',
                                                            labelText:
                                                                'Enter User Name',
                                                            labelStyle:
                                                                TextStyle(
                                                              color: Colors
                                                                  .black87,
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
                                                                    srch.addAll(userSearch(
                                                                        allUsersList:
                                                                            data,
                                                                        query: search
                                                                            .text
                                                                            .trim()));
                                                                  });
                                                                },
                                                                child: Icon(
                                                                  Icons.search,
                                                                  color: Colors
                                                                      .black87,
                                                                  size: 24,
                                                                )),
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child:
                                                              ListView.builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount: srch
                                                                      .length,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return ListTile(
                                                                      tileColor: istapped[
                                                                              index]
                                                                          ? Colors
                                                                              .blue
                                                                          : Colors
                                                                              .white,
                                                                      title: Text(
                                                                          "${srch[index].firstName} ${srch[index].lastName}"),
                                                                      onTap:
                                                                          () {
                                                                        if (!istapped[
                                                                            index]) {
                                                                          var contain = eventhead.where((element) =>
                                                                              element.smartcardNo ==
                                                                              srch[index].smartcardNo);
                                                                          if (contain
                                                                              .isEmpty) {
                                                                            setState(() {
                                                                              eventhead.add(srch[index]);
                                                                            });
                                                                          }
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            eventhead.remove(srch[index]);
                                                                          });
                                                                        }
                                                                        ss(() {
                                                                          istapped[index] =
                                                                              !istapped[index];
                                                                        });
                                                                      },
                                                                    );
                                                                  }),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                                } else {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                              }),
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.add))
                          ],
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: eventhead.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  "${eventhead[index].firstName} ${eventhead[index].lastName}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                trailing: InkWell(
                                    onTap: () {
                                      setS(() {
                                        eventhead.removeAt(index);
                                      });
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                    )),
                              );
                            })
                      ],
                    );
                  }),
                ),
                Container(
                  margin: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                "Add Event Image",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                      hasImage
                          ? AspectRatio(
                              aspectRatio: 16 / 9, child: Image.file(img!))
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
                      color: primaryColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Add Event",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  onTap: () async {
                    LoadingFunc.show(context);

                    if (addkey.currentState!.validate()) {
                      if (isFest) {
                        if (isIndivisual)
                          await addIndivisualEvent();
                        else
                          await addFest();
                      } else {
                        await addChildEvent();
                      }
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  addChildEvent() async {
    var uid = Uuid();
    String id = uid.v4().split("-").join("");

    if (eventData == null) {
      Fluttertoast.showToast(
          msg: "Please select a parent event",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[700],
          textColor: Colors.red,
          fontSize: 16.0);
      return;
    }

    DateTime newEventStart = DateTime.parse(dateFrom.text);
    DateTime newEventEnd = DateTime.parse(dateTo.text);

    bool isValidDate = isFest ||
        (newEventStart.isAfter(eventData!.dateFrom!) &&
            newEventEnd.isBefore(eventData!.dateTo!) &&
            newEventStart.isBefore(newEventEnd));

    if (!isValidDate) {
      Fluttertoast.showToast(
          msg:
              "Event dates must be within the parent event's date range (${eventData!.dateFrom!.toString()} to ${eventData!.dateTo!.toString()}) and start date must be before end date",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[700],
          textColor: Colors.red,
          fontSize: 16.0);
      return;
    }

    // Collect rules
    _controller.forEach((i) {
      rules.add(i.text.trim());
    });

    // Collect event head IDs
    List<String> headIds = [];
    eventhead.forEach((h) {
      headIds.add(h.uid!);
    });

    // Parse and validate numeric inputs
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
      typei =
          eventTypes?.values.firstWhere((value) => value["name"] == type)['id'];
      _price = int.parse(price.text.trim());
      participationPoints = int.parse(participationPoint.text.trim());
      runnerUpPoints = int.parse(runnerUpPoint.text.trim());
      winnerPoints = int.parse(winnerPoint.text.trim());
      participantsLimit = int.parse(participationLimit.text.trim());
      volunteersLimit = int.parse(volunteerLimit.text.trim());
      volunteersPoints = int.parse(volunteerPoints.text.trim());
      eventHeadsPoints = int.parse(eventHeadPoints.text.trim());
    } catch (e) {
      print("Error parsing numeric inputs: $e");
      Fluttertoast.showToast(
          msg: "Invalid numeric input. Please check all number fields.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[700],
          textColor: Colors.red,
          fontSize: 16.0);
      return;
    }

    // Upload image if present
    if (hasImage && img != null) {
      try {
        bannerUrl = await cs.uploadEventImage(
            '${name.text.trim().replaceAll(" ", "_")}-${DateTime.now().year}',
            img!);
      } catch (e) {
        print("Error uploading image: $e");
        Fluttertoast.showToast(
            msg: "Failed to upload event image. Continuing without image.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[700],
            textColor: Colors.red,
            fontSize: 16.0);
        bannerUrl = ""; // Set bannerUrl to an empty string if upload fails
      }
    }

    // Get current user ID
    var pref = await SharedPreferences.getInstance();
    var userId = pref.getString(UID_KEY);

    // Create event data object
    var eventdata = Event(
      id: id,
      name: name.text.trim(),
      bannerUrl: bannerUrl,
      price: _price,
      description: description.text.trim(),
      dateFrom: newEventStart,
      dateTo: newEventEnd,
      type: typei!,
      rules: rules,
      location: location.text.trim(),
      locationType: locationType!,
      participationPoints: participationPoints,
      runnerUpPoints: runnerUpPoints,
      winnerPoints: winnerPoints,
      participantsLimit: participantsLimit,
      volunteersLimit: volunteersLimit,
      volunteerPoints: volunteersPoints,
      eventHeadPoints: eventHeadsPoints,
      meetLink: eventMeetingURL.text.trim(),
      eventLogisticsUrl: eventLogisticURL.text.trim(),
      registrationUrl: registrationURL.text.trim(),
      feedbackUrl: feedbackURL.text.trim(),
      eventHeads: headIds,
      parentId: parentId,
      softDelete: false,
      goLive: false,
      forSakec: forSakec,
      createdBy: userId,
    );

    try {
      // Add event to database
      var doc = await db.addEvent(eventdata, id);

      // Update parent event
      await db.updateChildEvent(parentId, id);

      // Update roles for event heads
      // for (var headId in headIds) {
      //   await db.updateRoles(headId, Event(id: doc.uid), headIds, 2);
      // }

      // Success
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Event Added Successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    } catch (e) {
      print("Error adding event: $e");
      Fluttertoast.showToast(
          msg: "Failed to add event. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[700],
          textColor: Colors.red,
          fontSize: 16.0);
    }
  }

  addFest() async {
    var uid = Uuid();
    String id = uid.v4().split("-").join("");

    _controller.forEach((i) {
      rules.add(i.text.trim());
    });
    List<String> headIds = [];
    eventhead.forEach((h) {
      headIds.add(h.uid!);
    });
    int volunteersPoints, eventHeadsPoints;

    try {
      volunteersPoints = int.parse(volunteerPoints.text.trim());
      eventHeadsPoints = int.parse(eventHeadPoints.text.trim());
    } catch (e) {
      //print(e);
      volunteersPoints = 0;
      eventHeadsPoints = 0;
    }
    if (hasImage) {
      bannerUrl = await cs.uploadFestImage(
          '${name.text.trim().replaceAll(" ", "_")}-${DateTime.now().year}',
          img!);
    }
    var pref = await SharedPreferences.getInstance();
    var userId = pref.getString(UID_KEY);

    var eventdata = Event(
      id: id,
      name: name.text.trim(),
      bannerUrl: bannerUrl,
      description: description.text.trim(),
      dateFrom: DateTime.parse(dateFrom.text),
      dateTo: DateTime.parse(dateTo.text),
      rules: rules,
      icon: index,
      isEvent: isIndivisual,
      locationType: locationType!,
      volunteerPoints: volunteersPoints,
      eventHeadPoints: eventHeadsPoints,
      eventHeads: headIds,
      parentId: "",
      softDelete: false,
      goLive: false,
      forSakec: forSakec,
      createdBy: userId,
    );

    var doc = await db.addFest(eventdata, id);
    headIds.forEach((h) {
      db.updateRoles(h, Event(id: doc.uid), headIds, 2);
    });

    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: "Fest Added Successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  addIndivisualEvent() async {
    var uid = Uuid();
    String fid = uid.v4().split("-").join("");
    String eid = uid.v4().split("-").join("");

    _controller.forEach((i) {
      rules.add(i.text.trim());
    });
    List<String> headIds = [];
    eventhead.forEach((h) {
      headIds.add(h.uid!);
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
      eventTypes?.values.forEach((value) {
        if (value["name"] == type) {
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
      //print(e);
      typei = 0;
      _price = 0;
      participationPoints = 0;
      runnerUpPoints = 0;
      winnerPoints = 0;
      participantsLimit = 0;
      volunteersLimit = 0;
      volunteersPoints = 0;
      eventHeadsPoints = 0;
    }
    if (hasImage) {
      bannerUrl = await cs.uploadFestImage(
          '${name.text.trim().replaceAll(" ", "_")}-${DateTime.now().year}',
          img!);
    }
    var pref = await SharedPreferences.getInstance();
    var userId = pref.getString(UID_KEY);

    var festdata = Event(
      id: fid,
      name: name.text.trim(),
      bannerUrl: bannerUrl,
      description: description.text.trim(),
      dateFrom: DateTime.parse(dateFrom.text),
      dateTo: DateTime.parse(dateTo.text),
      rules: rules,
      icon: index,
      locationType: locationType!,
      isEvent: isIndivisual,
      volunteerPoints: 0,
      eventHeadPoints: 0,
      eventHeads: [],
      parentId: "",
      childId: [eid],
      softDelete: false,
      goLive: false,
      forSakec: forSakec,
      createdBy: userId,
    );

    var eventdata = Event(
      id: eid,
      name: name.text.trim(),
      bannerUrl: bannerUrl,
      price: _price,
      description: description.text.trim(),
      dateFrom: DateTime.parse(dateFrom.text),
      dateTo: DateTime.parse(dateTo.text),
      type: typei!,
      rules: rules,
      location: location.text.trim(),
      locationType: locationType!,
      participationPoints: participationPoints,
      runnerUpPoints: runnerUpPoints,
      winnerPoints: winnerPoints,
      participantsLimit: participantsLimit,
      volunteersLimit: volunteersLimit,
      volunteerPoints: volunteersPoints,
      eventHeadPoints: eventHeadsPoints,
      meetLink: eventMeetingURL.text.trim(),
      eventLogisticsUrl: eventLogisticURL.text.trim(),
      registrationUrl: registrationURL.text.trim(),
      feedbackUrl: feedbackURL.text.trim(),
      eventHeads: headIds,
      parentId: fid,
      softDelete: false,
      goLive: false,
      forSakec: forSakec,
      createdBy: userId,
    );

    var doc = await db.addFest(festdata, fid);
    var doc1 = await db.addEvent(eventdata, eid);
    headIds.forEach((h) {
      db.updateRoles(h, Event(id: eid), headIds, 2);
    });

    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: "Event Added Successfully",
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