/// 구독 상태 열거형
enum SubscriptionStatus {
  /// 활성 구독
  active('ACTIVE'),

  /// 취소됨 (기간 종료까지는 사용 가능)
  cancelled('CANCELLED'),

  /// 만료됨
  expired('EXPIRED'),

  /// 일시정지
  paused('PAUSED');

  const SubscriptionStatus(this.value);

  final String value;

  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SubscriptionStatus.expired,
    );
  }

  /// 사용 가능 여부
  bool get isUsable {
    return this == SubscriptionStatus.active ||
        this == SubscriptionStatus.cancelled;
  }

  /// 표시 텍스트
  String get displayText {
    switch (this) {
      case SubscriptionStatus.active:
        return '활성';
      case SubscriptionStatus.cancelled:
        return '취소됨';
      case SubscriptionStatus.expired:
        return '만료됨';
      case SubscriptionStatus.paused:
        return '일시정지';
    }
  }

  /// 색상 (Hex)
  String get colorHex {
    switch (this) {
      case SubscriptionStatus.active:
        return '#4CAF50'; // Green
      case SubscriptionStatus.cancelled:
        return '#FF9800'; // Orange
      case SubscriptionStatus.expired:
        return '#F44336'; // Red
      case SubscriptionStatus.paused:
        return '#9E9E9E'; // Grey
    }
  }
}
