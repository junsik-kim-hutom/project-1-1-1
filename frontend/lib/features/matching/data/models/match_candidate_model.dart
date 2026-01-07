class MatchCandidateModel {
  final int userId;
  final String displayName;
  final int? age;
  final int? height;
  final String? occupation;
  final String? education;
  final String? bio;
  final String? locationAddress;
  final double distanceKm;
  final int matchScore;
  final String? imageUrl;

  const MatchCandidateModel({
    required this.userId,
    required this.displayName,
    required this.age,
    required this.height,
    required this.occupation,
    required this.education,
    required this.bio,
    required this.locationAddress,
    required this.distanceKm,
    required this.matchScore,
    required this.imageUrl,
  });

  factory MatchCandidateModel.fromJson(Map<String, dynamic> json) {
    return MatchCandidateModel(
      userId: _parseId(json['userId']),
      displayName: json['displayName'] as String? ?? '',
      age: (json['age'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      occupation: json['occupation'] as String?,
      education: json['education'] as String?,
      bio: json['bio'] as String?,
      locationAddress: json['locationAddress'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      matchScore: (json['matchScore'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
