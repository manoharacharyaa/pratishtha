import 'package:flutter/material.dart';
import 'package:pratishtha/constants/keys.dart';
import 'package:pratishtha/services/sharedPreferencesServices.dart';
import 'package:pratishtha/widgets/errorWidget.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';
import 'package:pratishtha/widgets/noContentWidget.dart';
import 'package:pratishtha/widgets/rulesCard.dart';

class ManageSponsorshipRulesPage extends StatefulWidget {
  @override
  _ManageSponsorshipRulesPageState createState() => _ManageSponsorshipRulesPageState();
}

class _ManageSponsorshipRulesPageState extends State<ManageSponsorshipRulesPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getRulesFromPrefs(),
        builder: (context, AsyncSnapshot<Map> snapshot){
          if(snapshot.hasData){
            if(!snapshot.data!.containsKey(ruleKeys[5])){
              return Center(
                child: noContentWidget(),
              );
            }
            return RulesWidget(rules: snapshot.data![ruleKeys[5]]["rules"]);
          } else if(snapshot.hasError){
            return CustomErrorWidget();
          } else{
            return Center(child: loadingWidget());
          }
        }
    );
  }
}