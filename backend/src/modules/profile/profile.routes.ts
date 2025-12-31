import { Router } from 'express';
import { ProfileController } from './profile.controller';
import { authMiddleware } from '../../common/middleware/auth.middleware';

const router = Router();
const profileController = new ProfileController();

router.post('/', authMiddleware, (req, res) => profileController.createProfile(req, res));
router.put('/', authMiddleware, (req, res) => profileController.updateProfile(req, res));
router.get('/me', authMiddleware, (req, res) => profileController.getProfile(req, res));
router.get('/:userId', authMiddleware, (req, res) => profileController.getProfile(req, res));
router.delete('/', authMiddleware, (req, res) => profileController.deleteProfile(req, res));

export default router;
