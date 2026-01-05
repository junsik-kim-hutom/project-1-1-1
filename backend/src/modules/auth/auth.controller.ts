import { Request, Response } from 'express';
import { AuthService } from './auth.service';

const authService = new AuthService();

export class AuthController {
  async googleLogin(req: Request, res: Response) {
    try {
      console.log('[CONTROLLER] Google login request received');
      const { idToken } = req.body;

      if (!idToken) {
        return res.status(400).json({ error: 'ID token is required' });
      }

      const result = await authService.authenticateWithGoogle(idToken);

      console.log('[CONTROLLER] AuthService result:', JSON.stringify({
        isNewUser: result.isNewUser,
        hasProfile: result.hasProfile,
        userId: result.user.id,
      }));

      const response = {
        success: true,
        data: result,
      };

      console.log('[CONTROLLER] Sending response with hasProfile:', result.hasProfile);

      return res.status(200).json(response);
    } catch (error) {
      console.error('[CONTROLLER] Google login error:', error);
      return res.status(401).json({ error: 'Authentication failed' });
    }
  }

  async refreshToken(req: Request, res: Response) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({ error: 'Refresh token is required' });
      }

      const result = await authService.refreshAccessToken(refreshToken);

      return res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }
  }

  async logout(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      await authService.logout(userId);

      return res.status(200).json({
        success: true,
        message: 'Logged out successfully',
      });
    } catch (error) {
      return res.status(500).json({ error: 'Logout failed' });
    }
  }
}
