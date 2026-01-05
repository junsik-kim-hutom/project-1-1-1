import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/chat_room_summary_model.dart';
import '../../../../core/models/chat_message_model.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

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

  Future<List<ChatMessageModel>> fetchMessages(String roomId) async {
    try {
      final response = await _dio.get(ApiConstants.chatMessages(roomId));
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
}
