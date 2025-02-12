import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//import 'package:flutter/material.dart';
Event eventFromMap(Map<String, dynamic> data, String id) =>
  Event.fromMap(data, id);

Map eventToJson(Event data) => data.toJson();

Map festToJson(Event data) => data.toJsonFest();

class Event {
  Event(
    {this.id,
    this.parentId = "",
    this.childId,
    this.name,
    this.icon,
    this.bannerUrl = "",
    this.description = "",
    this.dateFrom,
    this.dateTo,
    this.type = 0,
    this.price = 0,
    this.rules,
    this.eventHeads,
    this.volunteers,
    this.location = "",
    this.meetLink = "",
    this.locationType = "Offline",
    this.reportUrl = "",
    this.eventLogisticsUrl = "",
    this.registrationUrl = "",
    this.feedbackUrl = "",
    this.participationPoints = 0,
    this.runnerUpPoints = 0,
    this.winnerPoints = 0,
    this.likes,
    this.registration,
    this.createdBy,
    this.totalCollected = 0,
    this.participantsLimit = 0,
    this.volunteersLimit = 0,
    this.completed = const [],
    this.winners,
    this.goLive = true,
    this.softDelete = false,
    this.forSakec = false,
    this.forFaculty = false,
    this.closeEvent = false,
    this.isEvent = false,
    this.volunteerPoints,
    this.approved_users,
    this.eventHeadPoints});

  String? id;
  String parentId;
  List? childId;
  String? name;
  int? icon;
  String bannerUrl;
  String description;
  DateTime? dateFrom;
  DateTime? dateTo;
  int type;
  int price;
  List? rules;
  List? eventHeads;
  List? volunteers;
  String location;
  String meetLink;
  String locationType;
  String reportUrl;
  String eventLogisticsUrl;
  String registrationUrl;
  String feedbackUrl;
  int participationPoints;
  int runnerUpPoints;
  int winnerPoints;
  List? approved_users;
  List? likes;
  List? registration;
  List? completed;
  Map<String, dynamic>? winners;
  String? createdBy;
  int totalCollected;
  int participantsLimit;
  int volunteersLimit;
  bool goLive;
  bool softDelete;
  bool forSakec;
  bool forFaculty;
  bool closeEvent;
  bool isEvent;
  int? volunteerPoints;
  int? eventHeadPoints;

