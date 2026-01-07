/// 메시지 읽음 상태 모델
///
/// 그룹 채팅에서 각 참여자별로 메시지를 읽었는지 추적
/// 백엔드 MessageReadStatus 테이블과 동기화
class MessageReadStatusModel {
  /// ID
  final int id;

  /// 메시지 ID
  final int messageId;

  /// 사용자 ID
  final int userId;

  /// 읽은 시간
  final DateTime readAt;

  MessageReadStatusModel({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.readAt,
  });

  /// JSON → Model
  factory MessageReadStatusModel.fromJson(Map<String, dynamic> json) {
    return MessageReadStatusModel(
      id: _parseId(json['id']),
      messageId: _parseId(json['messageId']),
      userId: _parseId(json['userId']),
      readAt: DateTime.parse(json['readAt'] as String),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'messageId': messageId,
        'userId': userId,
        'readAt': readAt.toIso8601String(),
      };

  /// copyWith
  MessageReadStatusModel copyWith({
    int? id,
    int? messageId,
    int? userId,
    DateTime? readAt,
  }) {
    return MessageReadStatusModel(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      userId: userId ?? this.userId,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() {
    return 'MessageReadStatusModel(id: $id, messageId: $messageId, userId: $userId, readAt: $readAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageReadStatusModel &&
        other.id == id &&
        other.messageId == messageId &&
        other.userId == userId &&
        other.readAt == readAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ messageId.hashCode ^ userId.hashCode ^ readAt.hashCode;
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}
