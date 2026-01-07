import prisma from '../../config/database';

export class ChatService {
  private pickProfileImageUrl(profile: any): string | null {
    const images = (profile?.images ?? []) as Array<any>;
    if (!images || images.length === 0) return null;
    const main = images.find((img) => img.imageType === 'MAIN') ?? images[0];
    return (main?.imageUrl ?? null) as string | null;
  }

  async createOrGetDirectRoom(userId: number, targetUserId: number, initialMessage?: string) {
    if (userId === targetUserId) throw new Error('Invalid target user');

    const isBlocked = await prisma.userBlock.findFirst({
      where: {
        OR: [
          { userId, blockedUserId: targetUserId },
          { userId: targetUserId, blockedUserId: userId },
        ],
      },
      select: { id: true },
    });
    if (isBlocked) throw new Error('User is blocked');

    const existing = await prisma.chatRoom.findFirst({
      where: {
        roomType: 'direct',
        status: 'ACTIVE',
        participants: {
          some: { userId, leftAt: null },
        },
        AND: [
          {
            participants: {
              some: { userId: targetUserId, leftAt: null },
            },
          },
        ],
      },
    });

    const room =
      existing ??
      (await prisma.chatRoom.create({
        data: {
          roomType: 'direct',
          participants: {
            create: [
              { userId, role: 'member' },
              { userId: targetUserId, role: 'member' },
            ],
          },
        },
      }));

    const trimmed = (initialMessage ?? '').trim();
    if (trimmed.length > 0) {
      const message = await prisma.chatMessage.create({
        data: {
          roomId: room.id,
          senderId: userId,
          content: trimmed,
          messageType: 'TEXT',
        },
      });

      await prisma.chatRoomParticipant.updateMany({
        where: {
          roomId: room.id,
          leftAt: null,
          userId: { not: userId },
        },
        data: {
          unreadCount: { increment: 1 },
        },
      });
      await prisma.chatRoomParticipant.updateMany({
        where: {
          roomId: room.id,
          leftAt: null,
          userId,
        },
        data: {
          lastReadMessageId: message.id,
          lastReadAt: new Date(),
          unreadCount: 0,
        },
      });

      const preview = trimmed.length > 80 ? `${trimmed.slice(0, 80)}…` : trimmed;
      await prisma.notification.create({
        data: {
          userId: targetUserId,
          type: 'CHAT_NEW_MESSAGE' as any,
          title: { ko: '새 메시지', ja: '新しいメッセージ', en: 'New message' },
          message: { ko: preview, ja: preview, en: preview },
          relatedUserId: userId,
          relatedMessageId: message.id,
          isPushSent: false,
          isActionable: true,
          actionUrl: `/chat/rooms/${room.id}`,
          data: { roomId: room.id },
        },
      });
    }

    const partner = await prisma.user.findUnique({
      where: { id: targetUserId },
      select: {
        id: true,
        profile: {
          select: {
            displayName: true,
            images: {
              orderBy: [{ displayOrder: 'asc' }],
              take: 5,
            },
          },
        },
      },
    });

    return {
      roomId: room.id,
      partnerName: partner?.profile?.displayName ?? '사용자',
      partnerUserId: partner?.id ?? targetUserId,
      partnerImageUrl: this.pickProfileImageUrl(partner?.profile),
    };
  }

  async getChatRooms(userId: number) {
    const rooms = await prisma.chatRoom.findMany({
      where: {
        participants: {
          some: {
            userId,
            leftAt: null,
          },
        },
        // 메시지가 1개도 없는 방은 채팅 목록/카운트에서 제외 (실제 대화가 시작된 방만 표시)
        messages: {
          some: {},
        },
      },
      include: {
        participants: {
          where: {
            leftAt: null,
          },
          include: {
            user: {
              select: {
                id: true,
                profile: {
                  select: {
                    displayName: true,
                    images: {
                      orderBy: [{ displayOrder: 'asc' }],
                      take: 5,
                    },
                  },
                },
              },
            },
          },
        },
        messages: {
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
        },
      },
    });

    const mapped = rooms.map((room) => {
      const participants = room.participants.map((participant) => ({
        id: participant.id,
        roomId: participant.roomId,
        userId: participant.userId,
        role: participant.role,
        lastReadMessageId: participant.lastReadMessageId,
        lastReadAt: participant.lastReadAt,
        unreadCount: participant.unreadCount,
        joinedAt: participant.joinedAt,
        leftAt: participant.leftAt,
        displayName: participant.user.profile?.displayName ?? '사용자',
        imageUrl: this.pickProfileImageUrl(participant.user.profile),
      }));

      const otherUser = participants.find((p) => p.userId !== userId);
      const myParticipant = participants.find((p) => p.userId === userId);
      const lastMessage = room.messages[0] ?? null;

      return {
        id: room.id,
        roomType: room.roomType,
        name: room.name,
        status: room.status,
        startedAt: room.startedAt,
        expiresAt: room.expiresAt,
        isPremium: room.isPremium,
        createdAt: room.createdAt,
        otherUser: otherUser
          ? {
              id: otherUser.userId,
              displayName: otherUser.displayName,
              imageUrl: otherUser.imageUrl,
            }
          : null,
        lastMessage: lastMessage
          ? {
              id: lastMessage.id,
              roomId: lastMessage.roomId,
              senderId: lastMessage.senderId,
              content: lastMessage.content,
              messageType: lastMessage.messageType,
              isRead: lastMessage.isRead,
              readAt: lastMessage.readAt,
              createdAt: lastMessage.createdAt,
            }
          : null,
        unreadCount: myParticipant?.unreadCount ?? 0,
      };
    });

    mapped.sort((a, b) => {
      const aTimestamp = a.lastMessage?.createdAt ?? a.createdAt;
      const bTimestamp = b.lastMessage?.createdAt ?? b.createdAt;
      return bTimestamp.getTime() - aTimestamp.getTime();
    });

    return mapped;
  }

