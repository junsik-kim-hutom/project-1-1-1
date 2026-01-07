import 'chat_room_participant_model.dart';

/// 채팅방 모델
///
/// 백엔드 ChatRoom 테이블과 동기화
/// v2.0에서 그룹 채팅 지원을 위해 user1/user2에서 participants로 변경
class ChatRoomModel {
  /// 채팅방 ID
  final int id;

  /// 채팅방 타입 (direct = 1:1, group = 그룹)
  /// v2.0 추가
  final String roomType;

  /// 채팅방 이름 (그룹 채팅용, 1:1은 null)
  /// v2.0 추가
  final String? name;

  /// 참여자 목록
  /// v2.0에서 user1/user2 대신 participants 사용
  final List<ChatRoomParticipantModel>? participants;

  /// 채팅방 상태 (ACTIVE, EXPIRED, CLOSED)
  final String status;

  /// 시작 시간
  final DateTime startedAt;

  /// 만료 시간 (무료 사용자용, 30분)
  final DateTime? expiresAt;

  /// 생성 시간
  final DateTime createdAt;

  /// 수정 시간
  final DateTime updatedAt;

  ChatRoomModel({
    required this.id,
    required this.roomType,
    this.name,
    this.participants,
    required this.status,
    required this.startedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON → Model
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: _parseId(json['id']),
      roomType: json['roomType'] as String? ?? 'direct',
      name: json['name'] as String?,
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((e) => ChatRoomParticipantModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'roomType': roomType,
        'name': name,
        'participants': participants?.map((e) => e.toJson()).toList(),
        'status': status,
        'startedAt': startedAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 1:1 채팅방인지
  bool get isDirectChat => roomType == 'direct';

  /// 그룹 채팅방인지
  bool get isGroupChat => roomType == 'group';

  /// 활성 상태인지
  bool get isActive => status == 'ACTIVE';

  /// 만료되었는지
  bool get isExpired => status == 'EXPIRED';

  /// 닫혔는지
  bool get isClosed => status == 'CLOSED';

  /// 현재 시점에서 실제로 활성인지 (만료 시간 체크)
  bool get isCurrentlyActive {
    if (!isActive) return false;
    if (expiresAt == null) return true; // 무제한
    return DateTime.now().isBefore(expiresAt!);
  }

  /// 만료까지 남은 시간 (초)
  int? get secondsUntilExpiry {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return 0;
    return expiresAt!.difference(now).inSeconds;
  }

  /// 만료까지 남은 시간 (분)
  int? get minutesUntilExpiry {
    final seconds = secondsUntilExpiry;
    if (seconds == null) return null;
    return (seconds / 60).ceil();
  }

  /// 곧 만료 예정인지 (5분 이내)
  bool get isExpiringSoon {
    final minutes = minutesUntilExpiry;
    if (minutes == null) return false;
    return minutes > 0 && minutes <= 5;
  }

  /// 참여자 수
  int get participantCount {
    if (participants == null) return 0;
    return participants!.where((p) => p.isActive).length;
  }

  /// 활성 참여자 목록
  List<ChatRoomParticipantModel> get activeParticipants {
    if (participants == null) return [];
    return participants!.where((p) => p.isActive).toList();
  }

  /// 특정 사용자가 참여 중인지
  bool hasParticipant(int userId) {
    return activeParticipants.any((p) => p.userId == userId);
  }

  /// 특정 사용자의 참여자 정보 조회
  ChatRoomParticipantModel? getParticipant(int userId) {
    if (participants == null) return null;
    return participants!.where((p) => p.userId == userId && p.isActive).firstOrNull;
  }

  /// 상대방 참여자 조회 (1:1 채팅용)
  ChatRoomParticipantModel? getOtherParticipant(int myUserId) {
    if (!isDirectChat) return null;
    return activeParticipants.where((p) => p.userId != myUserId).firstOrNull;
  }

  /// 방장 조회
  ChatRoomParticipantModel? get owner {
    if (participants == null) return null;
    return participants!.where((p) => p.isOwner && p.isActive).firstOrNull;
  }

  /// 채팅방 표시 이름 (그룹명 또는 상대방 이름)
  String getDisplayName(int myUserId, {String? otherUserName}) {
    if (isGroupChat) {
      return name ?? '그룹 채팅';
    }

    // 1:1 채팅: 상대방 이름 반환
    if (otherUserName != null) {
      return otherUserName;
    }

    final otherParticipant = getOtherParticipant(myUserId);
    return otherParticipant != null ? '사용자 ${otherParticipant.userId}' : '알 수 없음';
  }

  /// 읽지 않은 메시지 수 (특정 사용자 기준)
  int getUnreadCount(int userId) {
    final participant = getParticipant(userId);
    return participant?.unreadCount ?? 0;
  }

  /// 만료 시간 문자열
  String? get expiryTimeText {
    final minutes = minutesUntilExpiry;
    if (minutes == null) return null;
    if (minutes <= 0) return '만료됨';
    if (minutes < 60) return '$minutes분 남음';
    final hours = (minutes / 60).floor();
    return '$hours시간 남음';
  }

  /// copyWith
  ChatRoomModel copyWith({
    int? id,
    String? roomType,
    String? name,
    List<ChatRoomParticipantModel>? participants,
    String? status,
    DateTime? startedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      roomType: roomType ?? this.roomType,
      name: name ?? this.name,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ChatRoomModel(id: $id, roomType: $roomType, status: $status, participantCount: $participantCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoomModel &&
        other.id == id &&
        other.roomType == roomType &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ roomType.hashCode ^ status.hashCode;
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
