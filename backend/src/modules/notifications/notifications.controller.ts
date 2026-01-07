import { Response } from 'express';
import { AuthRequest } from '../../common/middleware/auth.middleware';
import { NotificationsService } from './notifications.service';

const notificationsService = new NotificationsService();

export class NotificationsController {
  async list(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const typesParam = (req.query.types ?? '').toString().trim();
      const limit = req.query.limit != null ? Number(req.query.limit) : undefined;
      const types =
        typesParam.length > 0
          ? typesParam
              .split(',')
              .map((t) => t.trim())
              .filter(Boolean)
          : undefined;

      const notifications = await notificationsService.listNotifications(userId, { types, limit });
      return res.status(200).json({ success: true, data: notifications });
    } catch (error: any) {
      console.error('List notifications error:', error);
      return res.status(400).json({ error: error.message ?? 'Failed to list notifications' });
    }
  }
}

