import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:pratishtha/constants/festIcons.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Gallery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            MyLogoCarousel(),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: festColor,
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Your logic here
                        },
                        icon: Icon(Icons.sports_cricket, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Event'),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: festColor,
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Your logic here
                        },
                        icon: Icon(Icons.sports_cricket, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Event'),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: festColor,
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Your logic here
                        },
                        icon: Icon(Icons.sports_cricket, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Event'),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: festColor,
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Your logic here
                        },
                        icon: festIcons![3],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Event'),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Pratishtha 2023 Album',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ImageList(),
          ],
        ),
      ),
    );
  }
}

class MyLogoCarousel extends StatefulWidget {
  @override
  _MyLogoCarouselState createState() => _MyLogoCarouselState();
}

class _MyLogoCarouselState extends State<MyLogoCarousel> {
  final String storagePath = 'Sponsorship/Logo';
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<String> logoUrls = [];
  int currentIndex = 0;
  CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    fetchLogoUrls();
  }

  Future<void> fetchLogoUrls() async {
    try {
      ListResult result = await _storage.ref(storagePath).listAll();
      List<String> urls = [];

      for (Reference ref in result.items) {
        String url = await ref.getDownloadURL();
        urls.add(url);
      }

      setState(() {
        logoUrls = urls;
      });
    } catch (e) {
      print('Error fetching logos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return logoUrls.isNotEmpty
        ? Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: logoUrls.length,
                    options: CarouselOptions(
                      height: 180.0,
                      viewportFraction: 0.8,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 7.0),
                          child: CachedNetworkImage(
                            imageUrl: logoUrls[index],
                            fit: BoxFit.fill,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_left,
                            color: Colors.blue, size: 60),
                        onPressed: () {
                          if (currentIndex > 0) {
                            _carouselController.previousPage();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_right,
                            color: Colors.blue, size: 60),
                        onPressed: () {
                          if (currentIndex < logoUrls.length - 1) {
                            _carouselController.nextPage();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (logoUrls.length > 1)
                Text(
                  '${currentIndex + 1}/${logoUrls.length}',
                  style: TextStyle(fontSize: 20),
                ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}

class ImageList extends StatefulWidget {
  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  final String storagePathh = 'Sponsorship/Logo';
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    getImagesFromStorage();
  }

  Future<void> getImagesFromStorage() async {
    try {
      ListResult result = await storage.ref(storagePathh).list();
      result.items.forEach((Reference reference) async {
        String downloadURL = await reference.getDownloadURL();
        setState(() {
          imageUrls.add(downloadURL);
        });
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
              // height: 200,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3)),
              child: ListTile(
                title: Image.network(imageUrls[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
