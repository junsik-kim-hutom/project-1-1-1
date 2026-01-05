import prisma from '../../config/database';

export class ChatService {
  async getChatRooms(userId: string) {
    const rooms = await prisma.chatRoom.findMany({
      where: {
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
          include: {
            user: {
              select: {
                id: true,
                profile: {
                  select: {
                    displayName: true,
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

  async getRoomMessages(userId: string, roomId: string) {
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
}
