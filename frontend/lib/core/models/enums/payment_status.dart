/// 결제 상태 열거형
enum PaymentStatus {
  /// 결제 대기 중
  pending('PENDING'),

  /// 결제 완료
  completed('COMPLETED'),

  /// 결제 실패
  failed('FAILED'),

  /// 환불 완료
  refunded('REFUNDED');

  const PaymentStatus(this.value);

  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.failed,
    );
  }

  /// 표시 텍스트
  String get displayText {
    switch (this) {
      case PaymentStatus.pending:
        return '대기 중';
      case PaymentStatus.completed:
        return '완료';
      case PaymentStatus.failed:
        return '실패';
      case PaymentStatus.refunded:
        return '환불됨';
    }
  }

  /// 색상 (Hex)
  String get colorHex {
    switch (this) {
      case PaymentStatus.pending:
        return '#FF9800'; // Orange
      case PaymentStatus.completed:
        return '#4CAF50'; // Green
      case PaymentStatus.failed:
        return '#F44336'; // Red
      case PaymentStatus.refunded:
        return '#9E9E9E'; // Grey
    }
  }
}
