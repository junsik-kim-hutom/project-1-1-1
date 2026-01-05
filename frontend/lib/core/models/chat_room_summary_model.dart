import 'chat_message_model.dart';

class ChatUserSummary {
  final String id;
  final String displayName;

  ChatUserSummary({
    required this.id,
    required this.displayName,
  });

  factory ChatUserSummary.fromJson(Map<String, dynamic> json) {
    return ChatUserSummary(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? '',
    );
  }
}

class ChatRoomSummaryModel {
  final String id;
  final String roomType;
  final String? name;
  final String status;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final bool isPremium;
  final DateTime createdAt;
  final ChatUserSummary? otherUser;
  final ChatMessageModel? lastMessage;
  final int unreadCount;

  ChatRoomSummaryModel({
    required this.id,
    required this.roomType,
    this.name,
    required this.status,
    required this.startedAt,
    this.expiresAt,
    required this.isPremium,
    required this.createdAt,
    this.otherUser,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ChatRoomSummaryModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomSummaryModel(
      id: json['id'] as String,
      roomType: json['roomType'] as String? ?? 'direct',
      name: json['name'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isPremium: json['isPremium'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      otherUser: json['otherUser'] != null
          ? ChatUserSummary.fromJson(json['otherUser'] as Map<String, dynamic>)
          : null,
      lastMessage: json['lastMessage'] != null
          ? ChatMessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
