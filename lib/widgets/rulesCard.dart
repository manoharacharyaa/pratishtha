import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pratishtha/constants/colors.dart';

Widget rulesIconButton({BuildContext? context, Widget? popUpPage}) {
  return IconButton(
    icon: Icon(FontAwesomeIcons.circleQuestion),
    onPressed: () {
      showDialog(
          context: context!,
          builder: (context) {
            return AlertDialog(
                title: Text("Instructions", textAlign: TextAlign.center),
                content: AspectRatio(
                  aspectRatio: 2.5 / 5,
                  child: Container(
                      //height: MediaQuery.of(context).size.height/1.7,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: popUpPage),
                ));
          });
    },
  );
}

class RulesCard extends StatelessWidget {
  Map? rule;
  int? index;
  RulesCard({this.rule, this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * (4 / 2.5),
      decoration: BoxDecoration(
          color: whiteColor,
          //boxShadow: [containerShadow],
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: primaryColor,
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(color: whiteColor),
              ),
            ),
          ),
          Spacer(),
          //SizedBox(height: 40),
          Text(
            rule?["text"].replaceAll("\\n", "\n"),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          rule?['image'] != null
              ? Container(
                  height: MediaQuery.of(context).size.height / 4,
                  child: Image(
                      image: NetworkImage(rule!['image']),
                      fit: BoxFit.fitHeight))
              : Container(),
          Spacer()
        ],
      ),
    );
  }
}

class RulesWidget extends StatefulWidget {
  List? rules;
  RulesWidget({this.rules});

  @override
  _RulesWidgetState createState() => _RulesWidgetState();
}

class _RulesWidgetState extends State<RulesWidget> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  List<Widget> getRuleCards() {
    List<Widget> ruleCards = [];
    int index = 1;
    this.widget.rules?.forEach((rule) {
      ruleCards.add(RulesCard(rule: rule, index: index));
      index += 1;
    });
    return ruleCards;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Expanded(
          child: CarouselSlider(
            items: getRuleCards(),
            carouselController: _controller,
            options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                aspectRatio: 2.5 / 3.5,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: this.widget.rules!.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor
                        .withOpacity(_current == entry.key ? 0.9 : 0.4)),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}
