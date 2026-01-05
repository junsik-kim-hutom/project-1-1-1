import { Router } from 'express';
import { ProfileController } from './profile.controller';
import { authMiddleware } from '../../common/middleware/auth.middleware';
import { uploadMultiple } from '../../config/multer.config';

const router = Router();
const profileController = new ProfileController();

// 프로필 존재 여부 체크 (다른 라우트보다 먼저 정의)
router.get('/check', authMiddleware, (req, res) => profileController.checkProfile(req, res));

// 이미지 업로드 엔드포인트
router.post('/images/upload', authMiddleware, uploadMultiple, (req, res) =>
  profileController.uploadImages(req, res)
);

router.post('/', authMiddleware, (req, res) => profileController.createProfile(req, res));
router.put('/', authMiddleware, (req, res) => profileController.updateProfile(req, res));
router.get('/me', authMiddleware, (req, res) => profileController.getProfile(req, res));
router.get('/:userId', authMiddleware, (req, res) => profileController.getProfile(req, res));
router.delete('/', authMiddleware, (req, res) => profileController.deleteProfile(req, res));

export default router;
