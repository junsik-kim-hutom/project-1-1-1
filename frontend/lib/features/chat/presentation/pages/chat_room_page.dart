import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/chat_message_model.dart';
import '../../../../core/models/enums/message_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/providers/secure_storage_provider.dart';
import '../../../profile/providers/profile_provider.dart';
import '../widgets/chat_room_app_bar.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  final int roomId;
  final String partnerName;
  final int? partnerUserId;
  final String? partnerImageUrl;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.partnerName,
    this.partnerUserId,
    this.partnerImageUrl,
  });

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _messageController = TextEditingController();
  final List<ChatMessageModel> _socketMessages = [];
  io.Socket? _socket;
  bool _isTyping = false;
  bool _didMarkInitialRead = false;
  DateTime? _myMessagesReadUpToCreatedAt;
  DateTime? _myMessagesReadAt;
  bool _selectionMode = false;
  final Set<int> _selectedMessageIds = <int>{};
  ProviderContainer? _container;

  @override
  void initState() {
    super.initState();
    ref.read(profileProvider.notifier).loadMyProfile();
    _initializeSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container ??= ProviderScope.containerOf(context, listen: false);
  }

  Future<void> _initializeSocket() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'access_token');
    if (token == null) return;

    _socket = io.io(ApiConstants.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    _socket?.connect();

    _socket?.on('chat:receive', (data) {
      final message = _parseSocketMessage(data);
      if (mounted) {
        setState(() {
          _socketMessages.add(message);
        });
        _markRoomRead(upToMessageId: message.id);
      }
    });

    _socket?.on('chat:sent', (data) {
      if (!mounted) return;
      if (data is Map && data['message'] is Map) {
        final sent = _parseSocketMessage(data['message']);
        final myProfile = ref.read(profileProvider).profile;
        final currentUserId =
            myProfile?.userId ?? ref.read(authProvider).user?.id ?? -1;
        setState(() {
          final idx = _socketMessages.lastIndexWhere(
            (m) =>
                m.senderId == currentUserId &&
                m.content == sent.content &&
                _isLocalMessageId(m.id) &&
                (sent.createdAt.difference(m.createdAt).inSeconds).abs() <= 10,
          );
          if (idx != -1) {
            _socketMessages[idx] = sent;
          } else {
            _socketMessages.add(sent);
          }
        });
        return;
      }
    });

    _socket?.on('chat:read', (data) {
      final roomId = _parseNullableId(data is Map ? data['roomId'] : null);
      if (roomId != null && roomId != widget.roomId) return;

      final upToCreatedAtRaw = data is Map ? data['upToCreatedAt'] : null;
      final readAtRaw = data is Map ? data['readAt'] : null;
      final upToCreatedAt = upToCreatedAtRaw != null
          ? DateTime.tryParse(upToCreatedAtRaw.toString())
          : null;
      final readAt =
          readAtRaw != null ? DateTime.tryParse(readAtRaw.toString()) : null;

      if (mounted) {
        if (upToCreatedAt != null) {
          setState(() {
            _myMessagesReadUpToCreatedAt = upToCreatedAt;
            _myMessagesReadAt = readAt ?? _myMessagesReadAt ?? DateTime.now();
          });
        } else {
          final messageId =
              _parseNullableId(data is Map ? data['messageId'] : null);
          if (messageId == null) return;
          setState(() {
            for (var i = 0; i < _socketMessages.length; i++) {
              final m = _socketMessages[i];
              if (m.id == messageId) {
                _socketMessages[i] = m.copyWith(isRead: true, readAt: readAt);
                break;
              }
            }
          });
        }
      }
    });

    _socket?.on('chat:typing', (data) {
      if (mounted) {
        setState(() {
          _isTyping = data['isTyping'];
        });
      }
    });

    _socket?.on('chat:time:expired', (data) {
      if (mounted) _showTimeExpiredDialog();
    });

    _socket?.onConnect((_) {
      _markRoomRead();
    });
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _socket?.emit('chat:send', {
      'roomId': widget.roomId,
      'content': content,
    });

    final myProfile = ref.read(profileProvider).profile;
    final currentUserId =
        myProfile?.userId ?? ref.read(authProvider).user?.id ?? -1;
    setState(() {
      _socketMessages.add(
        ChatMessageModel(
          id: _createLocalMessageId(),
          roomId: widget.roomId,
          senderId: currentUserId,
          messageType: MessageType.text,
          content: content,
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
  }

  Future<void> _markRoomRead({int? upToMessageId}) async {
    if (!mounted) return;

    if ((_socket?.connected ?? false) == true) {
      _socket?.emit('chat:read', {
        'roomId': widget.roomId,
        if (upToMessageId != null) 'messageId': upToMessageId,
      });
      return;
    }

    final repo = ref.read(chatRepositoryProvider);
    await repo.markRoomRead(
        roomId: widget.roomId, upToMessageId: upToMessageId);
  }

  void _onTyping(bool isTyping) {
    _socket?.emit('chat:typing', {
      'roomId': widget.roomId,
      'isTyping': isTyping,
    });
  }

  void _showTimeExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('대화 시간 만료'),
        content: const Text('무료 사용자는 30분까지 대화할 수 있습니다.\n프리미엄으로 업그레이드하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('업그레이드'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _container?.invalidate(chatRoomsProvider);
    _container?.invalidate(chatMessagesProvider(widget.roomId));
    _socket?.disconnect();
    _socket?.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _toggleSelection(int messageId) {
    setState(() {
      _selectionMode = true;
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        if (_selectedMessageIds.isEmpty) {
          _selectionMode = false;
        }
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedMessageIds.clear();
    });
  }

  Future<void> _confirmAndDeleteSelected() async {
    if (_selectedMessageIds.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메시지 삭제'),
        content: Text('선택한 메시지 ${_selectedMessageIds.length}개를 삭제할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제')),
        ],
      ),
    );
    if (ok != true) return;

    final repo = ref.read(chatRepositoryProvider);
    final ids = _selectedMessageIds.toList(growable: false);
    var anyDeleted = false;
    final localIds =
        ids.where(_isLocalMessageId).toList(growable: false);
    final serverIds =
        ids.where((id) => !_isLocalMessageId(id)).toList(growable: false);

    if (localIds.isNotEmpty) {
      anyDeleted = true;
      setState(() {
        _socketMessages.removeWhere((m) => localIds.contains(m.id));
      });
    }

    for (final id in serverIds) {
      final deleted = await repo.deleteMessage(id);
      anyDeleted = anyDeleted || deleted;
    }

    if (!mounted) return;
    if (anyDeleted) {
      setState(() {
        _socketMessages.removeWhere((m) => _selectedMessageIds.contains(m.id));
      });
      ref.invalidate(chatMessagesProvider(widget.roomId));
      ref.invalidate(chatRoomsProvider);
    }
    _exitSelectionMode();
  }

  Future<void> _confirmAndDeleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메시지 전체 삭제'),
        content: const Text('이 채팅방의 메시지를 모두 삭제할까요?\n삭제하면 채팅 목록에서도 숨겨집니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제')),
        ],
      ),
    );
    if (ok != true) return;

    final repo = ref.read(chatRepositoryProvider);
    final deleted = await repo.deleteAllMessages(widget.roomId);
    if (!mounted) return;
    if (deleted) {
      setState(() {
        _socketMessages.clear();
      });
      ref.invalidate(chatMessagesProvider(widget.roomId));
      ref.invalidate(chatRoomsProvider);
      Navigator.pop(context);
    }
  }

  void _showRoomMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('메시지 전체 삭제',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmAndDeleteAll();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.checklist, color: AppColors.textPrimary),
              title: const Text('선택 삭제',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectionMode = true;
                  _selectedMessageIds.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  ChatMessageModel _parseSocketMessage(dynamic data) {
    final createdAt = data['createdAt'];
    final messageId = _parseNullableId(data['id']) ?? _createLocalMessageId();
    final roomId = _parseNullableId(data['roomId']) ?? widget.roomId;
    final senderId = _parseNullableId(data['senderId']) ?? -1;
    return ChatMessageModel(
      id: messageId,
      roomId: roomId,
      senderId: senderId,
      messageType:
          MessageType.fromString(data['messageType'] as String? ?? 'TEXT'),
      content: data['content'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      readAt: data['readAt'] != null ? DateTime.parse(data['readAt']) : null,
      createdAt: createdAt != null
          ? DateTime.parse(createdAt as String)
          : DateTime.now(),
    );
  }

  List<ChatMessageModel> _mergeMessages(List<ChatMessageModel> apiMessages) {
    final merged = [...apiMessages, ..._socketMessages];
    merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return merged;
  }

  bool _isReadByPartner(ChatMessageModel message, int currentUserId) {
    if (message.senderId != currentUserId) return false;
    if (message.isRead) return true;
    final upTo = _myMessagesReadUpToCreatedAt;
    if (upTo == null) return false;
    return !message.createdAt.isAfter(upTo);
  }

  String _formatMessageTime(DateTime time) {
    return DateFormat('yyyy-MM-dd HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.roomId));
    final myProfile = ref.watch(profileProvider).profile;
    final currentUserId =
        myProfile?.userId ?? ref.watch(authProvider).user?.id ?? -1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ChatRoomAppBar(
        partnerName: widget.partnerName,
        partnerImageUrl: widget.partnerImageUrl,
        selectionMode: _selectionMode,
        selectedCount: _selectedMessageIds.length,
        onDeleteSelected: _confirmAndDeleteSelected,
        onExitSelectionMode: _exitSelectionMode,
        onMorePressed: _showRoomMenu,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                final mergedMessages = _mergeMessages(messages);
                if (!_didMarkInitialRead) {
                  _didMarkInitialRead = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _markRoomRead();
                  });
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  reverse: true,
                  itemCount: mergedMessages.length,
                  itemBuilder: (context, index) {
                    final message =
                        mergedMessages[mergedMessages.length - 1 - index];
                    final isMine = message.senderId == currentUserId;
                    final isReadByPartner =
                        _isReadByPartner(message, currentUserId);
                    final timeText = _formatMessageTime(message.createdAt);

                    return MessageBubble(
                      message: message.content,
                      isMine: isMine,
                      timeText: timeText,
                      imageUrl: isMine ? null : widget.partnerImageUrl,
                      isRead: isReadByPartner,
                      isSelectionMode: _selectionMode,
                      isSelected: _selectedMessageIds.contains(message.id),
                      onToggleSelection: () => _toggleSelection(message.id),
                    );
                  },
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (error, stackTrace) => const Center(
                child: Text('메시지를 불러오지 못했습니다.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${widget.partnerName}님이 입력 중...',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
            onChanged: (value) {
              if (value.isNotEmpty) {
                _onTyping(true);
              } else {
                _onTyping(false);
              }
            },
            isTyping: _isTyping,
          ),
        ],
      ),
    );
  }

  int _createLocalMessageId() {
    return -DateTime.now().microsecondsSinceEpoch;
  }

  bool _isLocalMessageId(int id) {
    return id < 0;
  }

  int? _parseNullableId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
