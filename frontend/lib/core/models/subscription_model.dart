import 'enums/subscription_status.dart';

/// 구독 모델
///
/// 백엔드 Subscription 테이블과 동기화
/// v2.0에서 취소 시간(cancelledAt) 필드 추가
class SubscriptionModel {
  /// 구독 ID
  final int id;

  /// 사용자 ID
  final int userId;

  /// 플랜 ID
  final int planId;

  /// 구독 상태
  final SubscriptionStatus status;

  /// 시작 시간
  final DateTime startedAt;

  /// 만료 시간
  final DateTime expiresAt;

  /// 취소 시간
  final DateTime? cancelledAt;

  /// 생성 시간
  final DateTime createdAt;

  /// 수정 시간
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startedAt,
    required this.expiresAt,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON → Model
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: _parseId(json['id']),
      userId: _parseId(json['userId']),
      planId: _parseId(json['planId']),
      status: SubscriptionStatus.fromString(json['status'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'planId': planId,
        'status': status.value,
        'startedAt': startedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'cancelledAt': cancelledAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 활성 구독 여부
  bool get isActive => status == SubscriptionStatus.active;

  /// 취소됨 (하지만 만료 전까지는 사용 가능)
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  /// 만료됨
  bool get isExpired => status == SubscriptionStatus.expired;

  /// 일시정지
  bool get isPaused => status == SubscriptionStatus.paused;

  /// 사용 가능 여부 (active 또는 cancelled이지만 만료 전)
  bool get isUsable => status.isUsable;

  /// 현재 시점에서 실제로 사용 가능한지 (만료 시간 체크)
  bool get isCurrentlyActive {
    if (!isUsable) return false;
    return DateTime.now().isBefore(expiresAt);
  }

  /// 만료까지 남은 일수
  int get daysUntilExpiry {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return 0;
    return expiresAt.difference(now).inDays;
  }

  /// 만료까지 남은 시간 (초)
  int get secondsUntilExpiry {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return 0;
    return expiresAt.difference(now).inSeconds;
  }

  /// 곧 만료 예정인지 (7일 이내)
  bool get isExpiringSoon {
    return isCurrentlyActive && daysUntilExpiry <= 7;
  }

  /// 만료 임박 (1일 이내)
  bool get isExpiringVerySoon {
    return isCurrentlyActive && daysUntilExpiry <= 1;
  }

  /// 구독 기간 (일)
  int get totalDurationDays {
    return expiresAt.difference(startedAt).inDays;
  }

  /// 경과 기간 (일)
  int get elapsedDays {
    final now = DateTime.now();
    if (now.isBefore(startedAt)) return 0;
    if (now.isAfter(expiresAt)) return totalDurationDays;
    return now.difference(startedAt).inDays;
  }

  /// 진행률 (0.0 ~ 1.0)
  double get progressRatio {
    if (totalDurationDays == 0) return 1.0;
    return (elapsedDays / totalDurationDays).clamp(0.0, 1.0);
  }

  /// 만료 시간 문자열 (예: "3일 후", "1시간 후")
  String get expiryTimeText {
    if (!isCurrentlyActive) return '만료됨';

    final now = DateTime.now();
    final diff = expiresAt.difference(now);

    if (diff.inDays > 0) {
      return '${diff.inDays}일 후';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 후';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}분 후';
    } else {
      return '곧 만료';
    }
  }

  /// copyWith
  SubscriptionModel copyWith({
    int? id,
    int? userId,
    int? planId,
    SubscriptionStatus? status,
    DateTime? startedAt,
    DateTime? expiresAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, status: ${status.value}, expiresAt: $expiresAt)';
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
