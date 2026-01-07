import { Request, Response } from 'express';
import { EQTestService } from './eq-test.service';
import { EQCategory } from '@prisma/client';
import { AuthRequest } from '../../common/middleware/auth.middleware';

const eqTestService = new EQTestService();

export class EQTestController {
  private parseCategory(raw: unknown): EQCategory | undefined {
    if (typeof raw !== 'string' || raw.trim() === '') return undefined;
    const normalized = raw.trim().toUpperCase();
    if (Object.values(EQCategory).includes(normalized as EQCategory)) {
      return normalized as EQCategory;
    }
    return undefined;
  }

  // EQ 테스트 질문 조회 (활성화된 질문만)
  async getQuestions(req: Request, res: Response) {
    try {
      const { category } = req.query;
      const parsedCategory = this.parseCategory(category);
      const questions = await eqTestService.getActiveQuestions(parsedCategory);

      return res.status(200).json({
        success: true,
        data: questions,
      });
    } catch (error: any) {
      console.error('Get EQ questions error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  // 모든 EQ 테스트 질문 조회 (관리자용)
  async getAllQuestions(req: Request, res: Response) {
    try {
      const questions = await eqTestService.getAllQuestions();

      return res.status(200).json({
        success: true,
        data: questions,
      });
    } catch (error: any) {
      console.error('Get all EQ questions error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  // 답변 제출
  async submitAnswer(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      const { questionId: questionIdRaw, answer } = req.body;
      const questionId = typeof questionIdRaw === 'number' ? questionIdRaw : Number(questionIdRaw);

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });
      if (!Number.isInteger(questionId) || answer === undefined) {
        return res.status(400).json({ error: 'Question ID and answer are required' });
      }

      const result = await eqTestService.submitAnswer({
        userId,
        questionId,
        answer,
      });

      return res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      console.error('Submit EQ answer error:', error);
      if (error?.code === 'P2003' && `${error?.meta?.field_name || ''}`.includes('user_id')) {
        return res.status(401).json({ error: 'User not found' });
      }
      return res.status(500).json({ error: error.message });
    }
  }

  // 테스트 결과 계산
  async calculateResults(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });
      const result = await eqTestService.calculateResults(userId);

      return res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      console.error('Calculate EQ results error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  // 테스트 결과 조회
  async getResults(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });
      const result = await eqTestService.getResults(userId);

      return res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      console.error('Get EQ results error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  // 초기 데이터 생성 (개발용)
  async seedQuestions(req: Request, res: Response) {
    try {
      const questions = await eqTestService.seedQuestions();

      return res.status(200).json({
        success: true,
        message: `${questions.length} questions created`,
        data: questions,
      });
    } catch (error: any) {
      console.error('Seed EQ questions error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  // EQ 질문 생성 (관리자용)
  async createQuestion(req: Request, res: Response) {
    try {
      const question = await eqTestService.createQuestion(req.body);

      return res.status(201).json({
        success: true,
        data: question,
      });
    } catch (error: any) {
      console.error('Create EQ question error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  // EQ 질문 수정 (관리자용)
  async updateQuestion(req: Request, res: Response) {
    try {
      const questionId = Number(req.params.questionId);

      if (!Number.isInteger(questionId)) {
        return res.status(400).json({ error: 'Invalid question ID' });
      }

      const question = await eqTestService.updateQuestion(questionId, req.body);

      return res.status(200).json({
        success: true,
        data: question,
      });
    } catch (error: any) {
      console.error('Update EQ question error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  // EQ 질문 활성화/비활성화 (관리자용)
  async toggleQuestion(req: Request, res: Response) {
    try {
      const questionId = Number(req.params.questionId);

      if (!Number.isInteger(questionId)) {
        return res.status(400).json({ error: 'Invalid question ID' });
      }

      const question = await eqTestService.toggleQuestion(questionId);

      return res.status(200).json({
        success: true,
        data: question,
      });
    } catch (error: any) {
      console.error('Toggle EQ question error:', error);
      return res.status(500).json({ error: error.message });
    }
  }
}
