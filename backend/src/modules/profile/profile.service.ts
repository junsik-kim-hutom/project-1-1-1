import prisma from '../../config/database';
import { Gender } from '@prisma/client';

export interface CreateProfileDto {
  userId: string;
  displayName: string;
  gender: Gender;
  birthDate: Date;
  height?: number;
  occupation?: string;
  education?: string;
  income?: string;
  smoking?: string;
  drinking?: string;
  bio?: string;
  profileImages?: string[];
  interests?: string[];
}

export class ProfileService {
  async createProfile(data: CreateProfileDto) {
    const profile = await prisma.profile.create({
      data: {
        userId: data.userId,
        displayName: data.displayName,
        gender: data.gender,
        birthDate: data.birthDate,
        height: data.height,
        occupation: data.occupation,
        education: data.education,
        income: data.income,
        smoking: data.smoking,
        drinking: data.drinking,
        bio: data.bio,
        isComplete: true,
      },
    });

    return profile;
  }

  async updateProfile(userId: string, data: Partial<CreateProfileDto>) {
    const profile = await prisma.profile.update({
      where: { userId },
      data: {
        displayName: data.displayName,
        gender: data.gender,
        birthDate: data.birthDate,
        height: data.height,
        occupation: data.occupation,
        education: data.education,
        income: data.income,
        smoking: data.smoking,
        drinking: data.drinking,
        bio: data.bio,
      },
    });

    return profile;
  }

  async getProfile(userId: string) {
    const profile = await prisma.profile.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            status: true,
            createdAt: true,
          },
        },
      },
    });

    if (!profile) {
      throw new Error('Profile not found');
    }

    return profile;
  }

  async deleteProfile(userId: string) {
    await prisma.profile.delete({
      where: { userId },
    });

    return { success: true };
  }
}
