class MatchingActionUserModel {
  final int userId;
  final String displayName;
  final int? age;
  final String? imageUrl;
  final String action;
  final DateTime createdAt;

  const MatchingActionUserModel({
    required this.userId,
    required this.displayName,
    required this.age,
    required this.imageUrl,
    required this.action,
    required this.createdAt,
  });

  factory MatchingActionUserModel.fromJson(Map<String, dynamic> json) {
    return MatchingActionUserModel(
      userId: _parseId(json['userId']),
      displayName: (json['displayName'] ?? '').toString(),
      age: (json['age'] as num?)?.toInt(),
      imageUrl: json['imageUrl']?.toString(),
      action: (json['action'] ?? '').toString(),
      createdAt: DateTime.parse((json['createdAt'] ?? '').toString()),
    );
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
