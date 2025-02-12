import 'dart:math';

User userFromMap(Map<String, dynamic> data, String id) => User.fromMap(data);

Map userToJson(User data) => data.toJson();

class User {
  User({
    this.uid,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.institute,
    this.role = 0,
    this.avatar = 4,
    this.eventIds,
    this.regNo = 0,
    this.smartcardNo = "",
    this.sakecId = "",
    this.rollNo = 0,
    this.branch = "",
    this.year = "",
    this.div = 0,
    this.wallet = 0,
    this.points = 0,
    this.badges,
    this.achievements,
    this.completedEvents,
    this.registeredEvents,
    this.interestedEvents,
    this.pointsHistory,
    this.walletHistory,
    this.eventRoles,
    this.softDelete = false,
    this.isVerified = false,
    this.isFaculty,
  });

  String? uid;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? institute;
  int role;
  int avatar;
  List? eventIds;
  int regNo;
  String smartcardNo;
  String sakecId;
  int rollNo;
  String branch;
  String year;
  int div;
  int wallet;
  int points;
  List? badges;
  Map<String, dynamic>? achievements;
  Map? completedEvents;
  Map? registeredEvents;
  List? interestedEvents;
  List? pointsHistory;
  List? walletHistory;
  String? eventRoles;
  bool softDelete;
  bool isVerified;
  bool? isFaculty;

  factory User.fromMap(Map<String, dynamic> map) => User(
        uid: map['uid'],
        firstName: map['first_name'],
        lastName: map['last_name'],
        email: map['email'],
        phone: map['phone'],
        institute: map['institute'],
        role: map['role'] ?? 0,
        avatar: map['avatar'] ?? Random().nextInt(8),
        eventIds: map['event_ids'] ?? [],
        regNo: map['reg_no'] ?? 0,
        smartcardNo: map['smartcard_no'] ?? "",
        sakecId: map['sakec_id'] ?? "",
        rollNo: map['roll_no'] ?? 0,
        branch: map['branch'] ?? "",
        year: map['year'] ?? "",
        div: map['div'] ?? 0,
        wallet: map['wallet'] ?? 0,
        points: map['points'] ?? 0,
        badges: map['badges'] ?? [],
        achievements: map['achievements'] ?? {},
        completedEvents: map['completed_events'] ?? {},
        registeredEvents: map['registered_events'] ?? {},
        interestedEvents: map['interested_events'] ?? [],
        pointsHistory: map['points_history'] ?? [],
        walletHistory: map['wallet_history'] ?? [],
        eventRoles: map['event_roles'] ?? "",
        softDelete: map['soft_delete'] ?? false,
        isVerified: map['is_verified'] ?? false,
        isFaculty: map['is_faculty'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'institute': institute,
        'role': role,
        'avatar': avatar,
        'event_ids': eventIds,
        'reg_no': regNo,
        'smartcard_no': smartcardNo,
        'sakec_id': sakecId,
        'roll_no': rollNo,
        'branch': branch,
        'year': year,
        'div': div,
        'wallet': wallet,
        'points': points,
        'badges': badges,
        'achievements': achievements,
        'completed_events': completedEvents,
        'registered_events': registeredEvents,
        'interested_events': interestedEvents,
        'points_history': pointsHistory,
        'wallet_history': walletHistory,
        'event_roles': eventRoles,
        'soft_delete': softDelete,
        'is_verified': isVerified,
        'is_faculty': isFaculty,
      };
}
