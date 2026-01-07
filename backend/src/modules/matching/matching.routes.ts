import { Router } from 'express';
import { authMiddleware } from '../../common/middleware/auth.middleware';
import { MatchingController } from './matching.controller';

const router = Router();
const controller = new MatchingController();

router.get('/', authMiddleware, (req, res) => controller.getCandidates(req, res));
router.get('/activity', authMiddleware, (req, res) => controller.getMyActivity(req, res));
router.get('/actions', authMiddleware, (req, res) => controller.getActionUsers(req, res));
router.post('/action', authMiddleware, (req, res) => controller.recordAction(req, res));

export default router;
