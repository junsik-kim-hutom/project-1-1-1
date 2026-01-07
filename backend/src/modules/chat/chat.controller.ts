import { Response } from 'express';
import { ChatService } from './chat.service';
import { AuthRequest } from '../../common/middleware/auth.middleware';

const chatService = new ChatService();

export class ChatController {
  async createOrGetDirectRoom(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const targetUserId = Number(req.body?.targetUserId);
      const initialMessage = req.body?.initialMessage?.toString();
      if (!targetUserId || isNaN(targetUserId)) return res.status(400).json({ error: 'targetUserId is required' });

      const room = await chatService.createOrGetDirectRoom(userId, targetUserId, initialMessage);
      return res.status(200).json({ success: true, data: room });
    } catch (error: any) {
      console.error('Create or get direct room error:', error);
      return res.status(400).json({ error: error.message ?? 'Failed to create chat room' });
    }
  }

  async getChatRooms(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const rooms = await chatService.getChatRooms(userId);

      return res.status(200).json({
        success: true,
        data: rooms,
      });
    } catch (error) {
      console.error('Get chat rooms error:', error);
      return res.status(500).json({ error: 'Failed to get chat rooms' });
    }
  }

  async getRoomMessages(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      const roomId = Number(req.params.roomId);

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      if (isNaN(roomId)) {
        return res.status(400).json({ error: 'Invalid roomId' });
      }

      const messages = await chatService.getRoomMessages(userId, roomId);

      return res.status(200).json({
        success: true,
        data: messages,
      });
    } catch (error: any) {
      console.error('Get room messages error:', error);
      return res.status(404).json({ error: error.message ?? 'Failed to get messages' });
    }
  }

  async markRoomRead(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      const roomId = Number(req.params.roomId);
      const upToMessageId = req.body?.upToMessageId ? Number(req.body.upToMessageId) : undefined;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      if (isNaN(roomId)) {
        return res.status(400).json({ error: 'Invalid roomId' });
      }

      const result = await chatService.markRoomRead(userId, roomId, upToMessageId);
      return res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      console.error('Mark room read error:', error);
      return res.status(400).json({ error: error.message ?? 'Failed to mark read' });
    }
  }

  async deleteAllMessages(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      const roomId = Number(req.params.roomId);

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      if (isNaN(roomId)) {
        return res.status(400).json({ error: 'Invalid roomId' });
      }

      const result = await chatService.deleteAllMessages(userId, roomId);
      return res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      console.error('Delete all messages error:', error);
      return res.status(400).json({ error: error.message ?? 'Failed to delete messages' });
    }
  }

  async deleteMessage(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      const messageId = Number(req.params.messageId);

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      if (isNaN(messageId)) {
        return res.status(400).json({ error: 'Invalid messageId' });
      }

      const result = await chatService.deleteMessage(userId, messageId);
      return res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      console.error('Delete message error:', error);
      const status = error.message === 'Forbidden' ? 403 : 400;
      return res.status(status).json({ error: error.message ?? 'Failed to delete message' });
    }
  }
}
