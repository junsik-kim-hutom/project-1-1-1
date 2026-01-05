import { Response } from 'express';
import { ProfileService } from './profile.service';
import { AuthRequest } from '../../common/middleware/auth.middleware';
import { Gender } from '@prisma/client';
import { getFileUrl } from '../../config/multer.config';

const profileService = new ProfileService();

export class ProfileController {
  async checkProfile(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      console.log('[PROFILE_CONTROLLER] Checking profile for userId:', userId);
      const hasProfile = await profileService.checkProfileExists(userId);
      console.log('[PROFILE_CONTROLLER] Profile exists:', hasProfile);

      return res.status(200).json({
        success: true,
        data: {
          hasProfile,
        },
      });
    } catch (error) {
      console.error('[PROFILE_CONTROLLER] Check profile error:', error);
      return res.status(500).json({ error: 'Failed to check profile' });
    }
  }

  async createProfile(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      console.log('[PROFILE_CONTROLLER] Creating profile for userId:', userId);
      console.log('[PROFILE_CONTROLLER] Request body:', req.body);

      // Validate and convert gender to enum
      const gender = req.body.gender as Gender;
      if (!Object.values(Gender).includes(gender)) {
        console.error('[PROFILE_CONTROLLER] Invalid gender value:', req.body.gender);
        return res.status(400).json({ error: 'Invalid gender value' });
      }

      const profile = await profileService.createProfile({
        userId,
        ...req.body,
        gender,
      });

      console.log('[PROFILE_CONTROLLER] Profile created successfully:', profile.id);
      return res.status(201).json({
        success: true,
        data: profile,
      });
    } catch (error) {
      console.error('[PROFILE_CONTROLLER] Create profile error:', error);
      return res.status(500).json({
        error: 'Failed to create profile',
        details: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  async updateProfile(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      console.log('[PROFILE_CONTROLLER] Updating profile for userId:', userId);
      console.log('[PROFILE_CONTROLLER] Request body:', req.body);

      // Validate gender if provided
      if (req.body.gender) {
        const gender = req.body.gender as Gender;
        if (!Object.values(Gender).includes(gender)) {
          console.error('[PROFILE_CONTROLLER] Invalid gender value:', req.body.gender);
          return res.status(400).json({ error: 'Invalid gender value' });
        }
      }

      const profile = await profileService.updateProfile(userId, req.body);

      console.log('[PROFILE_CONTROLLER] Profile updated successfully');
      return res.status(200).json({
        success: true,
        data: profile,
      });
    } catch (error) {
      console.error('[PROFILE_CONTROLLER] Update profile error:', error);
      return res.status(500).json({
        error: 'Failed to update profile',
        details: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  async getProfile(req: AuthRequest, res: Response) {
    try {
      const userId = req.params.userId || req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const profile = await profileService.getProfile(userId);

      if (!profile) {
        return res.status(404).json({ error: 'Profile not found' });
      }

      return res.status(200).json({
        success: true,
        data: profile,
      });
    } catch (error) {
      console.error('Get profile error:', error);
      return res.status(500).json({ error: 'Failed to get profile' });
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

  async uploadImages(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const files = req.files as Express.Multer.File[];

      if (!files || files.length === 0) {
        return res.status(400).json({ error: 'No files uploaded' });
      }

      // 파일 URL 생성
      const imageUrls = files.map(file => getFileUrl(file.filename, 'profile-images'));

      return res.status(200).json({
        success: true,
        data: {
          images: imageUrls,
          count: imageUrls.length,
        },
      });
    } catch (error) {
      console.error('Upload images error:', error);
      return res.status(500).json({ error: 'Failed to upload images' });
    }
  }
}
