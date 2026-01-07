import { Server, Socket } from 'socket.io';
import prisma from '../config/database';
import { verifyAccessToken } from '../common/utils/jwt';
import redis from '../config/redis';

export class ChatSocketHandler {
  private io: Server;
  private userSockets: Map<number, string>;

  constructor(io: Server) {
    this.io = io;
    this.userSockets = new Map();
  }

  handleConnection(socket: Socket) {
    const token = socket.handshake.auth.token;

    if (!token) {
      socket.disconnect();
      return;
    }

    try {
      const user = verifyAccessToken(token);
      const userId = user.userId;

      this.userSockets.set(userId, socket.id);

      this.updateUserStatus(userId, 'online');
      this.broadcastOnlineCount();

      console.log(`✅ User ${userId} connected`);

      socket.on('chat:send', (data) => this.handleChatSend(socket, userId, data));
      socket.on('chat:typing', (data) => this.handleTyping(socket, userId, data));
      socket.on('chat:read', (data) => this.handleReadMessage(socket, userId, data));
      socket.on('disconnect', () => this.handleDisconnect(userId));
    } catch (error) {
      console.error('Socket authentication failed:', error);
      socket.disconnect();
    }
  }

  private async handleChatSend(socket: Socket, senderId: number, data: any) {
    try {
      const roomId = parseInt(data?.roomId);
      const content = (data?.content ?? '').toString().trim();
      if (!roomId || isNaN(roomId) || !content) {
        socket.emit('error', { message: 'Invalid message' });
        return;
      }

      const room = await prisma.chatRoom.findFirst({
        where: {
          id: roomId,
          participants: {
            some: {
              userId: senderId,
              leftAt: null,
            },
          },
        },
        include: {
          participants: true,
        },
      });

      if (!room) {
        socket.emit('error', { message: 'Unauthorized or room not found' });
        return;
      }

      if (!room.isPremium && room.expiresAt && new Date() > room.expiresAt) {
        socket.emit('chat:time:expired', {
          message: '대화 시간이 만료되었습니다. 프리미엄으로 업그레이드하세요.',
        });
        return;
      }

      const message = await prisma.chatMessage.create({
        data: {
          roomId,
          senderId,
          content,
          messageType: 'TEXT',
        },
      });

      // Unread count 관리 (간단한 1:1/소규모 채팅 기준)
      await prisma.chatRoomParticipant.updateMany({
        where: {
          roomId,
          leftAt: null,
          userId: {
            not: senderId,
          },
        },
        data: {
          unreadCount: { increment: 1 },
        },
      });
      await prisma.chatRoomParticipant.updateMany({
        where: {
          roomId,
          leftAt: null,
          userId: senderId,
        },
        data: {
          lastReadMessageId: message.id,
          lastReadAt: new Date(),
          unreadCount: 0,
        },
      });

      const receiverParticipant = room.participants.find((p) => p.userId !== senderId);
      if (receiverParticipant) {
        const preview = content.length > 80 ? `${content.slice(0, 80)}…` : content;
        await prisma.notification.create({
          data: {
            userId: receiverParticipant.userId,
            type: 'CHAT_NEW_MESSAGE' as any,
            title: {
              ko: '새 메시지',
              ja: '新しいメッセージ',
              en: 'New message',
            },
            message: {
              ko: preview,
              ja: preview,
              en: preview,
            },
            relatedUserId: senderId,
            relatedMessageId: message.id,
            isPushSent: false,
            isActionable: true,
            actionUrl: `/chat/rooms/${roomId}`,
            data: { roomId },
          },
        });

        const receiverSocketId = this.userSockets.get(receiverParticipant.userId);
        if (receiverSocketId) {
          this.io.to(receiverSocketId).emit('chat:receive', message);
        }
      }

      // 발신자에게도 최종 저장된 메시지를 전달 (optimistic UI 보정/재진입 시 불일치 방지)
      socket.emit('chat:sent', { message });
    } catch (error) {
      console.error('Chat send error:', error);
      socket.emit('error', { message: 'Failed to send message' });
    }
  }

