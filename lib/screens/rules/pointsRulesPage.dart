import 'package:flutter/material.dart';
import 'package:pratishtha/constants/keys.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/noContentWidget.dart';
import 'package:pratishtha/widgets/rulesCard.dart';

class PointsRulesPage extends StatefulWidget {
  @override
  _PointsRulesPageState createState() => _PointsRulesPageState();
}

class _PointsRulesPageState extends State<PointsRulesPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getRulesFromPrefs(),
        builder: (context, AsyncSnapshot<Map> snapshot){
          if(snapshot.hasData){
            if(!snapshot.data!.containsKey(ruleKeys[6])){
              return Center(
                child: noContentWidget(),
              );
            }
            return RulesWidget(rules: snapshot.data![ruleKeys[6]]["rules"]);
          } else if(snapshot.hasError){
            return CustomErrorWidget();
          } else{
            return Center(child: loadingWidget());
          }
        }
    );
  }
}