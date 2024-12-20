import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pratishtha/constants/colors.dart';
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

class _InterCollegeHomeState extends State<InterCollegeHome> {
  final List<String> carouselImages = [];
  int _currentCarouselIndex = 0; // Add this line to track current index

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    try {
      final List<String> urls =
          await InterCollegeServices().fetchImagesFromFirebase();
      setState(() {
        carouselImages.addAll(urls);
      });
      print(carouselImages);
    } catch (error) {
      print("Error fetching images: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
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
          if (widget.userRole == 8)
            CircleAvatar(
              backgroundColor: secondaryColor,
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AdminInterCollegePage()));
                },
              ),
            ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaderBoard()),
              );
            },
            child: Container(
              padding: EdgeInsets.only(right: 15),
              child: Image.asset(
                'assets/gifs/leaderboard_intercollege.gif',
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            color: Color.fromRGBO(120, 78, 209, 1),
            child: Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 180,
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
                          width: 300,
                          margin:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.grey.withOpacity(0.5),
                            //     spreadRadius: 1,
                            //     blurRadius: 3,
                            //     offset: Offset(0, 3),
                            //   ),
                            // ],
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
            top: MediaQuery.of(context).size.height * 0.3,
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
                          sportsIcon: Image.asset(
                              "assets/images/InterCollegeSports/cricket_logo_intercollege.png"),
                          sportsName: "Cricket",
                          navigator: MaterialPageRoute(
                              builder: (context) => InterCollegeCricketHome()),
                        ),
                        InterCollegeSportsButton(
                          context: context,
                          sportsIcon: Image.asset(
                              "assets/images/InterCollegeSports/football_icon_intercollege.jpg"),
                          sportsName: "Football",
                          navigator: MaterialPageRoute(
                              builder: (context) => InterCollegeFootballHome()),
                        ),
                        InterCollegeSportsButton(
                          context: context,
                          sportsIcon: Image.asset(
                              "assets/images/InterCollegeSports/volleyball_logo_intercollege.jpg"),
                          sportsName: "Volleyball",
                          navigator: MaterialPageRoute(
                              builder: (context) =>
                                  InterCollegeVolleyballHome()),
                        ),
                        InterCollegeSportsButton(
                          context: context,
                          sportsIcon: Image.asset(
                              "assets/images/InterCollegeSports/kabaddi_logo_intercollege.svg"),
                          sportsName: "Kabaddi",
                          navigator: MaterialPageRoute(
                              builder: (context) => InterCollegeKabaddiHome()),
                        ),
                        InterCollegeSportsButton(
                          context: context,
                          sportsIcon: Image.asset(
                              "assets/images/InterCollegeSports/tugofwar_logo_intecollege.jpeg"),
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
