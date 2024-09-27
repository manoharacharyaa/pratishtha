import 'package:flutter/material.dart';
import 'package:pratishtha/constants/keys.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/noContentWidget.dart';
import 'package:pratishtha/widgets/rulesCard.dart';

class ChangeParticipantStatusRulesPage extends StatefulWidget {
  @override
  _ChangeParticipantStatusRulesPageState createState() => _ChangeParticipantStatusRulesPageState();
}

class _ChangeParticipantStatusRulesPageState extends State<ChangeParticipantStatusRulesPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getRulesFromPrefs(),
        builder: (context, AsyncSnapshot<Map> snapshot){
          if(snapshot.hasData){
            if(!snapshot.data!.containsKey(ruleKeys[2])){
              return Center(
                child: noContentWidget(),
              );
            }
            return RulesWidget(rules: snapshot.data![ruleKeys[2]]["rules"]);
          } else if(snapshot.hasError){
            return CustomErrorWidget();
          } else{
            return Center(child: loadingWidget());
          }
        }
    );
  }
}