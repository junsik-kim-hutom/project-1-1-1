import { Response } from 'express';
import { ProfileService } from './profile.service';
import { AuthRequest } from '../../common/middleware/auth.middleware';
import { Gender } from '@prisma/client';

const profileService = new ProfileService();

export class ProfileController {
  async createProfile(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      // Validate and convert gender to enum
      const gender = req.body.gender as Gender;
      if (!Object.values(Gender).includes(gender)) {
        return res.status(400).json({ error: 'Invalid gender value' });
      }

      const profile = await profileService.createProfile({
        userId,
        ...req.body,
        gender,
      });

      return res.status(201).json({
        success: true,
        data: profile,
      });
    } catch (error) {
      console.error('Create profile error:', error);
      return res.status(500).json({ error: 'Failed to create profile' });
    }
  }

  async updateProfile(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      // Validate gender if provided
      if (req.body.gender) {
        const gender = req.body.gender as Gender;
        if (!Object.values(Gender).includes(gender)) {
          return res.status(400).json({ error: 'Invalid gender value' });
        }
      }

      const profile = await profileService.updateProfile(userId, req.body);

      return res.status(200).json({
        success: true,
        data: profile,
      });
    } catch (error) {
      console.error('Update profile error:', error);
      return res.status(500).json({ error: 'Failed to update profile' });
    }
  }

  async getProfile(req: AuthRequest, res: Response) {
    try {
      const userId = req.params.userId || req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const profile = await profileService.getProfile(userId);

      return res.status(200).json({
        success: true,
        data: profile,
      });
    } catch (error) {
      console.error('Get profile error:', error);
      return res.status(404).json({ error: 'Profile not found' });
    }
  }

  async deleteProfile(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      await profileService.deleteProfile(userId);

      return res.status(200).json({
        success: true,
        message: 'Profile deleted successfully',
      });
    } catch (error) {
      console.error('Delete profile error:', error);
      return res.status(500).json({ error: 'Failed to delete profile' });
    }
  }
}
