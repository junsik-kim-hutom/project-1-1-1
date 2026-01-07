import { Router } from 'express';
import { authMiddleware } from '../../common/middleware/auth.middleware';
import { NotificationsController } from './notifications.controller';

const router = Router();
const controller = new NotificationsController();

router.get('/', authMiddleware, (req, res) => controller.list(req, res));

export default router;