  factory Event.fromMap(Map<String, dynamic> map, String id) {
  //print("event db map: $map");
  return Event(
    id: id,
    parentId: map['parent_id'] != null ? map['parent_id'] : "",
    name: map['name'] != null ? map['name'] : "",
    icon: map['icon'] != null ? int.parse(map['icon'].toString()) : 0,
    bannerUrl: map['banner_url'] != null ? map['banner_url'] : "",
    description: map['description'] != null ? map['description'] : "",
    dateFrom: map['date_from'] != null
      ? DateTime.parse(map['date_from'].toDate().toString())
      : DateTime(1975, 12, 11),
    dateTo: map['date_to'] != null
      ? DateTime.parse(map['date_to'].toDate().toString())
      : DateTime.now(),
    type: map['type'] != null ? int.parse(map['type'].toString()) : 0,
    price: map['price'] != null ? int.parse(map['price'].toString()) : 10,
    rules: map['rules'] != null ? map['rules'] : [],
    eventHeads: map['event_heads'] != null ? map['event_heads'] : [],
    volunteers: map['volunteers'] != null ? map['volunteers'] : [],
    location: map['location'] != null ? map['location'] : "",
    meetLink: map['meet_link'] != null ? map['meet_link'] : "",
    locationType:
      map['location_type'] != null ? map['location_type'] : "Offline",
    reportUrl: map['report_url'] != null ? map['report_url'] : "",
    eventLogisticsUrl:
      map['event_logistics_url'] != null ? map['event_logistics_url'] : "",
    registrationUrl:
      map['registration_url'] != null ? map['registration_url'] : "",
    feedbackUrl: map['feedback_url'] != null ? map['feedback_url'] : "",
    participationPoints: map['participation_points'] != null
      ? int.parse(map['participation_points'].toString())
      : 0,
    runnerUpPoints: map['runner_up_points'] != null
      ? int.parse(map['runner_up_points'].toString())
      : 0,
    winnerPoints: map['winner_points'] != null
      ? int.parse(map['winner_points'].toString())
      : 0,
    likes: map['likes'] != null ? map['likes'] : [],
    registration: map['registration'] != null ? map['registration'] : [],
    createdBy: map['created_by'] != null ? map['created_by'] : "",
    totalCollected: map['total_collected'] != null
      ? int.parse(map['total_collected'].toString())
      : 0,
    participantsLimit: map['participants_limit'] != null
      ? int.parse(map['participants_limit'].toString())
      : 0,
    volunteersLimit: map['volunteers_limit'] != null
      ? int.parse(map['volunteers_limit'].toString())
      : 0,
    completed: map['completed'] != null ? map['completed'] : [],
    winners: map['winners'] != null ? map['winners'] : {},
    goLive: map['go_live'] != null ? map['go_live'] : true,
    softDelete: map['soft_delete'] != null ? map['soft_delete'] : false,
    forSakec: map['for_sakec'] != null ? map['for_sakec'] : false,
    forFaculty: map['for_faculty'] != null ? map['for_faculty'] : false,
    closeEvent: map['close_event'] != null ? map['close_event'] : false,
    isEvent: map['is_event'] != null ? map['is_event'] : false,
    childId: map['child_id'] != null
      ? map['child_id'].runtimeType != "".runtimeType
        ? map['child_id'] ?? []
        : []
      : [],
    volunteerPoints: map['volunteer_points'] != null
      ? int.parse(map['volunteer_points'].toString())
      : 0,
    eventHeadPoints: map['event_head_points'] != null
      ? int.parse(map['event_head_points'].toString())
      : 0,
    approved_users: map['approved_users'] != null ? map['approved_users'] : [],
  );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'parent_id': parentId,
    'name': name,
    'banner_url': bannerUrl,
    'description': description,
    'date_from': Timestamp.fromDate(dateFrom!),
    'date_to': Timestamp.fromDate(dateTo!),
    'type': type,
    'price': price,
    'rules': rules,
    'event_heads': eventHeads ?? [],
    'volunteers': volunteers ?? [],
    'location': location,
    'meet_link': meetLink ?? "",
    'location_type': locationType,
    'report_url': reportUrl,
    'participation_points': participationPoints,
    'runner_up_points': runnerUpPoints,
    'winner_points': winnerPoints,
    'likes': likes,
    'registration': registration ?? [],
    'created_by': createdBy,
    'total_collected': totalCollected,
    'participants_limit': participantsLimit,
    'volunteers_limit': volunteersLimit,
    'completed': completed ?? [],
    'winners': winners,
    'go_live': goLive,
    'for_sakec': forSakec,
    'soft_delete': softDelete,
    'volunteer_points': volunteerPoints,
    'event_head_points': eventHeadPoints,
    'approved_users': approved_users ?? [],
    };

  Map<String, dynamic> toJsonFest() => {
    'id': id,
    'name': name,
    'child_id': childId,
    'description': description,
    'icon': icon,
    'date_from': Timestamp.fromDate(dateFrom!),
    'date_to': Timestamp.fromDate(dateTo!),
    'rules': rules,
    'banner_url': bannerUrl,
    'report_url': reportUrl,
    'event_heads': eventHeads ?? [],
    'volunteers': volunteers ?? [],
    'go_live': goLive,
    'soft_delete': softDelete,
    'for_sakec': forSakec,
    'volunteer_points': volunteerPoints,
    'event_head_points': eventHeadPoints,
    'location_type': locationType,
    'is_event': isEvent,
    'created_by': createdBy,
    'approved_users': approved_users ?? [],
    };
}

class MatchModel {
  MatchModel({
  this.matchId,
  this.result,
  this.resultsdeclare,
  this.score01,
  this.score02,
  this.team01,
  this.team01ID,
  this.team02,
  this.team02ID,
  });

  final String? matchId;
  final String? result;
  final bool? resultsdeclare;
  final String? score01;
  final String? score02;
  final String? team01;
  final String? team01ID;
  final String? team02;
  final String? team02ID;

  factory MatchModel.fromJson(Map<String, dynamic> match) {
  return MatchModel(
    matchId: match['matchId'],
    result: match['result'],
    resultsdeclare: match['resultsdeclare'],
    score01: match['score01'],
    score02: match['score02'],
    team01: match['team01'],
    team01ID: match['team01ID'],
    team02: match['team02'],
    team02ID: match['team02ID'],
  );
  }
}
