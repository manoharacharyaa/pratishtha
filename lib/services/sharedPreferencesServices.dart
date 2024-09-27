import 'dart:convert';

import 'package:pratishtha/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/keys.dart';

Future<bool> setFeatureListValuesInPrefs(Map featureMap) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();

  try {
    await _prefs.setString(FEATURE_MAP_KEY, jsonEncode(featureMap));
    return true;
  } catch (e) {
    return   false;
  }

}

Future<bool> setEventTypesListInPrefs(Map eventTypesMap) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();

  try {
    await _prefs.setString(EVENT_TYPES_KEY, jsonEncode(eventTypesMap));
    return true;
  } catch (e) {
    return   false;
  }

}

Future<bool> setRulesInPrefs(Map rulesMap) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();

  try {
    await _prefs.setString(RULES_KEY, jsonEncode(rulesMap));
    return true;
  } catch (e) {
    return   false;
  }

}

Future<Map> getEventTypesListFromPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return jsonDecode(await _prefs.getString(EVENT_TYPES_KEY) ?? '') as Map;
}

Future<Map> getRulesFromPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return jsonDecode(await _prefs.getString(RULES_KEY) ?? '') as Map;
}

Future<Map> getFeatureListValuesFromPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return jsonDecode(await _prefs.getString(FEATURE_MAP_KEY) ?? '') as Map;
}

Future<bool> setValuesInPrefs(
    {String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNo,
    int? roleId}) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(UID_KEY, uid!);
  await _prefs.setString(FIRST_NAME_KEY, firstName!);
  await _prefs.setString(LAST_NAME_KEY, lastName!);
  //await _prefs.setString(EMAIL_KEY, email);
  await _prefs.setString(PHONE_KEY, phoneNo!);
  await _prefs.setInt(ROLE_ID_KEY, roleId!);

  String? tempID = await _prefs.getString(UID_KEY) ;
  String? tempFN = await _prefs.getString(FIRST_NAME_KEY);
  int? tempR = await _prefs.getInt(ROLE_ID_KEY);
  //print("ID: $tempID");
  //print("FNAME: $tempFN");
  //print("ROLE: $tempR");
  return true;
}

Future<bool> setDefaultValuesInPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(UID_KEY, "");
  await _prefs.setString(FIRST_NAME_KEY, "");
  await _prefs.setString(LAST_NAME_KEY, "");
  await _prefs.setString(EMAIL_KEY, "");
  await _prefs.setString(PHONE_KEY, "");
  await _prefs.setInt(ROLE_ID_KEY, 0);
  return true;
}

Future<String?> getUidFromPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return _prefs.getString(UID_KEY);
}

Future<String> getNameFromPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String? fname = await _prefs.getString(FIRST_NAME_KEY);
  String? lname = await _prefs.getString(LAST_NAME_KEY);
  return "$fname $lname";
}

Future<String?> getEmailFromPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return _prefs.getString(EMAIL_KEY);
}

Future<String?> getPhoneFromPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return _prefs.getString(PHONE_KEY);
}

Future<int?> getRoleFromPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return _prefs.getInt(ROLE_ID_KEY);
}

Future<bool> setUserFromPrefs(User user) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  Map data = user.toJson();
  String str = jsonEncode(data);
  _prefs.setString(USER_KEY, str);
  return true;
}

Future<User> getUserFromPrefs() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  //print(_prefs.getString(USER_KEY));
  Map data = jsonDecode(_prefs.getString(USER_KEY)?? '');
  User user = User.fromMap(data as Map<String, dynamic>);
  return user;
}
