class MatchingActivityModel {
  final int interestSent;
  final int boostSent;
  final int interestReceived;
  final int boostReceived;
  final int ongoingChats;

  const MatchingActivityModel({
    required this.interestSent,
    required this.boostSent,
    required this.interestReceived,
    required this.boostReceived,
    required this.ongoingChats,
  });

  factory MatchingActivityModel.fromJson(Map<String, dynamic> json) {
    return MatchingActivityModel(
      interestSent: (json['interestSent'] as num?)?.toInt() ?? 0,
      boostSent: (json['boostSent'] as num?)?.toInt() ?? 0,
      interestReceived: (json['interestReceived'] as num?)?.toInt() ?? 0,
      boostReceived: (json['boostReceived'] as num?)?.toInt() ?? 0,
      ongoingChats: (json['ongoingChats'] as num?)?.toInt() ?? 0,
    );
  }
}

