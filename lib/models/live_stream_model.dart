class LiveStreamModel {
  final String liveId;
  final String title;
  final bool isLive;

  const LiveStreamModel({
    required this.liveId,
    required this.title,
    required this.isLive,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      liveId: json['live_id'],
      title: json['title'],
      isLive: json['is_live'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'live_id': liveId,
      'title': title,
      'is_live': isLive,
    };
  }
}