  private async handleTyping(socket: Socket, userId: number, data: any) {
    try {
      const roomId = parseInt(data?.roomId);
      const isTyping = data?.isTyping;

      if (!roomId || isNaN(roomId)) return;

      const room = await prisma.chatRoom.findFirst({
        where: {
          id: roomId,
          participants: {
            some: {
              userId,
              leftAt: null,
            },
          },
        },
        include: {
          participants: true,
        },
      });

      if (!room) return;

      const receiverParticipant = room.participants.find((p) => p.userId !== userId);
      if (receiverParticipant) {
        const receiverSocketId = this.userSockets.get(receiverParticipant.userId);
        if (receiverSocketId) {
          this.io.to(receiverSocketId).emit('chat:typing', {
            roomId,
            userId,
            isTyping,
          });
        }
      }
    } catch (error) {
      console.error('Typing indicator error:', error);
    }
  }

  private async handleReadMessage(socket: Socket, userId: number, data: any) {
    try {
      const messageId = data?.messageId ? parseInt(data.messageId) : undefined;
      const roomId = data?.roomId ? parseInt(data.roomId) : undefined;

      // 1) messageId 기반으로 room/sender/cutoff 구하기 (옵션)
      const referencedMessage =
        messageId && !isNaN(messageId)
          ? await prisma.chatMessage.findUnique({
              where: { id: messageId },
              select: { id: true, roomId: true, senderId: true, createdAt: true },
            })
          : null;

      const resolvedRoomId = roomId ?? referencedMessage?.roomId;
      if (!resolvedRoomId) return;

      // 2) 참여자 검증
      const participant = await prisma.chatRoomParticipant.findFirst({
        where: {
          roomId: resolvedRoomId,
          userId,
          leftAt: null,
        },
        select: { id: true },
      });
      if (!participant) return;

      const now = new Date();

      // 3) 읽음 처리할 메시지 목록 조회
      const senderFilter = referencedMessage?.senderId && referencedMessage.senderId !== userId
        ? referencedMessage.senderId
        : undefined;
      const cutoff = referencedMessage?.createdAt;

      const unreadMessages = await prisma.chatMessage.findMany({
        where: {
          roomId: resolvedRoomId,
          senderId: senderFilter ? senderFilter : { not: userId },
          isRead: false,
          ...(cutoff
            ? {
                createdAt: { lte: cutoff },
              }
            : {}),
        },
        orderBy: { createdAt: 'asc' },
        select: { id: true, senderId: true, createdAt: true },
      });

      if (unreadMessages.length === 0) return;

      // 4) 메시지 읽음 업데이트
      await prisma.chatMessage.updateMany({
        where: {
          id: { in: unreadMessages.map((m) => m.id) },
        },
        data: {
          isRead: true,
          readAt: now,
        },
      });

      // 5) 참여자 읽음 상태 업데이트
      const latestRead = unreadMessages[unreadMessages.length - 1];
      const remainingUnreadCount = await prisma.chatMessage.count({
        where: {
          roomId: resolvedRoomId,
          senderId: { not: userId },
          isRead: false,
        },
      });

      await prisma.chatRoomParticipant.update({
        where: { id: participant.id },
        data: {
          lastReadMessageId: latestRead.id,
          lastReadAt: now,
          unreadCount: remainingUnreadCount,
        },
      });

      // 6) 발신자들에게 읽음 알림 (그룹 채팅 대비)
      const latestBySender = new Map<number, { messageId: number; createdAt: Date }>();
      for (const m of unreadMessages) {
        const existing = latestBySender.get(m.senderId);
        if (!existing || existing.createdAt.getTime() < m.createdAt.getTime()) {
          latestBySender.set(m.senderId, { messageId: m.id, createdAt: m.createdAt });
        }
      }

      for (const [senderId, latest] of latestBySender.entries()) {
        const senderSocketId = this.userSockets.get(senderId);
        if (!senderSocketId) continue;

        this.io.to(senderSocketId).emit('chat:read', {
          roomId: resolvedRoomId,
          upToMessageId: latest.messageId,
          upToCreatedAt: latest.createdAt.toISOString(),
          readAt: now.toISOString(),
        });
      }
    } catch (error) {
      console.error('Read message error:', error);
    }
  }

  private async handleDisconnect(userId: number) {
    this.userSockets.delete(userId);
    await this.updateUserStatus(userId, 'offline');
    this.broadcastOnlineCount();
    console.log(`❌ User ${userId} disconnected`);
  }

  private async updateUserStatus(userId: number, status: 'online' | 'offline') {
    try {
      await redis.setex(`user:${userId}:status`, 300, status);
      this.io.emit('user:status:update', { userId, status });
    } catch (error) {
      console.error('Update user status error:', error);
    }
  }

  private broadcastOnlineCount() {
    const count = this.userSockets.size;
    this.io.emit('system:users:count', count);
  }
}
