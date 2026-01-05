import { Router } from 'express';
import { ChatController } from './chat.controller';
import { authMiddleware } from '../../common/middleware/auth.middleware';

const router = Router();
const chatController = new ChatController();

router.get('/rooms', authMiddleware, (req, res) => chatController.getChatRooms(req, res));
router.get('/rooms/:roomId/messages', authMiddleware, (req, res) =>
  chatController.getRoomMessages(req, res)
);

export default router;
