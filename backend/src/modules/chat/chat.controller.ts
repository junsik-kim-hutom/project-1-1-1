import { Response } from 'express';
import { ChatService } from './chat.service';
import { AuthRequest } from '../../common/middleware/auth.middleware';

const chatService = new ChatService();

export class ChatController {
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
      const { roomId } = req.params;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
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
}
