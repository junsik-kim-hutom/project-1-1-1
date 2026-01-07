import { Request, Response } from 'express';
import { BalanceGameService } from './balance-game.service';
import { AuthRequest } from '../../common/middleware/auth.middleware';

const balanceGameService = new BalanceGameService();

export class BalanceGameController {
  async createBalanceGame(req: Request, res: Response) {
    try {
      const game = await balanceGameService.createBalanceGame(req.body);

      return res.status(201).json({
        success: true,
        data: game,
      });
    } catch (error) {
      console.error('Create balance game error:', error);
      return res.status(500).json({ error: 'Failed to create balance game' });
    }
  }

  async getBalanceGames(req: Request, res: Response) {
    try {
      const random = req.query.random === 'true';
      const limit = parseInt(req.query.limit as string) || 20;

      const games = random
        ? await balanceGameService.getRandomBalanceGames(limit)
        : await balanceGameService.getActiveBalanceGames(limit);

      return res.status(200).json({
        success: true,
        data: games,
      });
    } catch (error) {
      console.error('Get balance games error:', error);
      return res.status(500).json({ error: 'Failed to get balance games' });
    }
  }

  async submitAnswer(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const { gameId: gameIdRaw, selectedOption } = req.body;
      const gameId = typeof gameIdRaw === 'number' ? gameIdRaw : Number(gameIdRaw);

      if (!Number.isInteger(gameId)) {
        return res.status(400).json({ error: 'Invalid game ID' });
      }

      if (!['A', 'B'].includes(selectedOption)) {
        return res.status(400).json({ error: 'Invalid option' });
      }

      const answer = await balanceGameService.submitAnswer(
        userId,
        gameId,
        selectedOption
      );

      return res.status(200).json({
        success: true,
        data: answer,
      });
    } catch (error) {
      console.error('Submit answer error:', error);
      return res.status(500).json({ error: 'Failed to submit answer' });
    }
  }

  async getUserAnswers(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const answers = await balanceGameService.getUserAnswers(userId);

      return res.status(200).json({
        success: true,
        data: answers,
      });
    } catch (error) {
      console.error('Get user answers error:', error);
      return res.status(500).json({ error: 'Failed to get user answers' });
    }
  }

  async calculateCompatibility(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      const targetUserId = parseInt(req.params.targetUserId);

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      if (isNaN(targetUserId)) {
        return res.status(400).json({ error: 'Invalid target user ID' });
      }

      const result = await balanceGameService.calculateCompatibility(
        userId,
        targetUserId
      );

      return res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      console.error('Calculate compatibility error:', error);
      return res.status(500).json({ error: 'Failed to calculate compatibility' });
    }
  }
}
