import { Response } from 'express';
import { LocationService } from './location.service';
import { AuthRequest } from '../../common/middleware/auth.middleware';

const locationService = new LocationService();

export class LocationController {
  async createLocationArea(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const locationArea = await locationService.createLocationArea({
        userId,
        ...req.body,
      });

      return res.status(201).json({
        success: true,
        data: locationArea,
      });
    } catch (error: any) {
      console.error('Create location area error:', error);
      return res.status(400).json({ error: error.message });
    }
  }

  async getLocationAreas(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const areas = await locationService.getLocationAreas(userId);

      return res.status(200).json({
        success: true,
        data: areas,
      });
    } catch (error) {
      console.error('Get location areas error:', error);
      return res.status(500).json({ error: 'Failed to get location areas' });
    }
  }

  async verifyLocation(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      const { areaId } = req.params;
      const { latitude, longitude } = req.body;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const updatedArea = await locationService.verifyLocation(
        areaId,
        userId,
        latitude,
        longitude
      );

      return res.status(200).json({
        success: true,
        data: updatedArea,
      });
    } catch (error: any) {
      console.error('Verify location error:', error);
      return res.status(400).json({ error: error.message });
    }
  }

  async updateLocationArea(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      const { areaId } = req.params;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const updatedArea = await locationService.updateLocationArea(
        areaId,
        userId,
        req.body
      );

      return res.status(200).json({
        success: true,
        data: updatedArea,
      });
    } catch (error: any) {
      console.error('Update location area error:', error);
      return res.status(400).json({ error: error.message });
    }
  }

  async deleteLocationArea(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;
      const { areaId } = req.params;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      await locationService.deleteLocationArea(areaId, userId);

      return res.status(200).json({
        success: true,
        message: 'Location area deleted successfully',
      });
    } catch (error: any) {
      console.error('Delete location area error:', error);
      return res.status(400).json({ error: error.message });
    }
  }

  async findNearbyUsers(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const maxDistance = parseInt(req.query.distance as string) || 10000;

      const nearbyUsers = await locationService.findNearbyUsers(userId, maxDistance);

      return res.status(200).json({
        success: true,
        data: nearbyUsers,
      });
    } catch (error: any) {
      console.error('Find nearby users error:', error);
      return res.status(400).json({ error: error.message });
    }
  }
}
