/// 알림 타입 열거형
///
/// 백엔드 NotificationType Enum과 동기화
/// 총 27개 타입을 지원합니다.
enum NotificationType {
  // ========================================
  // 매칭 관련 알림 (Matching) - 4개
  // ========================================

  /// 누군가 내 프로필에 관심을 보냈을 때
  matchLike('MATCH_LIKE'),

  /// 누군가 내 프로필에 부스트를 보냈을 때
  matchSuperLike('MATCH_SUPER_LIKE'),

  /// 서로 관심을 보내 매칭이 성사되었을 때
  matchMutual('MATCH_MUTUAL'),

  /// 누군가 내 프로필을 조회했을 때
  matchProfileView('MATCH_PROFILE_VIEW'),

  // ========================================
  // 채팅 관련 알림 (Chat) - 7개
  // ========================================

  /// 대화 요청을 받았을 때
  chatRequestReceived('CHAT_REQUEST_RECEIVED'),

  /// 내가 보낸 대화 요청이 수락되었을 때
  chatRequestAccepted('CHAT_REQUEST_ACCEPTED'),

  /// 대화 요청이 거절되었을 때
  chatRequestRejected('CHAT_REQUEST_REJECTED'),

  /// 대화 요청이 만료되었을 때
  chatRequestExpired('CHAT_REQUEST_EXPIRED'),

  /// 새 메시지가 도착했을 때
  chatNewMessage('CHAT_NEW_MESSAGE'),

  /// 내가 보낸 메시지를 상대방이 읽었을 때
  chatMessageRead('CHAT_MESSAGE_READ'),

  /// 채팅방이 곧 만료될 예정일 때 (무료 사용자)
  chatRoomExpiring('CHAT_ROOM_EXPIRING'),

  // ========================================
  // 프로필 관련 알림 (Profile) - 4개
  // ========================================

  /// 업로드한 프로필 사진이 승인되었을 때
  profileImageApproved('PROFILE_IMAGE_APPROVED'),

  /// 업로드한 프로필 사진이 거절되었을 때
  profileImageRejected('PROFILE_IMAGE_REJECTED'),

  /// 프로필 인증이 완료되었을 때
  profileVerified('PROFILE_VERIFIED'),

  /// 프로필 완성도가 낮아서 개선이 필요할 때
  profileIncomplete('PROFILE_INCOMPLETE'),

  // ========================================
  // 결제 관련 알림 (Payment) - 5개
  // ========================================

  /// 결제가 완료되었을 때
  paymentCompleted('PAYMENT_COMPLETED'),

  /// 결제가 실패했을 때
  paymentFailed('PAYMENT_FAILED'),

  /// 환불이 처리되었을 때
  paymentRefunded('PAYMENT_REFUNDED'),

  /// 구독이 갱신되었을 때
  subscriptionRenewed('SUBSCRIPTION_RENEWED'),

  /// 구독이 곧 만료될 예정일 때
  subscriptionExpiring('SUBSCRIPTION_EXPIRING'),

  // ========================================
  // 시스템 알림 (System) - 7개
  // ========================================

  /// 시스템 공지사항
  systemAnnouncement('SYSTEM_ANNOUNCEMENT'),

  /// 이벤트/프로모션
  systemEvent('SYSTEM_EVENT'),

  /// 앱 업데이트 안내
  systemUpdate('SYSTEM_UPDATE'),

  /// 계정 보안 경고 (의심스러운 로그인 등)
  systemSecurityAlert('SYSTEM_SECURITY_ALERT'),

  /// 정책 변경 안내 (이용약관, 개인정보처리방침)
  systemPolicyUpdate('SYSTEM_POLICY_UPDATE'),

  /// 서비스 점검 안내
  systemMaintenance('SYSTEM_MAINTENANCE'),

  /// 기타 알림
  systemOther('SYSTEM_OTHER');

  const NotificationType(this.value);

  /// 백엔드 Enum 값 (SNAKE_CASE)
  final String value;

