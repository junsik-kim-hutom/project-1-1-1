/// 구독 플랜 모델
///
/// 백엔드 SubscriptionPlan 테이블과 동기화
/// v2.0에서 신규 추가됨 (하드코딩에서 DB 기반으로 변경)
class SubscriptionPlanModel {
  /// 플랜 ID
  final String id;

  /// 플랜 이름 (다국어 지원)
  /// { "ko": "프리미엄", "ja": "プレミアム", "en": "Premium" }
  final Map<String, dynamic> name;

  /// 설명 (다국어 지원)
  final Map<String, dynamic> description;

  /// 가격
  final double price;

  /// 통화 (KRW, JPY, USD)
  final String currency;

  /// 기간 (일 단위)
  final int durationDays;

  /// 무제한 채팅 가능 여부
  final bool unlimitedChat;

  /// 슈퍼 좋아요 개수
  final int superLikesCount;

  /// 일일 좋아요 제한 (null이면 무제한)
  final int? dailyLikesLimit;

  /// 프로필 조회 우선순위
  final bool priorityProfile;

  /// 광고 제거 여부
  final bool adFree;

  /// 읽음 확인 기능 활성화
  final bool readReceipts;

  /// 활성화 여부
  final bool isActive;

  /// 표시 순서
  final int displayOrder;

  /// 생성 시간
  final DateTime createdAt;

  /// 수정 시간
  final DateTime updatedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.unlimitedChat,
    required this.superLikesCount,
    this.dailyLikesLimit,
    required this.priorityProfile,
    required this.adFree,
    required this.readReceipts,
    required this.isActive,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON → Model
  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as Map<String, dynamic>,
      description: json['description'] as Map<String, dynamic>,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      durationDays: json['durationDays'] as int,
      unlimitedChat: json['unlimitedChat'] as bool,
      superLikesCount: json['superLikesCount'] as int,
      dailyLikesLimit: json['dailyLikesLimit'] as int?,
      priorityProfile: json['priorityProfile'] as bool,
      adFree: json['adFree'] as bool,
      readReceipts: json['readReceipts'] as bool,
      isActive: json['isActive'] as bool,
      displayOrder: json['displayOrder'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'currency': currency,
        'durationDays': durationDays,
        'unlimitedChat': unlimitedChat,
        'superLikesCount': superLikesCount,
        'dailyLikesLimit': dailyLikesLimit,
        'priorityProfile': priorityProfile,
        'adFree': adFree,
        'readReceipts': readReceipts,
        'isActive': isActive,
        'displayOrder': displayOrder,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 다국어 이름 추출
  String getLocalizedName(String languageCode) {
    return name[languageCode] as String? ?? name['en'] as String? ?? '';
  }

  /// 다국어 설명 추출
  String getLocalizedDescription(String languageCode) {
    return description[languageCode] as String? ??
        description['en'] as String? ??
        '';
  }

  /// 월간 플랜인지 (30일)
  bool get isMonthly => durationDays == 30;

  /// 주간 플랜인지 (7일)
  bool get isWeekly => durationDays == 7;

  /// 연간 플랜인지 (365일)
  bool get isYearly => durationDays == 365;

  /// 무제한 좋아요 가능 여부
  bool get hasUnlimitedLikes => dailyLikesLimit == null;

  /// 프리미엄 기능이 있는지 (하나라도 true면)
  bool get hasPremiumFeatures {
    return unlimitedChat ||
        superLikesCount > 0 ||
        priorityProfile ||
        adFree ||
        readReceipts;
  }

  /// 통화 기호 반환
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

  /// 가격 문자열 (통화 기호 포함)
  String get formattedPrice {
    if (currency == 'KRW' || currency == 'JPY') {
      // 원화/엔화는 소수점 없음
      return '$currencySymbol${price.toInt().toString()}';
    } else {
      return '$currencySymbol${price.toStringAsFixed(2)}';
    }
  }

  /// 일일 가격 계산
  double get pricePerDay {
    return price / durationDays;
  }

  /// copyWith
  SubscriptionPlanModel copyWith({
    String? id,
    Map<String, dynamic>? name,
    Map<String, dynamic>? description,
    double? price,
    String? currency,
    int? durationDays,
    bool? unlimitedChat,
    int? superLikesCount,
    int? dailyLikesLimit,
    bool? priorityProfile,
    bool? adFree,
    bool? readReceipts,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      durationDays: durationDays ?? this.durationDays,
      unlimitedChat: unlimitedChat ?? this.unlimitedChat,
      superLikesCount: superLikesCount ?? this.superLikesCount,
      dailyLikesLimit: dailyLikesLimit ?? this.dailyLikesLimit,
      priorityProfile: priorityProfile ?? this.priorityProfile,
      adFree: adFree ?? this.adFree,
      readReceipts: readReceipts ?? this.readReceipts,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SubscriptionPlanModel(id: $id, price: $formattedPrice, durationDays: $durationDays)';
  }
}
