import { Router } from 'express';
import { EQTestController } from './eq-test.controller';
import { authMiddleware } from '../../common/middleware/auth.middleware';

const router = Router();
const eqTestController = new EQTestController();

// 공개 API - 활성 질문 조회
router.get('/questions', (req, res) => eqTestController.getQuestions(req, res));

// 사용자 API (인증 필요)
router.post('/answers', authMiddleware, (req, res) => eqTestController.submitAnswer(req, res));
router.post('/results/calculate', authMiddleware, (req, res) => eqTestController.calculateResults(req, res));
router.get('/results', authMiddleware, (req, res) => eqTestController.getResults(req, res));

// 관리자 API (인증 필요)
router.post('/questions', authMiddleware, (req, res) => eqTestController.createQuestion(req, res));
router.get('/questions/all', authMiddleware, (req, res) => eqTestController.getAllQuestions(req, res));
router.put('/questions/:questionId', authMiddleware, (req, res) => eqTestController.updateQuestion(req, res));
router.patch('/questions/:questionId/toggle', authMiddleware, (req, res) => eqTestController.toggleQuestion(req, res));

// 초기 데이터 생성 (개발용)
router.post('/seed', (req, res) => eqTestController.seedQuestions(req, res));

export default router;
