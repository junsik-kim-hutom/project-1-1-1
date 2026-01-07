/// 사용자 차단 모델
///
/// 백엔드 UserBlock 테이블과 동기화
class UserBlockModel {
  /// ID
  final int id;

  /// 차단을 실행한 사용자 ID
  final int blockerId;

  /// 차단된 사용자 ID
  final int blockedId;

  /// 차단 사유
  final String? reason;

  /// 차단 시간
  final DateTime createdAt;

  UserBlockModel({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    this.reason,
    required this.createdAt,
  });

  /// JSON → Model
  factory UserBlockModel.fromJson(Map<String, dynamic> json) {
    return UserBlockModel(
      id: _parseId(json['id']),
      blockerId: _parseId(json['blockerId']),
      blockedId: _parseId(json['blockedId']),
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'blockerId': blockerId,
        'blockedId': blockedId,
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
      };

  /// copyWith
  UserBlockModel copyWith({
    int? id,
    int? blockerId,
    int? blockedId,
    String? reason,
    DateTime? createdAt,
  }) {
    return UserBlockModel(
      id: id ?? this.id,
      blockerId: blockerId ?? this.blockerId,
      blockedId: blockedId ?? this.blockedId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserBlockModel(id: $id, blockerId: $blockerId, blockedId: $blockedId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserBlockModel &&
        other.id == id &&
        other.blockerId == blockerId &&
        other.blockedId == blockedId &&
        other.reason == reason &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        blockerId.hashCode ^
        blockedId.hashCode ^
        reason.hashCode ^
        createdAt.hashCode;
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
