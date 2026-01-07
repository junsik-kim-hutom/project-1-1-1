import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/models/chat_room_summary_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/url_utils.dart';
import '../../providers/chat_provider.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_list_item.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  List<ChatRoomSummaryModel> _rooms = const [];

  bool _sameRoomIds(
      List<ChatRoomSummaryModel> a, List<ChatRoomSummaryModel> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Future<bool> _confirmDeleteAll(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text(l10n.chatTitle, style: AppTextStyles.titleLarge), // "Chat"
        content:
            const Text('Delete all messages in this chat?', // TODO: Localize
                style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'), // TODO: Add to l10n
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _deleteRoomAllMessages({
    required ChatRoomSummaryModel room,
  }) async {
    final removed = room;
    final idx = _rooms.indexWhere((r) => r.id == removed.id);
    if (idx == -1) return;
    setState(() {
      _rooms = List.of(_rooms)..removeAt(idx);
    });

    final repo = ref.read(chatRepositoryProvider);
    final deleted = await repo.deleteAllMessages(removed.id);
    if (!mounted) return;

    if (deleted) {
      ref.invalidate(chatRoomsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat deleted')), // TODO: Localize
      );
      return;
    }

    setState(() {
      _rooms = List.of(_rooms)..insert(idx, removed);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete chat')), // TODO: Localize
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final roomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ChatAppBar(),
      body: roomsAsync.when(
        data: (rooms) {
          if (_rooms.isEmpty || !_sameRoomIds(_rooms, rooms)) {
            _rooms = List.of(rooms);
          }

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.noChatsYet,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Match with someone to start chatting!', // TODO: Localize
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _rooms.length,
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.divider,
              height: 1,
              indent: 90, // Align with text start
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final room = _rooms[index];
              final partnerName = room.otherUser?.displayName ?? l10n.user;
              final partnerUserId = room.otherUser?.id;
              final partnerImageUrl =
                  resolveNetworkUrl(room.otherUser?.imageUrl);
              final lastMessage = room.lastMessage;

              return Dismissible(
                key: ValueKey('chat-room-${room.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: AppColors.error,
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.white, size: 28),
                ),
                confirmDismiss: (direction) async {
                  final confirmed = await _confirmDeleteAll(context);
                  if (confirmed) {
                    // Remove the item immediately before dismissal animation completes
                    await _deleteRoomAllMessages(room: room);
                  }
                  return confirmed;
                },
                onDismissed: (_) {
                  // Item already removed in confirmDismiss
                },
                child: ChatListItem(
                  partnerName: partnerName,
                  partnerImageUrl: partnerImageUrl,
                  lastMessage: lastMessage?.content ?? l10n.startMatchingToChat,
                  timeAgo: _formatTime(
                      context, lastMessage?.createdAt ?? room.createdAt),
                  unreadCount: room.unreadCount,
                  onTap: () {
                    context.push(
                      '/chat/rooms/${room.id}',
                      extra: {
                        'partnerName': partnerName,
                        if (partnerUserId != null)
                          'partnerUserId': partnerUserId,
                        if (partnerImageUrl != null)
                          'partnerImageUrl': partnerImageUrl,
                      },
                    );
                  },
                  onDelete: () async {
                    if (await _confirmDeleteAll(context)) {
                      _deleteRoomAllMessages(room: room);
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load chats', // TODO: Localize
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(chatRoomsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    // Better time formatting logic
    if (diff.inMinutes < 1) {
      return 'Now'; // TODO: Localize
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24 && now.day == time.day) {
      return DateFormat('h:mm a').format(time);
    } else if (diff.inDays < 7) {
      return DateFormat('EEE').format(time); // Mon, Tue...
    } else {
      return DateFormat('MMM d').format(time); // Jun 12
    }
  }
}
