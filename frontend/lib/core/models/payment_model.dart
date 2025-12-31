import 'enums/payment_status.dart';

/// 결제 모델
///
/// 백엔드 Payment 테이블과 동기화
/// v2.0에서 환불 정보 및 메타데이터 필드 추가
class PaymentModel {
  /// 결제 ID
  final String id;

  /// 사용자 ID
  final String userId;

  /// 구독 ID (구독 결제인 경우)
  final String? subscriptionId;

  /// 결제 방법 (paypay, stripe, toss, kakao_pay, etc.)
  final String paymentMethod;

  /// 결제 금액
  final double amount;

  /// 통화
  final String currency;

  /// 결제 상태
  final PaymentStatus status;

  /// 결제 게이트웨이 거래 ID
  final String? transactionId;

  /// 청구 주소 (JSON)
  final Map<String, dynamic>? billingAddress;

  /// 세금 금액
  final double? taxAmount;

  /// 할인 금액
  final double? discountAmount;

  /// 환불 금액
  final double? refundedAmount;

  /// 환불 시간
  final DateTime? refundedAt;

  /// 환불 사유
  final String? refundReason;

  /// 메타데이터 (추가 정보 저장용 JSON)
  final Map<String, dynamic>? metadata;

  /// 생성 시간
  final DateTime createdAt;

  /// 수정 시간
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    this.subscriptionId,
    required this.paymentMethod,
    required this.amount,
    required this.currency,
    required this.status,
    this.transactionId,
    this.billingAddress,
    this.taxAmount,
    this.discountAmount,
    this.refundedAmount,
    this.refundedAt,
    this.refundReason,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON → Model
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subscriptionId: json['subscriptionId'] as String?,
      paymentMethod: json['paymentMethod'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: PaymentStatus.fromString(json['status'] as String),
      transactionId: json['transactionId'] as String?,
      billingAddress: json['billingAddress'] as Map<String, dynamic>?,
      taxAmount: json['taxAmount'] != null ? (json['taxAmount'] as num).toDouble() : null,
      discountAmount: json['discountAmount'] != null ? (json['discountAmount'] as num).toDouble() : null,
      refundedAmount: json['refundedAmount'] != null ? (json['refundedAmount'] as num).toDouble() : null,
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'] as String)
          : null,
      refundReason: json['refundReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'subscriptionId': subscriptionId,
        'paymentMethod': paymentMethod,
        'amount': amount,
        'currency': currency,
        'status': status.value,
        'transactionId': transactionId,
        'billingAddress': billingAddress,
        'taxAmount': taxAmount,
        'discountAmount': discountAmount,
        'refundedAmount': refundedAmount,
        'refundedAt': refundedAt?.toIso8601String(),
        'refundReason': refundReason,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 결제 완료 여부
  bool get isCompleted => status == PaymentStatus.completed;

  /// 결제 실패 여부
  bool get isFailed => status == PaymentStatus.failed;

  /// 결제 대기 중 여부
  bool get isPending => status == PaymentStatus.pending;

  /// 환불됨 여부
  bool get isRefunded => status == PaymentStatus.refunded;

  /// 부분 환불 여부 (일부만 환불된 경우)
  bool get isPartiallyRefunded {
    return refundedAmount != null &&
        refundedAmount! > 0 &&
        refundedAmount! < amount;
  }

  /// 전체 환불 여부
  bool get isFullyRefunded {
    return refundedAmount != null && refundedAmount! >= amount;
  }

  /// 통화 기호
  String get currencySymbol {
    switch (currency.toUpperCase()) {
      case 'KRW':
        return '₩';
      case 'JPY':
        return '¥';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }

  /// 최종 결제 금액 (할인 및 세금 반영)
  double get finalAmount {
    double total = amount;
    if (discountAmount != null) {
      total -= discountAmount!;
    }
    if (taxAmount != null) {
      total += taxAmount!;
    }
    return total;
  }

  /// 가격 문자열 (통화 기호 포함)
  String get formattedAmount {
    if (currency == 'KRW' || currency == 'JPY') {
      return '$currencySymbol${amount.toInt().toString()}';
    } else {
      return '$currencySymbol${amount.toStringAsFixed(2)}';
    }
  }

  /// 최종 금액 문자열
  String get formattedFinalAmount {
    if (currency == 'KRW' || currency == 'JPY') {
      return '$currencySymbol${finalAmount.toInt().toString()}';
    } else {
      return '$currencySymbol${finalAmount.toStringAsFixed(2)}';
    }
  }

  /// 환불 금액 문자열
  String? get formattedRefundedAmount {
    if (refundedAmount == null) return null;
    if (currency == 'KRW' || currency == 'JPY') {
      return '$currencySymbol${refundedAmount!.toInt().toString()}';
    } else {
      return '$currencySymbol${refundedAmount!.toStringAsFixed(2)}';
    }
  }

  /// 결제 방법 표시 이름
  String get paymentMethodDisplayName {
    switch (paymentMethod.toLowerCase()) {
      case 'paypay':
        return 'PayPay';
      case 'stripe':
        return 'Stripe';
      case 'toss':
        return 'Toss';
      case 'kakao_pay':
        return 'Kakao Pay';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      default:
        return paymentMethod;
    }
  }

  /// copyWith
  PaymentModel copyWith({
    String? id,
    String? userId,
    String? subscriptionId,
    String? paymentMethod,
    double? amount,
    String? currency,
    PaymentStatus? status,
    String? transactionId,
    Map<String, dynamic>? billingAddress,
    double? taxAmount,
    double? discountAmount,
    double? refundedAmount,
    DateTime? refundedAt,
    String? refundReason,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      billingAddress: billingAddress ?? this.billingAddress,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      refundedAmount: refundedAmount ?? this.refundedAmount,
      refundedAt: refundedAt ?? this.refundedAt,
      refundReason: refundReason ?? this.refundReason,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $formattedAmount, status: ${status.value})';
  }
}
