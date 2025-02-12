import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:pratishtha/is_live_provider.dart';
import 'package:pratishtha/models/sponsorshipsModel.dart';
import 'package:pratishtha/models/userModel.dart';
import 'package:pratishtha/models/eventModel.dart';
import 'package:pratishtha/services/databaseServices.dart';
import 'package:pratishtha/utils/fonts.dart';
import 'package:pratishtha/widgets/comingSoonWidget.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/festButton.dart';
import 'package:pratishtha/widgets/eventCard.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/noContentWidget.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseServices databaseServices = DatabaseServices();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IsLiveProvider>();
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        return Future.delayed(Duration(seconds: 1));
      },
      child: Scaffold(
        body: FutureBuilder(
          future: Future.wait([
            databaseServices.getEvents(),
            databaseServices.getFests(),
            databaseServices.getCurrentUser(),
            databaseServices.getSponsors(),
          ]),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: loadingWidget());
            } else if (snapshot.hasError) {
              return CustomErrorWidget();
            } else if (snapshot.hasData) {
              final User currentUser = snapshot.data[2];
              final List<Event> events = _processEvents(
                  snapshot.data[0], snapshot.data[1], currentUser);
              final List<Event> fests = _processFests(events);
              final List<Sponsorship> sponsors = snapshot.data[3];

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SponsorCarousel(sponsors: sponsors),
                      SizedBox(height: 15.0),
                      Container(child: FestList(fests: fests)),
                      SizedBox(height: 20.0),
                      //Fests Images
                      !provider.isLive
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10.0),
                                    FutureBuilder(
                                      future: databaseServices
                                          .getFestBanners(), // Assuming you have this method
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return CustomErrorWidget();
                                        } else if (snapshot.hasData) {
                                          final List<String>? bannerUrls =
                                              snapshot.data;
                                          return Column(
                                            children: bannerUrls!.map((url) {
                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 5),
                                                child: CachedNetworkImage(
                                                  imageUrl: url,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Center(
                                                    child: SizedBox(),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        } else {
                                          return CustomErrorWidget();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          // : Consumer<IsLiveProvider>(
                          //     builder: (context, provider, child) {
                          //       if (provider.enabledLiveStreams.isEmpty) {
                          //         return Center(
                          //             child: Text("No Live Streams Available"));
                          //       }

                          //       return ListView.builder(
                          //         shrinkWrap: true,
                          //         itemCount: provider.enabledLiveStreams.length,
                          //         itemBuilder: (context, index) {
                          //           final live =
                          //               provider.enabledLiveStreams[index];
                          //           return YTLiveStream(videoId: live);
                          //         },
                          //       );
                          //     },
                          //   ),

                          : Consumer<IsLiveProvider>(
                              builder: (context, provider, child) {
                                return FutureBuilder(
                                  future: provider.liveStreams(),
                                  builder: (context, snapshot) {
                                    if (snapshot.data!.isEmpty) {
                                      return Text('No Livestreams Found');
                                    }
                                    if (snapshot.hasError) {
                                      return Text('Some Error Occured');
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        final stream = snapshot.data![index];
                                        print(stream.liveId);
                                        return YTLiveStream(
                                          videoId: stream.liveId,
                                          title: stream.title,
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),

                      // SizedBox(height: 20.0),
                      // Text(
                      //   'Upcoming Events',
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.bold, fontSize: 20.0),
                      // ),
                      // SizedBox(height: 10.0),
                      // EventList(events: events, currentUser: currentUser),
                    ],
                  ),
                ),
              );
            } else {
              return CustomErrorWidget();
            }
          },
        ),
      ),
    );
  }

  List<Event> _processEvents(
      List<Event> rawEvents, List<Event> rawFests, User currentUser) {
    final List<Event> allEvents = [...rawEvents, ...rawFests];
    return allEvents.where((event) => _showEvent(event, currentUser)).toList()
      ..sort((a, b) => b.dateFrom!.compareTo(a.dateFrom!));
  }

  List<Event> _processFests(List<Event> events) {
    return events.where((event) => event.parentId == "").toList()
      ..sort((a, b) => a.dateFrom!.compareTo(b.dateFrom!));
  }

  bool _showEvent(Event event, User currentUser) {
    if (currentUser.role == 5 || currentUser.role == 3) {
      return true;
    } else if (!event.goLive) {
      return false;
    } else if (event.forSakec) {
      if (event.forFaculty) {
        return currentUser.isFaculty!;
      } else {
        return currentUser.institute == "SAKEC";
      }
    } else {
      return true;
    }
  }
}

class SponsorCarousel extends StatelessWidget {
  final List<Sponsorship> sponsors;

  const SponsorCarousel({super.key, required this.sponsors});

  @override
  Widget build(BuildContext context) {
    if (sponsors.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ComingSoonWidget(
          waveColor: Colors.purple,
          boxBackgroundColor: Colors.black,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 60,
            color: Colors.orange,
            fontFamily: 'Times New Roman',
          ),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: CarouselSlider.builder(
        itemCount: sponsors.length,
        itemBuilder: (context, index, realIndex) {
          return SponsorCard(
            context: context,
            sponsorship: sponsors[index],
          );
        },
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 16 / 9,
          viewportFraction: 0.7,
        ),
      ),
    );
  }
}

class SponsorCard extends StatelessWidget {
  final BuildContext context;
  final Sponsorship sponsorship;

  const SponsorCard(
      {super.key, required this.context, required this.sponsorship});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: sponsorship.imgUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}

class FestList extends StatelessWidget {
  final List<Event> fests;

  const FestList({super.key, required this.fests});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      height: 110,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: fests.length,
          separatorBuilder: (context, index) => SizedBox(width: 20),
          itemBuilder: (context, index) {
            return FestButton(
              event: fests[index],
              individualEventsList: [],
              context: context,
            );
          },
        ),
      ),
    );
  }
}

class YTLiveStream extends StatefulWidget {
  const YTLiveStream({super.key, required this.videoId, this.title});

  final String videoId;
  final String? title;

  @override
  State<YTLiveStream> createState() => _YTLiveStreamState();
}

class _YTLiveStreamState extends State<YTLiveStream> {
  late final WebViewController _webViewController;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          'https://www.youtube.com/embed/${widget.videoId}?autoplay=1&modestbranding=1&playsinline=1&fs=1&enablejsapi=1',
        ),
      );
  }

  void toggleFullScreen(bool enable) {
    setState(() {
      isFullScreen = enable;
    });

    if (enable) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: isFullScreen
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius:
            isFullScreen ? BorderRadius.zero : BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                isFullScreen ? BorderRadius.zero : BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: GestureDetector(
                onDoubleTap: () => toggleFullScreen(!isFullScreen),
                child: WebViewWidget(controller: _webViewController),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 0, 0),
            child: Text(
              widget.title ?? '',
              style: AppFonts.poppins(
                size: 14,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
