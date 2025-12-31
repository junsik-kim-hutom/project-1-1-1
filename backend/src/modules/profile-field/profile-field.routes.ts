import { Router } from 'express';
import { ProfileFieldController } from './profile-field.controller';
import { authMiddleware } from '../../common/middleware/auth.middleware';

const router = Router();
const profileFieldController = new ProfileFieldController();

// 공개 API - 활성 필드 조회
router.get('/active', (req, res) => profileFieldController.getActiveFields(req, res));

// 관리자 API (인증 필요)
router.post('/', authMiddleware, (req, res) => profileFieldController.createField(req, res));
router.get('/', authMiddleware, (req, res) => profileFieldController.getAllFields(req, res));
router.put('/:fieldId', authMiddleware, (req, res) => profileFieldController.updateField(req, res));
router.patch('/:fieldId/toggle', authMiddleware, (req, res) => profileFieldController.toggleField(req, res));

// 초기 데이터 생성 (개발용)
router.post('/seed', (req, res) => profileFieldController.seedFields(req, res));

export default router;
