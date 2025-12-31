import { Request, Response } from 'express';
import { ProfileFieldService } from './profile-field.service';
import { ProfileFieldCategory } from '@prisma/client';

const profileFieldService = new ProfileFieldService();

export class ProfileFieldController {
  async createField(req: Request, res: Response) {
    try {
      const field = await profileFieldService.createField(req.body);

      return res.status(201).json({
        success: true,
        data: field,
      });
    } catch (error: any) {
      console.error('Create profile field error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  async getActiveFields(req: Request, res: Response) {
    try {
      const { category } = req.query;
      const fields = await profileFieldService.getActiveFields(category as ProfileFieldCategory);

      return res.status(200).json({
        success: true,
        data: fields,
      });
    } catch (error) {
      console.error('Get active fields error:', error);
      return res.status(500).json({ error: 'Failed to get fields' });
    }
  }

  async getAllFields(req: Request, res: Response) {
    try {
      const fields = await profileFieldService.getAllFields();

      return res.status(200).json({
        success: true,
        data: fields,
      });
    } catch (error) {
      console.error('Get all fields error:', error);
      return res.status(500).json({ error: 'Failed to get fields' });
    }
  }

  async updateField(req: Request, res: Response) {
    try {
      const { fieldId } = req.params;
      const field = await profileFieldService.updateField(fieldId, req.body);

      return res.status(200).json({
        success: true,
        data: field,
      });
    } catch (error: any) {
      console.error('Update profile field error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  async toggleField(req: Request, res: Response) {
    try {
      const { fieldId } = req.params;
      const field = await profileFieldService.toggleField(fieldId);

      return res.status(200).json({
        success: true,
        data: field,
      });
    } catch (error: any) {
      console.error('Toggle profile field error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  async seedFields(req: Request, res: Response) {
    try {
      const fields = await profileFieldService.seedFields();

      return res.status(200).json({
        success: true,
        message: `${fields.length} fields created`,
        data: fields,
      });
    } catch (error: any) {
      console.error('Seed fields error:', error);
      return res.status(500).json({ error: error.message });
    }
  }
}
