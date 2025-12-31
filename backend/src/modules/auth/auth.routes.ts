import { Router } from 'express';
import { AuthController } from './auth.controller';
import { authMiddleware } from '../../common/middleware/auth.middleware';

const router = Router();
const authController = new AuthController();

router.post('/google', (req, res) => authController.googleLogin(req, res));
router.post('/refresh', (req, res) => authController.refreshToken(req, res));
router.post('/logout', authMiddleware, (req, res) => authController.logout(req, res));

export default router;
