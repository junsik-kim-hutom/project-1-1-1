import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatRoomPage extends ConsumerStatefulWidget {
  final String roomId;
  final String partnerName;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.partnerName,
  });

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late io.Socket _socket;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  void _initializeSocket() {
    // TODO: Get actual token from secure storage
    const token = 'your-access-token';

    _socket = io.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {
        'token': token,
      },
    });

    _socket.connect();

    _socket.on('chat:receive', (data) {
      setState(() {
        _messages.add({
          'id': data['id'],
          'content': data['content'],
          'senderId': data['senderId'],
          'createdAt': data['createdAt'],
          'isMine': false,
        });
      });
    });

    _socket.on('chat:sent', (data) {
      debugPrint('Message sent: ${data['messageId']}');
    });

    _socket.on('chat:typing', (data) {
      setState(() {
        _isTyping = data['isTyping'];
      });
    });

    _socket.on('chat:time:expired', (data) {
      _showTimeExpiredDialog();
    });
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _socket.emit('chat:send', {
      'roomId': widget.roomId,
      'content': content,
    });

    setState(() {
      _messages.add({
        'content': content,
        'isMine': true,
        'createdAt': DateTime.now().toIso8601String(),
      });
    });

    _messageController.clear();
  }

  void _onTyping(bool isTyping) {
    _socket.emit('chat:typing', {
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
              // TODO: Navigate to payment page
            },
            child: const Text('업그레이드'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socket.disconnect();
    _socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partnerName),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isMine = message['isMine'] ?? false;

                return Align(
                  alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isMine
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['content'],
                      style: TextStyle(
                        color: isMine ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Text(
                    '${widget.partnerName}님이 입력 중...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _onTyping(true);
                        } else {
                          _onTyping(false);
                        }
                      },
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
