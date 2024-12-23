import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/leaderBoard.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/adminInterCollegePage.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeCricketHome.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeFootballHome.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeKabaddiHome.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeTugofWarHome.dart';
import 'package:pratishtha/screens/home/interCollegeSystem/interCollegeVolleyballHome.dart';
import 'package:pratishtha/services/interCollegeServices.dart';
import 'package:pratishtha/widgets/interCollegeSportsButton.dart';

class InterCollegeHome extends StatefulWidget {
  final int userRole;
  const InterCollegeHome({
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
    _fetchImages();
  }

  @override
  void dispose() {
    _gifController.dispose();
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
      return Center(child: CircularProgressIndicator());
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
                padding: EdgeInsets.only(right: 30),
                child: Gif(
                  controller: _gifController,
                  image: AssetImage('assets/gifs/leaderboard_intercollege.gif'),
                  height: 50,
                  fit: BoxFit.contain,
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
        alignment: Alignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            color: Color.fromRGBO(120, 78, 209, 1),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 180,
                      viewportFraction: 1.5,
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
                            width: MediaQuery.of(context).size.width - 100,
                            margin: EdgeInsets.symmetric(
                                horizontal: 7, vertical: 5),
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: ClipRRect(
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
                SizedBox(height: 10),
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
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      children: [
                        InterCollegeSportsButton(
                          context: context,
                          sportsIcon: Icon(Icons.sports_cricket),
                          sportsName: "Cricket",
                          navigator: MaterialPageRoute(
                              builder: (context) => InterCollegeCricketHome(
                                    currentAcademicYear: '2024-2025',
                                  )),
                        ),
                        InterCollegeSportsButton(
                          context: context,
                          sportsIcon: Icon(Icons.sports_football),
                          sportsName: "Football",
                          navigator: MaterialPageRoute(
                              builder: (context) => InterCollegeFootballHome()),
                        ),
                        InterCollegeSportsButton(
                          context: context,
                          sportsIcon: Icon(Icons.sports_volleyball),
                          sportsName: "Volleyball",
                          navigator: MaterialPageRoute(
                              builder: (context) =>
                                  InterCollegeVolleyballHome()),
                        ),
                        InterCollegeSportsButton(
                          context: context,
                          sportsIcon: Icon(Icons.sports_kabaddi),
                          sportsName: "Kabaddi",
                          navigator: MaterialPageRoute(
                              builder: (context) => InterCollegeKabaddiHome()),
                        ),
                        InterCollegeSportsButton(
                          context: context,
                          sportsIcon: Icon(Icons.sports_esports),
                          sportsName: "Tug of War",
                          navigator: MaterialPageRoute(
                              builder: (context) => InterCollegeTugofWarHome()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
