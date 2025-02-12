class RegistrationModel {
  final String eventId;
  final String eventName;
  final String eventImg;
  final List<Registration> registration;

  const RegistrationModel({
    required this.eventId,
    required this.eventName,
    required this.eventImg,
    required this.registration,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      eventId: json['event_id'],
      eventName: json['event_name'],
      eventImg: json['event_img'],
      registration: (json['registrations'] as List<dynamic>).map((e) {
        return Registration.fromJson(e as Map<String, dynamic>);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'event_name': eventName,
      'event_img': eventImg,
      'registrations': registration.map((r) => r.toJson()).toList(),
    };
  }
}

class Registration {
  final String uid;
  final String userName;
  final String branch;
  final String screenshot;
  final String phone;
  final String transactionId;

  const Registration({
    required this.uid,
    required this.userName,
    required this.branch,
    required this.screenshot,
    required this.phone,
    required this.transactionId,
  });

  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      uid: json['uid'],
      userName: json['user_name'],
      branch: json['branch'],
      screenshot: json['screenshot'],
      phone: json['phone'],
      transactionId: json['transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'user_name': userName,
      'branch': branch,
      'screenshot': screenshot,
      'phone': phone,
      'transaction_id': transactionId,
    };
  }
}
