import { Response } from 'express';
import { AuthRequest } from '../../common/middleware/auth.middleware';
import { MatchingService } from './matching.service';

const matchingService = new MatchingService();

export class MatchingController {
  async recordAction(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const rawTargetUserId = req.body?.targetUserId;
      const targetUserId = Number(rawTargetUserId);
      const action = (req.body?.action ?? '').toString();
      const matchScore = req.body?.matchScore != null ? Number(req.body.matchScore) : undefined;

      if (!Number.isInteger(targetUserId) || targetUserId <= 0) {
        return res.status(400).json({ error: 'targetUserId is required' });
      }
      if (!action) return res.status(400).json({ error: 'action is required' });
      if (!['LIKE', 'PASS', 'SUPER_LIKE', 'BLOCK'].includes(action)) {
        return res.status(400).json({ error: 'Invalid action' });
      }

      const saved = await matchingService.recordAction({
        userId,
        targetUserId,
        action: action as any,
        matchScore,
      });

      return res.status(200).json({ success: true, data: saved });
    } catch (error: any) {
      console.error('Record matching action error:', error);
      return res.status(400).json({ error: error.message ?? 'Failed to record matching action' });
    }
  }

  async getMyActivity(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const data = await matchingService.getMyActivity(userId);
      return res.status(200).json({ success: true, data });
    } catch (error: any) {
      console.error('Get matching activity error:', error);
      return res.status(500).json({ error: error.message ?? 'Failed to get matching activity' });
    }
  }

  async getCandidates(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const distanceKm = req.query.distanceKm ? Number(req.query.distanceKm) : undefined;
      const limit = req.query.limit ? Number(req.query.limit) : undefined;

      const candidates = await matchingService.getCandidates(userId, { distanceKm, limit });
      return res.status(200).json({ success: true, data: candidates });
    } catch (error: any) {
      console.error('Get matching candidates error:', error);
      return res.status(400).json({ error: error.message ?? 'Failed to get matching candidates' });
    }
  }

  async getActionUsers(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const action = (req.query.action ?? '').toString();
      const direction = (req.query.direction ?? 'sent').toString();
      const limit = req.query.limit != null ? Number(req.query.limit) : undefined;

      if (!['LIKE', 'PASS', 'SUPER_LIKE', 'BLOCK'].includes(action)) {
        return res.status(400).json({ error: 'Invalid action' });
      }
      if (!['sent', 'received'].includes(direction)) {
        return res.status(400).json({ error: 'Invalid direction' });
      }

      const data = await matchingService.getActionUsers(userId, {
        action: action as any,
        direction: direction as any,
        limit,
      });

      return res.status(200).json({ success: true, data });
    } catch (error: any) {
      console.error('Get matching action users error:', error);
      return res.status(400).json({ error: error.message ?? 'Failed to get action users' });
    }
  }

  async cancelAction(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const rawTargetUserId = req.body?.targetUserId;
      const targetUserId = Number(rawTargetUserId);

      if (!Number.isInteger(targetUserId) || targetUserId <= 0) {
        return res.status(400).json({ error: 'targetUserId is required' });
      }

      await matchingService.cancelAction(userId, targetUserId);

      return res.status(200).json({ success: true });
    } catch (error: any) {
      console.error('Cancel matching action error:', error);
      return res.status(400).json({ error: error.message ?? 'Failed to cancel action' });
    }
  }
}
