import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/leaderBoard.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/adminInterCollegePage.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeCricketHome.dart';
import 'package:pratishtha/services/interCollegeServices.dart';
import 'package:pratishtha/widgets/interCollegeSportsButton.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';

class InterCollegeHome extends StatefulWidget {
  final int userRole;
  InterCollegeHome({
    super.key,
    required this.userRole,
  });

  @override
  State<InterCollegeHome> createState() => _InterCollegeHomeState();
}

class _InterCollegeHomeState extends State<InterCollegeHome>
    with TickerProviderStateMixin {
  late final GifController _gifController;
  bool _controllerInitialized = false;
  bool _imagePrecached = false;
  final List<String> carouselImages = [];
  int _currentCarouselIndex = 0;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  // bool isSheetReady = false;
  final GlobalKey sheetKey = GlobalKey();
  double sheetSize = 0.7;

  bool isOutdoorExpanded = false;
  bool isIndoorExpanded = false;

  final List<Map<String, dynamic>> interCollegeOutdoorSportsEventsData = [
    {
      'icon': Image.asset('assets/images/InterCollegeSports/football.jpeg'),
      'name': 'Football',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
    {
      'icon': Image.asset('assets/images/InterCollegeSports/basketball.jpeg'),
      'name': 'Basketball',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
    {
      'icon':
          Image.asset('assets/images/InterCollegeSports/volleyball_boys.jpeg'),
      'name': 'Cricket',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
    {
      'icon': Image.asset('assets/images/InterCollegeSports/football.png'),
      'name': 'Cricket',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
    {
      'icon': Image.asset('assets/images/InterCollegeSports/football.png'),
      'name': 'Cricket',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
    {
      'icon': Image.asset('assets/images/InterCollegeSports/football.png'),
      'name': 'Cricket',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
  ];

  final List<Map<String, dynamic>> interCollegeIndoorSportsEventsData = [
    {
      'icon': Image.asset(
        'assets/images/InterCollegeSports/powerlifting.png',
        fit: BoxFit.cover,
      ),
      'name': 'Football',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
    {
      'icon': Image.asset('assets/images/InterCollegeSports/football.png'),
      'name': 'Basketball',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
    {
      'icon': Image.asset('assets/images/InterCollegeSports/football.png'),
      'name': 'Cricket',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
    {
      'icon': Image.asset('assets/images/InterCollegeSports/football.png'),
      'name': 'Cricket',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
    {
      'icon': Image.asset('assets/images/InterCollegeSports/football.png'),
      'name': 'Cricket',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
    {
      'icon': Image.asset('assets/images/InterCollegeSports/football.png'),
      'name': 'Cricket',
      'navigator': MaterialPageRoute(
          builder: (context) =>
              InterCollegeCricketHome(currentAcademicYear: '2024-2025')),
    },
  ];

  void toggleOutdoorExpansion(bool expand) {
    setState(() {
      isOutdoorExpanded = expand;
      _sheetController.animateTo(
        expand ? 0.99 : 0.7,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void toggleIndoorExpansion(bool expand) {
    setState(() {
      isIndoorExpanded = expand;
      _sheetController.animateTo(
        expand ? 0.99 : 0.7,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget buildEventGrid(List<Map<String, dynamic>> eventData) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: eventData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final event = eventData[index];
        return InterCollegeSportsButton(
          context: context,
          sportsIcon: event['icon'] as Image,
          sportsName: event['name'] as String,
          navigator: event['navigator'] as MaterialPageRoute,
        );
      },
    );
  }

  Widget outdoorSportsSection(
      BuildContext context, List<Map<String, dynamic>> outdoorEvents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "Outdoor Sports",
            style: GoogleFonts.robotoSlab(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 12),
          child: Column(
            children: [
              SizedBox(height: 10),
              isOutdoorExpanded
                  ? buildEventGrid(outdoorEvents)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: outdoorEvents
                                .take(3)
                                .map(
                                  (event) => InterCollegeSportsButton(
                                    context: context,
                                    sportsIcon: event['icon'] as Image,
                                    sportsName: event['name'] as String,
                                    navigator:
                                        event['navigator'] as MaterialPageRoute,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: IconButton(
                              onPressed: () {
                                if (!isOutdoorExpanded) {
                                  GestureDetector(
                                    onTap: () => toggleOutdoorExpansion(!isOutdoorExpanded),
                                    child: Text(
                                      "See More Events ...",
                                      style: GoogleFonts.robotoSlab(
                                        color: Colors.blue[700],
                                        fontSize: 12,
                                        textStyle: TextStyle(
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.blue[700],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.arrow_forward)),
                        )
                      ],
                    ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => toggleOutdoorExpansion(true),
                    child: isOutdoorExpanded
                        ? Icon(
                            Icons.keyboard_arrow_up,
                            size: 24,
                          )
                        : Text(
                            "See More Events ...",
                            style: GoogleFonts.robotoSlab(
                              color:  Color(0xFF222232),
                              fontSize: 12,
                              decorationColor: Colors.blue[700],
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget indoorSportsSection(
      BuildContext context, List<Map<String, dynamic>> indoorEvents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "Indoor Sports",
            style: GoogleFonts.robotoSlab(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 12),
          child: Column(
            children: [
              SizedBox(height: 10),
              isIndoorExpanded
                  ? buildEventGrid(indoorEvents):
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: indoorEvents
                          .take(3)
                          .map(
                            (event) => InterCollegeSportsButton(
                              context: context,
                              sportsIcon: event['icon'] as Image,
                              sportsName: event['name'] as String,
                              navigator:
                                  event['navigator'] as MaterialPageRoute,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: IconButton(
                        onPressed: () {
                          if (!isIndoorExpanded) {
                            GestureDetector(
                              onTap: () => toggleIndoorExpansion(true),
                              child: Text(
                                "See More Events ...",
                                style: GoogleFonts.robotoSlab(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                  textStyle: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue[700],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.arrow_forward)),
                  )
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => toggleIndoorExpansion(true),
                    child: isOutdoorExpanded
                        ? Icon(
                          color:  Color(0xFF222232),
                            Icons.keyboard_arrow_up,
                            size: 24,
                          )
                        : Text(
                            "See More Events ...",
                            style: GoogleFonts.robotoSlab(
                              color: const Color.fromARGB(255, 87, 87, 87),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue[700],
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagePrecached) {
      precacheImage(
        AssetImage('assets/gifs/leaderboard_intercollege.gif'),
        context,
      ).then((_) {
        setState(() {
          _imagePrecached = true;
        });
      });
    }
    if (!_controllerInitialized) {
      _gifController = GifController(vsync: this);
      _controllerInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChange);
    _fetchImages();
  }

  void _onSheetChange() {
    // Update expansion state based on sheet position
    setState(() {
      if (_sheetController.size >= 0.9) {
        isOutdoorExpanded = true;
        isIndoorExpanded = true;
      } else {
        isOutdoorExpanded = false;
        isIndoorExpanded = false;
      }
    });
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChange);
    _gifController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _fetchImages() async {
    try {
      final List<String> urls =
          await InterCollegeServices().fetchImagesFromFirebase();
      setState(() {
        carouselImages.addAll(urls);
      });
    } catch (error) {
      print("Error fetching images: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_imagePrecached) {
      return Center(child: loadingWidget());
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 30,
        ),
        backgroundColor: Color.fromRGBO(120, 78, 209, 1),
        centerTitle: true,
        title: Text(
          "Inter College",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaderBoard()),
              );
            },
            child: Container(
                padding: EdgeInsets.only(right: 10),
                child: Gif(
                  controller: _gifController,
                  image: AssetImage('assets/gifs/leaderboard_intercollege.gif'),
                  height: 50,
                  fit: BoxFit.contain,
                  autostart: Autostart.loop,
                )),
          ),
        ],
      ),
      floatingActionButton: widget.userRole == 8
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AdminInterCollegePage()));
              },
              child: Icon(
                Icons.add,
                size: 40,
              ),
            )
          : null,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            color: Color.fromRGBO(120, 78, 209, 1),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10), 
                  padding: const EdgeInsets.only(top: 5.0),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.22,
                      viewportFraction: 0.8,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 5),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentCarouselIndex = index;
                        });
                      },
                    ),
                    items: carouselImages.map((img) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 350
                                : MediaQuery.of(context).size.width - 100,
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: CachedNetworkImage(
                                imageUrl: img,
                                fit: BoxFit.fill,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: carouselImages.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                            _currentCarouselIndex == entry.key ? 1.0 : 0.4,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
              key: sheetKey,
              controller: _sheetController,
              initialChildSize:
                  MediaQuery.of(context).size.height > 700 ? 0.65 : 0.2,
              minChildSize:
                  MediaQuery.of(context).size.height > 700 ? 0.65 : 0.2,
              maxChildSize: 0.99,
              snap: true,
              snapSizes: [0.65, 0.99],
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        outdoorSportsSection(
                            context, interCollegeOutdoorSportsEventsData),
                        SizedBox(
                          height: 10,
                        ),
                        indoorSportsSection(
                            context, interCollegeIndoorSportsEventsData),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
