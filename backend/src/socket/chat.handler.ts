import { Server, Socket } from 'socket.io';
import prisma from '../config/database';
import { verifyAccessToken } from '../common/utils/jwt';
import redis from '../config/redis';

export class ChatSocketHandler {
  private io: Server;
  private userSockets: Map<string, string>;

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

  private async handleChatSend(socket: Socket, senderId: string, data: any) {
    try {
      const { roomId, content } = data;

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
          participants: {
            where: {
              leftAt: null,
            },
          },
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

      const receiverParticipant = room.participants.find((p) => p.userId !== senderId);
      if (receiverParticipant) {
        const receiverSocketId = this.userSockets.get(receiverParticipant.userId);
        if (receiverSocketId) {
          this.io.to(receiverSocketId).emit('chat:receive', message);
        }
      }

      socket.emit('chat:sent', { messageId: message.id });
    } catch (error) {
      console.error('Chat send error:', error);
      socket.emit('error', { message: 'Failed to send message' });
    }
  }

  private async handleTyping(socket: Socket, userId: string, data: any) {
    try {
      const { roomId, isTyping } = data;

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
          participants: {
            where: {
              leftAt: null,
            },
          },
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

  private async handleReadMessage(socket: Socket, userId: string, data: any) {
    try {
      const { messageId } = data;

      await prisma.chatMessage.update({
        where: { id: messageId },
        data: {
          isRead: true,
          readAt: new Date(),
        },
      });

      const message = await prisma.chatMessage.findUnique({
        where: { id: messageId },
        include: { room: true },
      });

      if (message) {
        const room = message.room;
        const senderId = message.senderId;
        const senderSocketId = this.userSockets.get(senderId);

        if (senderSocketId) {
          this.io.to(senderSocketId).emit('chat:read', {
            messageId,
            readAt: message.readAt,
          });
        }
      }
    } catch (error) {
      console.error('Read message error:', error);
    }
  }

  private async handleDisconnect(userId: string) {
    this.userSockets.delete(userId);
    await this.updateUserStatus(userId, 'offline');
    this.broadcastOnlineCount();
    console.log(`❌ User ${userId} disconnected`);
  }

  private async updateUserStatus(userId: string, status: 'online' | 'offline') {
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
