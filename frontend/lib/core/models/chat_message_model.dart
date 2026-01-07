import 'enums/message_type.dart';
import 'message_read_status_model.dart';

/// 채팅 메시지 모델
///
/// 백엔드 ChatMessage 테이블과 동기화
/// v2.0에서 그룹 채팅 지원을 위한 readStatus 배열 추가
class ChatMessageModel {
  /// 메시지 ID
  final int id;

  /// 채팅방 ID
  final int roomId;

  /// 발신자 ID
  final int senderId;

  /// 메시지 타입 (TEXT, IMAGE, SYSTEM)
  final MessageType messageType;

  /// 메시지 내용
  final String content;

  /// 읽음 여부 (1:1 채팅용, 하위 호환성)
  final bool isRead;

  /// 읽은 시간 (1:1 채팅용)
  final DateTime? readAt;

  /// 읽음 상태 목록 (그룹 채팅용) - v2.0 추가
  /// 각 참여자별 읽음 상태를 추적
  final List<MessageReadStatusModel>? readStatus;

  /// 생성 시간
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.messageType,
    required this.content,
    required this.isRead,
    this.readAt,
    this.readStatus,
    required this.createdAt,
  });

  /// JSON → Model
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: _parseId(json['id']),
      roomId: _parseId(json['roomId']),
      senderId: _parseId(json['senderId']),
      messageType: MessageType.fromString(json['messageType'] as String),
      content: json['content'] as String,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      readStatus: json['readStatus'] != null
          ? (json['readStatus'] as List)
              .map((e) => MessageReadStatusModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'roomId': roomId,
        'senderId': senderId,
        'messageType': messageType.value,
        'content': content,
        'isRead': isRead,
        'readAt': readAt?.toIso8601String(),
        'readStatus': readStatus?.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  /// 텍스트 메시지인지
  bool get isTextMessage => messageType == MessageType.text;

  /// 이미지 메시지인지
  bool get isImageMessage => messageType == MessageType.image;

  /// 시스템 메시지인지
  bool get isSystemMessage => messageType == MessageType.system;

  /// 읽지 않은 메시지인지
  bool get isUnread => !isRead;

  /// 그룹 채팅에서 특정 사용자가 읽었는지 확인
  bool isReadByUser(int userId) {
    // 발신자는 항상 읽은 것으로 간주
    if (senderId == userId) return true;

    // readStatus가 있으면 그룹 채팅
    if (readStatus != null) {
      return readStatus!.any((status) => status.userId == userId);
    }

    // readStatus가 없으면 1:1 채팅 (기존 isRead 사용)
    return isRead;
  }

  /// 그룹 채팅에서 읽은 사용자 수
  int get readCount {
    if (readStatus == null) {
      return isRead ? 1 : 0;
    }
    return readStatus!.length;
  }

  /// 그룹 채팅에서 특정 사용자가 읽은 시간 조회
  DateTime? getReadTimeByUser(int userId) {
    if (senderId == userId) return createdAt; // 발신자는 생성 시간
    if (readStatus == null) return readAt; // 1:1 채팅

    final status = readStatus!.where((s) => s.userId == userId).firstOrNull;
    return status?.readAt;
  }

  /// 읽음 확인 아이콘 표시 (WhatsApp 스타일)
  /// ✓ = 전송됨 (아무도 안 읽음)
  /// ✓✓ = 읽음 (1:1 채팅에서 상대방이 읽음, 또는 그룹에서 1명 이상 읽음)
  String get readReceiptIcon {
    if (readStatus != null) {
      // 그룹 채팅
      return readStatus!.isEmpty ? '✓' : '✓✓';
    } else {
      // 1:1 채팅
      return isRead ? '✓✓' : '✓';
    }
  }

  /// 읽음 확인 색상 (파란색 = 읽음, 회색 = 안 읽음)
  String get readReceiptColorHex {
    if (readStatus != null) {
      return readStatus!.isEmpty ? '#9E9E9E' : '#2196F3';
    } else {
      return isRead ? '#2196F3' : '#9E9E9E';
    }
  }

  /// copyWith
  ChatMessageModel copyWith({
    int? id,
    int? roomId,
    int? senderId,
    MessageType? messageType,
    String? content,
    bool? isRead,
    DateTime? readAt,
    List<MessageReadStatusModel>? readStatus,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      readStatus: readStatus ?? this.readStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 읽음 처리 (1:1 채팅용)
  ChatMessageModel markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// 그룹 채팅에서 특정 사용자의 읽음 상태 추가
  ChatMessageModel addReadStatus(MessageReadStatusModel status) {
    final currentReadStatus = readStatus ?? [];
    // 중복 방지
    if (currentReadStatus.any((s) => s.userId == status.userId)) {
      return this;
    }

    return copyWith(
      readStatus: [...currentReadStatus, status],
      // 1명이라도 읽으면 isRead도 true로 변경 (하위 호환성)
      isRead: true,
      readAt: status.readAt,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, senderId: $senderId, messageType: ${messageType.value}, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatMessageModel &&
        other.id == id &&
        other.roomId == roomId &&
        other.senderId == senderId &&
        other.messageType == messageType &&
        other.content == content &&
        other.isRead == isRead &&
        other.readAt == readAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomId.hashCode ^
        senderId.hashCode ^
        messageType.hashCode ^
        content.hashCode ^
        isRead.hashCode ^
        readAt.hashCode ^
        createdAt.hashCode;
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
