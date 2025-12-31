import 'enums/notification_type.dart';

/// 알림 모델
///
/// 백엔드 Notification 테이블과 동기화
class NotificationModel {
  /// 알림 ID
  final String id;

  /// 사용자 ID
  final String userId;

  /// 알림 타입
  final NotificationType type;

  /// 제목 (다국어 지원)
  /// { "ko": "새 메시지", "ja": "新しいメッセージ", "en": "New Message" }
  final Map<String, dynamic> title;

  /// 메시지 내용 (다국어 지원)
  final Map<String, dynamic> message;

  /// 읽음 여부
  final bool isRead;

  /// 읽은 시간
  final DateTime? readAt;

  /// 관련 사용자 ID (좋아요를 보낸 사람 등)
  final String? relatedUserId;

  /// 관련 대화 요청 ID
  final String? relatedChatRequestId;

  /// 관련 채팅방 ID
  final String? relatedChatRoomId;

  /// 관련 메시지 ID
  final String? relatedMessageId;

  /// 관련 결제 ID
  final String? relatedPaymentId;

  /// Push 알림 전송 여부
  final bool isPushSent;

  /// Push 알림 전송 시간
  final DateTime? pushSentAt;

  /// 액션 URL (클릭 시 이동할 경로)
  /// 예: "/chat/rooms/123", "/profile/456"
  final String? actionUrl;

  /// 생성 시간
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    this.relatedUserId,
    this.relatedChatRequestId,
    this.relatedChatRoomId,
    this.relatedMessageId,
    this.relatedPaymentId,
    required this.isPushSent,
    this.pushSentAt,
    this.actionUrl,
    required this.createdAt,
  });

  /// JSON → Model
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as Map<String, dynamic>,
      message: json['message'] as Map<String, dynamic>,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      relatedUserId: json['relatedUserId'] as String?,
      relatedChatRequestId: json['relatedChatRequestId'] as String?,
      relatedChatRoomId: json['relatedChatRoomId'] as String?,
      relatedMessageId: json['relatedMessageId'] as String?,
      relatedPaymentId: json['relatedPaymentId'] as String?,
      isPushSent: json['isPushSent'] as bool,
      pushSentAt: json['pushSentAt'] != null ? DateTime.parse(json['pushSentAt'] as String) : null,
      actionUrl: json['actionUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.value,
        'title': title,
        'message': message,
        'isRead': isRead,
        'readAt': readAt?.toIso8601String(),
        'relatedUserId': relatedUserId,
        'relatedChatRequestId': relatedChatRequestId,
        'relatedChatRoomId': relatedChatRoomId,
        'relatedMessageId': relatedMessageId,
        'relatedPaymentId': relatedPaymentId,
        'isPushSent': isPushSent,
        'pushSentAt': pushSentAt?.toIso8601String(),
        'actionUrl': actionUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  /// 다국어 제목 추출
  String getLocalizedTitle(String languageCode) {
    return title[languageCode] as String? ?? title['en'] as String? ?? '';
  }

  /// 다국어 메시지 추출
  String getLocalizedMessage(String languageCode) {
    return message[languageCode] as String? ?? message['en'] as String? ?? '';
  }

  /// 알림 아이콘
  String get icon => type.icon;

  /// 알림 색상
  String get colorHex => type.colorHex;

  /// 알림 카테고리
  String get category => type.category;

  /// 알림 우선순위
  int get priority => type.priority;

  /// 읽지 않은 알림인지
  bool get isUnread => !isRead;

  /// 새 알림인지 (1시간 이내)
  bool get isNew {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    return diff.inHours < 1;
  }

  /// copyWith
  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    Map<String, dynamic>? title,
    Map<String, dynamic>? message,
    bool? isRead,
    DateTime? readAt,
    String? relatedUserId,
    String? relatedChatRequestId,
    String? relatedChatRoomId,
    String? relatedMessageId,
    String? relatedPaymentId,
    bool? isPushSent,
    DateTime? pushSentAt,
    String? actionUrl,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      relatedUserId: relatedUserId ?? this.relatedUserId,
      relatedChatRequestId: relatedChatRequestId ?? this.relatedChatRequestId,
      relatedChatRoomId: relatedChatRoomId ?? this.relatedChatRoomId,
      relatedMessageId: relatedMessageId ?? this.relatedMessageId,
      relatedPaymentId: relatedPaymentId ?? this.relatedPaymentId,
      isPushSent: isPushSent ?? this.isPushSent,
      pushSentAt: pushSentAt ?? this.pushSentAt,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 읽음 처리
  NotificationModel markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: ${type.value}, isRead: $isRead)';
  }
}

