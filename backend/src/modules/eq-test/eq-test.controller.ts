import { Request, Response } from 'express';
import { EQTestService } from './eq-test.service';
import { EQCategory } from '@prisma/client';

const eqTestService = new EQTestService();

export class EQTestController {
  // EQ 테스트 질문 조회 (활성화된 질문만)
  async getQuestions(req: Request, res: Response) {
    try {
      const { category } = req.query;
      const questions = await eqTestService.getActiveQuestions(category as EQCategory);

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
  async submitAnswer(req: Request, res: Response) {
    try {
      const userId = (req as any).user.userId;
      const { questionId, answer } = req.body;

      if (!questionId || answer === undefined) {
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
      return res.status(500).json({ error: error.message });
    }
  }

  // 테스트 결과 계산
  async calculateResults(req: Request, res: Response) {
    try {
      const userId = (req as any).user.userId;
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
  async getResults(req: Request, res: Response) {
    try {
      const userId = (req as any).user.userId;
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
      const { questionId } = req.params;
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
      const { questionId } = req.params;
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
