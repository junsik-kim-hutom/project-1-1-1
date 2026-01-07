import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/chat_room_summary_model.dart';
import '../../../../core/models/chat_message_model.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  Future<Map<String, dynamic>> createOrGetDirectRoom({
    required int targetUserId,
    String? initialMessage,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatDirectRoom,
        data: {
          'targetUserId': targetUserId,
          if (initialMessage != null) 'initialMessage': initialMessage,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to create chat room');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<ChatRoomSummaryModel>> fetchChatRooms() async {
    try {
      final response = await _dio.get(ApiConstants.chatRooms);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((item) => ChatRoomSummaryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load chat rooms');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<ChatMessageModel>> fetchMessages(int roomId) async {
    try {
      final response =
          await _dio.get(ApiConstants.chatMessages(roomId.toString()));
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load messages');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>?> markRoomRead({
    required int roomId,
    int? upToMessageId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatMarkRead(roomId.toString()),
        data: {
          if (upToMessageId != null) 'upToMessageId': upToMessageId,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (_) {
      return null;
    }
  }

  Future<bool> deleteAllMessages(int roomId) async {
    try {
      final response =
          await _dio.delete(ApiConstants.chatDeleteAllMessages(roomId.toString()));
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> deleteMessage(int messageId) async {
    try {
      final response =
          await _dio.delete(ApiConstants.chatDeleteMessage(messageId.toString()));
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (_) {
      return false;
    }
  }
}
