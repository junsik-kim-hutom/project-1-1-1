import { Router } from 'express';
import { ChatController } from './chat.controller';
import { authMiddleware } from '../../common/middleware/auth.middleware';

const router = Router();
const chatController = new ChatController();

router.post('/rooms/direct', authMiddleware, (req, res) =>
  chatController.createOrGetDirectRoom(req, res)
);
router.get('/rooms', authMiddleware, (req, res) => chatController.getChatRooms(req, res));
router.get('/rooms/:roomId/messages', authMiddleware, (req, res) =>
  chatController.getRoomMessages(req, res)
);
router.post('/rooms/:roomId/read', authMiddleware, (req, res) =>
  chatController.markRoomRead(req, res)
);
router.delete('/rooms/:roomId/messages', authMiddleware, (req, res) =>
  chatController.deleteAllMessages(req, res)
);
router.delete('/messages/:messageId', authMiddleware, (req, res) =>
  chatController.deleteMessage(req, res)
);

export default router;
