import 'enums/matching_action.dart';

/// 매칭 히스토리 모델
///
/// 사용자가 다른 프로필에 대해 취한 행동 기록
/// 백엔드 MatchingHistory 테이블과 동기화
class MatchingHistoryModel {
  /// ID
  final int id;

  /// 행동을 취한 사용자 ID
  final int userId;

  /// 대상 사용자 ID
  final int targetUserId;

  /// 액션 타입 (LIKE, PASS, SUPER_LIKE, BLOCK)
  final MatchingAction action;

  /// 생성 시간
  final DateTime createdAt;

  MatchingHistoryModel({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.action,
    required this.createdAt,
  });

  /// JSON → Model
  factory MatchingHistoryModel.fromJson(Map<String, dynamic> json) {
    return MatchingHistoryModel(
      id: _parseId(json['id']),
      userId: _parseId(json['userId']),
      targetUserId: _parseId(json['targetUserId']),
      action: MatchingAction.fromString(json['action'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'targetUserId': targetUserId,
        'action': action.value,
        'createdAt': createdAt.toIso8601String(),
      };

  /// 좋아요 액션인지
  bool get isLike => action == MatchingAction.like;

  /// 슈퍼 좋아요 액션인지
  bool get isSuperLike => action == MatchingAction.superLike;

  /// 패스 액션인지
  bool get isPass => action == MatchingAction.pass;

  /// 차단 액션인지
  bool get isBlock => action == MatchingAction.block;

  /// 긍정적 액션인지 (좋아요 or 슈퍼 좋아요)
  bool get isPositive => isLike || isSuperLike;

  /// copyWith
  MatchingHistoryModel copyWith({
    int? id,
    int? userId,
    int? targetUserId,
    MatchingAction? action,
    DateTime? createdAt,
  }) {
    return MatchingHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetUserId: targetUserId ?? this.targetUserId,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MatchingHistoryModel(id: $id, userId: $userId, targetUserId: $targetUserId, action: ${action.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MatchingHistoryModel &&
        other.id == id &&
        other.userId == userId &&
        other.targetUserId == targetUserId &&
        other.action == action &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        targetUserId.hashCode ^
        action.hashCode ^
        createdAt.hashCode;
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
