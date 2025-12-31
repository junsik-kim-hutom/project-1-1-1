/// 채팅방 참여자 모델
///
/// 백엔드 ChatRoomParticipant 테이블과 동기화
/// v2.0에서 신규 추가 - 그룹 채팅 지원을 위해 user1/user2에서 분리
class ChatRoomParticipantModel {
  /// ID
  final String id;

  /// 채팅방 ID
  final String roomId;

  /// 사용자 ID
  final String userId;

  /// 역할 (owner, admin, member)
  final String role;

  /// 마지막으로 읽은 메시지 ID - v2.0 추가
  final String? lastReadMessageId;

  /// 마지막 읽은 시간 - v2.0 추가
  final DateTime? lastReadAt;

  /// 읽지 않은 메시지 수 - v2.0 추가
  final int unreadCount;

  /// 참여 시간
  final DateTime joinedAt;

  /// 퇴장 시간 (나간 경우)
  final DateTime? leftAt;

  ChatRoomParticipantModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.role,
    this.lastReadMessageId,
    this.lastReadAt,
    required this.unreadCount,
    required this.joinedAt,
    this.leftAt,
  });

  /// JSON → Model
  factory ChatRoomParticipantModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomParticipantModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      lastReadMessageId: json['lastReadMessageId'] as String?,
      lastReadAt: json['lastReadAt'] != null
          ? DateTime.parse(json['lastReadAt'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      leftAt: json['leftAt'] != null
          ? DateTime.parse(json['leftAt'] as String)
          : null,
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'roomId': roomId,
        'userId': userId,
        'role': role,
        'lastReadMessageId': lastReadMessageId,
        'lastReadAt': lastReadAt?.toIso8601String(),
        'unreadCount': unreadCount,
        'joinedAt': joinedAt.toIso8601String(),
        'leftAt': leftAt?.toIso8601String(),
      };

  /// 방장인지
  bool get isOwner => role == 'owner';

  /// 관리자인지
  bool get isAdmin => role == 'admin';

  /// 일반 멤버인지
  bool get isMember => role == 'member';

  /// 현재 참여 중인지 (나가지 않은 상태)
  bool get isActive => leftAt == null;

  /// 읽지 않은 메시지가 있는지
  bool get hasUnreadMessages => unreadCount > 0;

  /// copyWith
  ChatRoomParticipantModel copyWith({
    String? id,
    String? roomId,
    String? userId,
    String? role,
    String? lastReadMessageId,
    DateTime? lastReadAt,
    int? unreadCount,
    DateTime? joinedAt,
    DateTime? leftAt,
  }) {
    return ChatRoomParticipantModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      unreadCount: unreadCount ?? this.unreadCount,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
    );
  }

  /// 읽지 않은 메시지 수 증가
  ChatRoomParticipantModel incrementUnreadCount() {
    return copyWith(unreadCount: unreadCount + 1);
  }

  /// 읽지 않은 메시지 수 초기화
  ChatRoomParticipantModel resetUnreadCount({String? messageId}) {
    return copyWith(
      unreadCount: 0,
      lastReadMessageId: messageId ?? lastReadMessageId,
      lastReadAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ChatRoomParticipantModel(id: $id, userId: $userId, role: $role, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoomParticipantModel &&
        other.id == id &&
        other.roomId == roomId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ roomId.hashCode ^ userId.hashCode;
  }
}