  async getRoomMessages(userId: number, roomId: number) {
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
    });

    if (!room) {
      throw new Error('Chat room not found');
    }

    return prisma.chatMessage.findMany({
      where: {
        roomId,
      },
      include: {
        readStatus: true,
      },
      orderBy: {
        createdAt: 'asc',
      },
    });
  }

  async markRoomRead(userId: number, roomId: number, upToMessageId?: number) {
    const participant = await prisma.chatRoomParticipant.findFirst({
      where: { roomId, userId, leftAt: null },
      select: { id: true },
    });
    if (!participant) throw new Error('Chat room not found');

    const now = new Date();
    let cutoff: Date | undefined;
    let senderFilter: number | undefined;

    if (upToMessageId) {
      const msg = await prisma.chatMessage.findUnique({
        where: { id: upToMessageId },
        select: { id: true, roomId: true, senderId: true, createdAt: true },
      });
      if (msg && msg.roomId === roomId) {
        cutoff = msg.createdAt;
        if (msg.senderId !== userId) senderFilter = msg.senderId;
      }
    }

    const unreadMessages = await prisma.chatMessage.findMany({
      where: {
        roomId,
        senderId: senderFilter ? senderFilter : { not: userId },
        isRead: false,
        ...(cutoff ? { createdAt: { lte: cutoff } } : {}),
      },
      orderBy: { createdAt: 'asc' },
      select: { id: true, createdAt: true },
    });

    if (unreadMessages.length === 0) {
      return { roomId, readAt: now, upToMessageId: upToMessageId ?? null };
    }

    await prisma.chatMessage.updateMany({
      where: { id: { in: unreadMessages.map((m) => m.id) } },
      data: { isRead: true, readAt: now },
    });

    const latestRead = unreadMessages[unreadMessages.length - 1];
    const remainingUnreadCount = await prisma.chatMessage.count({
      where: { roomId, senderId: { not: userId }, isRead: false },
    });

    await prisma.chatRoomParticipant.update({
      where: { id: participant.id },
      data: {
        lastReadMessageId: latestRead.id,
        lastReadAt: now,
        unreadCount: remainingUnreadCount,
      },
    });

    return {
      roomId,
      readAt: now,
      upToMessageId: latestRead.id,
      upToCreatedAt: latestRead.createdAt,
    };
  }

  async deleteAllMessages(userId: number, roomId: number) {
    const participant = await prisma.chatRoomParticipant.findFirst({
      where: { roomId, userId, leftAt: null },
      select: { id: true },
    });
    if (!participant) throw new Error('Chat room not found');

    await prisma.chatMessage.deleteMany({
      where: { roomId },
    });

    const now = new Date();
    await prisma.chatRoomParticipant.updateMany({
      where: { roomId, leftAt: null },
      data: {
        lastReadMessageId: null,
        lastReadAt: now,
        unreadCount: 0,
      },
    });

    return { roomId, deletedAll: true };
  }

  async deleteMessage(userId: number, messageId: number) {
    const message = await prisma.chatMessage.findUnique({
      where: { id: messageId },
      select: { id: true, roomId: true, senderId: true, isRead: true },
    });
    if (!message) throw new Error('Message not found');

    const participant = await prisma.chatRoomParticipant.findFirst({
      where: { roomId: message.roomId, userId, leftAt: null },
      select: { id: true },
    });
    if (!participant) throw new Error('Chat room not found');

    // 최소한의 권한: 발신자만 삭제 가능 (양쪽에서 사라짐)
    if (message.senderId !== userId) throw new Error('Forbidden');

    await prisma.chatMessage.delete({ where: { id: messageId } });

    // 읽지 않은 메시지를 삭제한 경우 상대방 unreadCount를 보정
    if (!message.isRead) {
      await prisma.chatRoomParticipant.updateMany({
        where: {
          roomId: message.roomId,
          leftAt: null,
          userId: { not: userId },
          unreadCount: { gt: 0 },
        },
        data: { unreadCount: { decrement: 1 } },
      });
    }

    // lastReadMessageId가 삭제된 메시지인 경우 null로 정리
    await prisma.chatRoomParticipant.updateMany({
      where: {
        roomId: message.roomId,
        leftAt: null,
        lastReadMessageId: messageId,
      },
      data: { lastReadMessageId: null },
    });

    return { messageId, deleted: true };
  }
}
