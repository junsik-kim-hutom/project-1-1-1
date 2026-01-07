import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/models/chat_room_summary_model.dart';
import '../../../core/models/chat_message_model.dart';
import '../data/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatRepository(dio);
});

final chatRoomsProvider = FutureProvider<List<ChatRoomSummaryModel>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.fetchChatRooms();
});

final chatMessagesProvider =
    FutureProvider.autoDispose.family<List<ChatMessageModel>, int>((ref, roomId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.fetchMessages(roomId);
});