  /// 백엔드 값으로부터 Enum 변환
  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.systemOther,
    );
  }

  /// 알림 아이콘 반환
  String get icon {
    switch (this) {
      // Matching
      case NotificationType.matchLike:
        return '✨';
      case NotificationType.matchSuperLike:
        return '⚡';
      case NotificationType.matchMutual:
        return '🤝';
      case NotificationType.matchProfileView:
        return '👀';

      // Chat
      case NotificationType.chatRequestReceived:
        return '💬';
      case NotificationType.chatRequestAccepted:
        return '✅';
      case NotificationType.chatRequestRejected:
        return '❌';
      case NotificationType.chatRequestExpired:
        return '⏰';
      case NotificationType.chatNewMessage:
        return '💬';
      case NotificationType.chatMessageRead:
        return '✓✓';
      case NotificationType.chatRoomExpiring:
        return '⏳';

      // Profile
      case NotificationType.profileImageApproved:
        return '✅';
      case NotificationType.profileImageRejected:
        return '❌';
      case NotificationType.profileVerified:
        return '✓';
      case NotificationType.profileIncomplete:
        return '⚠️';

      // Payment
      case NotificationType.paymentCompleted:
        return '💳';
      case NotificationType.paymentFailed:
        return '❌';
      case NotificationType.paymentRefunded:
        return '↩️';
      case NotificationType.subscriptionRenewed:
        return '🔄';
      case NotificationType.subscriptionExpiring:
        return '⏰';

      // System
      case NotificationType.systemAnnouncement:
        return '📢';
      case NotificationType.systemEvent:
        return '🎉';
      case NotificationType.systemUpdate:
        return '🔄';
      case NotificationType.systemSecurityAlert:
        return '🔒';
      case NotificationType.systemPolicyUpdate:
        return '📋';
      case NotificationType.systemMaintenance:
        return '🔧';
      case NotificationType.systemOther:
        return '📬';
    }
  }

  /// 알림 색상 (Material Design 3 색상)
  String get colorHex {
    switch (this) {
      // Matching - Pink/Red
      case NotificationType.matchLike:
      case NotificationType.matchSuperLike:
      case NotificationType.matchMutual:
        return '#E91E63'; // Pink

      case NotificationType.matchProfileView:
        return '#9C27B0'; // Purple

      // Chat - Blue
      case NotificationType.chatRequestReceived:
      case NotificationType.chatNewMessage:
        return '#2196F3'; // Blue

      case NotificationType.chatRequestAccepted:
        return '#4CAF50'; // Green

      case NotificationType.chatRequestRejected:
        return '#F44336'; // Red

      case NotificationType.chatRequestExpired:
      case NotificationType.chatRoomExpiring:
        return '#FF9800'; // Orange

      case NotificationType.chatMessageRead:
        return '#03A9F4'; // Light Blue

      // Profile - Green/Orange
      case NotificationType.profileImageApproved:
      case NotificationType.profileVerified:
        return '#4CAF50'; // Green

      case NotificationType.profileImageRejected:
        return '#F44336'; // Red

      case NotificationType.profileIncomplete:
        return '#FF9800'; // Orange

      // Payment - Green/Red
      case NotificationType.paymentCompleted:
      case NotificationType.subscriptionRenewed:
        return '#4CAF50'; // Green

      case NotificationType.paymentFailed:
        return '#F44336'; // Red

      case NotificationType.paymentRefunded:
      case NotificationType.subscriptionExpiring:
        return '#FF9800'; // Orange

      // System - Grey/Blue
      case NotificationType.systemAnnouncement:
      case NotificationType.systemEvent:
        return '#2196F3'; // Blue

      case NotificationType.systemUpdate:
        return '#00BCD4'; // Cyan

      case NotificationType.systemSecurityAlert:
        return '#F44336'; // Red

      case NotificationType.systemPolicyUpdate:
      case NotificationType.systemMaintenance:
      case NotificationType.systemOther:
        return '#607D8B'; // Blue Grey
    }
  }

  /// 카테고리별 그룹화
  String get category {
    if (value.startsWith('MATCH_')) return 'matching';
    if (value.startsWith('CHAT_')) return 'chat';
    if (value.startsWith('PROFILE_')) return 'profile';
    if (value.startsWith('PAYMENT_') || value.startsWith('SUBSCRIPTION_')) {
      return 'payment';
    }
    if (value.startsWith('SYSTEM_')) return 'system';
    return 'other';
  }

  /// 중요도 (0-2: 낮음, 3-4: 보통, 5: 높음)
  int get priority {
    switch (this) {
      // 높음 (5): 즉시 확인 필요
      case NotificationType.matchMutual:
      case NotificationType.chatRequestReceived:
      case NotificationType.chatNewMessage:
      case NotificationType.systemSecurityAlert:
        return 5;

      // 보통 (3-4): 확인 권장
      case NotificationType.matchLike:
      case NotificationType.matchSuperLike:
      case NotificationType.chatRequestAccepted:
      case NotificationType.profileImageApproved:
      case NotificationType.paymentCompleted:
      case NotificationType.subscriptionExpiring:
        return 4;

      // 낮음 (0-2): 나중에 확인 가능
      default:
        return 2;
    }
  }
}