/// 알림 설정 모델
class NotificationSettingsModel {
  final String id;
  final String userId;

  // 카테고리별 푸시 알림 설정
  final bool matchingPushEnabled;
  final bool chatPushEnabled;
  final bool profilePushEnabled;
  final bool paymentPushEnabled;
  final bool systemPushEnabled;

  // 카테고리별 인앱 알림 설정
  final bool matchingInAppEnabled;
  final bool chatInAppEnabled;
  final bool profileInAppEnabled;
  final bool paymentInAppEnabled;
  final bool systemInAppEnabled;

  // 방해 금지 시간
  final String? quietHoursStart; // "22:00"
  final String? quietHoursEnd; // "08:00"
  final bool quietHoursEnabled;

  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationSettingsModel({
    required this.id,
    required this.userId,
    required this.matchingPushEnabled,
    required this.chatPushEnabled,
    required this.profilePushEnabled,
    required this.paymentPushEnabled,
    required this.systemPushEnabled,
    required this.matchingInAppEnabled,
    required this.chatInAppEnabled,
    required this.profileInAppEnabled,
    required this.paymentInAppEnabled,
    required this.systemInAppEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.quietHoursEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      matchingPushEnabled: json['matchingPushEnabled'] as bool,
      chatPushEnabled: json['chatPushEnabled'] as bool,
      profilePushEnabled: json['profilePushEnabled'] as bool,
      paymentPushEnabled: json['paymentPushEnabled'] as bool,
      systemPushEnabled: json['systemPushEnabled'] as bool,
      matchingInAppEnabled: json['matchingInAppEnabled'] as bool,
      chatInAppEnabled: json['chatInAppEnabled'] as bool,
      profileInAppEnabled: json['profileInAppEnabled'] as bool,
      paymentInAppEnabled: json['paymentInAppEnabled'] as bool,
      systemInAppEnabled: json['systemInAppEnabled'] as bool,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
      quietHoursEnabled: json['quietHoursEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'matchingPushEnabled': matchingPushEnabled,
        'chatPushEnabled': chatPushEnabled,
        'profilePushEnabled': profilePushEnabled,
        'paymentPushEnabled': paymentPushEnabled,
        'systemPushEnabled': systemPushEnabled,
        'matchingInAppEnabled': matchingInAppEnabled,
        'chatInAppEnabled': chatInAppEnabled,
        'profileInAppEnabled': profileInAppEnabled,
        'paymentInAppEnabled': paymentInAppEnabled,
        'systemInAppEnabled': systemInAppEnabled,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
        'quietHoursEnabled': quietHoursEnabled,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 현재 방해 금지 시간인지 확인
  bool isQuietHours() {
    if (!quietHoursEnabled || quietHoursStart == null || quietHoursEnd == null) {
      return false;
    }

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final start = quietHoursStart!;
    final end = quietHoursEnd!;

    // 예: 22:00 ~ 08:00 (다음날)
    if (start.compareTo(end) > 0) {
      return currentTime.compareTo(start) >= 0 || currentTime.compareTo(end) < 0;
    }
    // 예: 01:00 ~ 05:00 (같은 날)
    else {
      return currentTime.compareTo(start) >= 0 && currentTime.compareTo(end) < 0;
    }
  }

  /// 특정 카테고리의 푸시 알림이 활성화되어 있는지
  bool isPushEnabledForCategory(String category) {
    switch (category) {
      case 'matching':
        return matchingPushEnabled;
      case 'chat':
        return chatPushEnabled;
      case 'profile':
        return profilePushEnabled;
      case 'payment':
        return paymentPushEnabled;
      case 'system':
        return systemPushEnabled;
      default:
        return true;
    }
  }
}
