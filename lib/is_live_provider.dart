import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pratishtha/models/live_stream_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IsLiveProvider extends ChangeNotifier {
  IsLiveProvider() {
    getLiveStatus();
  }

  List<String> _enabledLiveStreams = [];
  Map<String, bool> _liveStatus = {};
  bool _isLive = false;

  bool get isLive => _isLive;
  List<String> get enabledLiveStreams => _enabledLiveStreams;
  Map<String, bool> get liveStatus => _liveStatus;

  void toogleIsLive(bool isLive) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLive = isLive;
    await prefs.setBool('isLive', isLive);
    notifyListeners();
  }

  void getLiveStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLive = prefs.getBool('isLive') ?? false;
    notifyListeners();
  }

  // enableSwitch() {
  //   Map switches = {};
  //   fv
  // }

  Future<List<LiveStreamModel>> fetchAllStreams() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('livestreamIds')
          .doc('liveStreams')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('streams') && data['streams'] is List) {
          final List<dynamic> streams = data['streams'];

          List<LiveStreamModel> list = streams
              .map((stream) =>
                  LiveStreamModel.fromJson(stream as Map<String, dynamic>))
              .toList();

          return list;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching livestreams: $e');
      return [];
    }
  }

  Future<List<LiveStreamModel>> liveStreams() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('livestreamIds')
          .doc('liveStreams')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('streams') && data['streams'] is List) {
          List<dynamic> streamData = data['streams'];

          List<LiveStreamModel> liveStreams = streamData
              .where((stream) => stream['is_live'] == true)
              .map((stream) => LiveStreamModel.fromJson(stream))
              .toList();

          return liveStreams;
        }
      }
      return [];
    } catch (e) {
      throw Exception('fetchLiveStreams(): $e');
    }
  }
}
