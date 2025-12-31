import { Router } from 'express';
import { BalanceGameController } from './balance-game.controller';
import { authMiddleware } from '../../common/middleware/auth.middleware';

const router = Router();
const balanceGameController = new BalanceGameController();

router.post('/', (req, res) => balanceGameController.createBalanceGame(req, res));
router.get('/', (req, res) => balanceGameController.getBalanceGames(req, res));
router.post('/answers', authMiddleware, (req, res) => balanceGameController.submitAnswer(req, res));
router.get('/answers/me', authMiddleware, (req, res) => balanceGameController.getUserAnswers(req, res));
router.get('/compatibility/:targetUserId', authMiddleware, (req, res) => balanceGameController.calculateCompatibility(req, res));

export default router;
