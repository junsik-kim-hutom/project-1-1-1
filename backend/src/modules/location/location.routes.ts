import { Router } from 'express';
import { LocationController } from './location.controller';
import { authMiddleware } from '../../common/middleware/auth.middleware';

const router = Router();
const locationController = new LocationController();

router.post('/areas', authMiddleware, (req, res) => locationController.createLocationArea(req, res));
router.get('/areas', authMiddleware, (req, res) => locationController.getLocationAreas(req, res));
router.put('/areas/:areaId', authMiddleware, (req, res) => locationController.updateLocationArea(req, res));
router.post('/areas/:areaId/verify', authMiddleware, (req, res) => locationController.verifyLocation(req, res));
router.delete('/areas/:areaId', authMiddleware, (req, res) => locationController.deleteLocationArea(req, res));
router.get('/nearby', authMiddleware, (req, res) => locationController.findNearbyUsers(req, res));

export default router;
