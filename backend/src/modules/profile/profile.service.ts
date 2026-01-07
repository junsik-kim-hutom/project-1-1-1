import prisma from '../../config/database';
import { Gender, Prisma } from '@prisma/client';

export interface CreateProfileDto {
  userId: number;
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
  // Additional fields
  residence?: string;
  bodyType?: string;
  marriageIntention?: string;
  childrenPlan?: string;
  marriageTiming?: string;
  dateCostSharing?: string;
  importantValue?: string;
  houseworkSharing?: string;
  charmPoint?: string;
  idealPartner?: string;
  holidayActivity?: string;
}

export class ProfileService {
  async checkProfileExists(userId: number): Promise<boolean> {
    console.log('[PROFILE_SERVICE] Checking profile for userId:', userId);
    const profile = await prisma.profile.findUnique({
      where: { userId },
    });
    const exists = !!profile;
    console.log('[PROFILE_SERVICE] Profile exists:', exists);
    return exists;
  }

  async createProfile(data: CreateProfileDto) {
    console.log('[PROFILE_SERVICE] Creating profile with data:', data);
    const existingProfile = await prisma.profile.findUnique({
      where: { userId: data.userId },
      select: { id: true },
    });
    if (existingProfile) {
      console.log('[PROFILE_SERVICE] Profile already exists, updating instead:', existingProfile.id);
      return this.updateProfile(data.userId, data);
    }

    // Calculate age from birthDate
    const birthDate = data.birthDate instanceof Date
      ? data.birthDate
      : new Date(data.birthDate);
    if (Number.isNaN(birthDate.getTime())) {
      throw new Error('Invalid birthDate');
    }
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }

    let profile;
    try {
      profile = await prisma.profile.create({
        data: {
          userId: data.userId,
          displayName: data.displayName,
          gender: data.gender,
          birthDate,
          age: age,
          height: data.height,
          occupation: data.occupation,
          education: data.education,
          income: data.income,
          smoking: data.smoking,
          drinking: data.drinking,
          bio: data.bio,
          isComplete: true,
          images: data.profileImages && data.profileImages.length > 0 ? {
            create: data.profileImages.map((url, index) => ({
              imageUrl: url,
              imageType: index === 0 ? 'MAIN' : 'SUB',
              displayOrder: index,
              isApproved: false,
            })),
          } : undefined,
        },
        include: {
          images: true,
        },
      });
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError &&
          error.code === 'P2002') {
        console.log('[PROFILE_SERVICE] Unique constraint hit, updating instead');
        return this.updateProfile(data.userId, data);
      }
      throw error;
    }

    console.log('[PROFILE_SERVICE] Profile created successfully:', profile.id);
    return profile;
  }

  async updateProfile(userId: number, data: Partial<CreateProfileDto>) {
    console.log('[PROFILE_SERVICE] Updating profile for userId:', userId);

    // Calculate age from birthDate if provided
    let age: number | undefined;
    let birthDateValue: Date | undefined;
    if (data.birthDate) {
      const parsedBirthDate = data.birthDate instanceof Date
        ? data.birthDate
        : new Date(data.birthDate);
      if (Number.isNaN(parsedBirthDate.getTime())) {
        throw new Error('Invalid birthDate');
      }
      const today = new Date();
      age = today.getFullYear() - parsedBirthDate.getFullYear();
      const monthDiff = today.getMonth() - parsedBirthDate.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < parsedBirthDate.getDate())) {
        age--;
      }
      birthDateValue = parsedBirthDate;
    }

    const profile = await prisma.profile.update({
      where: { userId },
      data: {
        displayName: data.displayName,
        gender: data.gender,
        birthDate: birthDateValue,
        age: age,
        height: data.height,
        occupation: data.occupation,
        education: data.education,
        income: data.income,
        smoking: data.smoking,
        drinking: data.drinking,
        bio: data.bio,
      },
      include: {
        images: true,
      },
    });

    // Update profile images if provided
    if (data.profileImages && data.profileImages.length > 0) {
      // Delete existing images
      await prisma.profileImage.deleteMany({
        where: { profileId: profile.id },
      });

      // Create new images
      await prisma.profileImage.createMany({
        data: data.profileImages.map((url, index) => ({
          profileId: profile.id,
          imageUrl: url,
          imageType: index === 0 ? 'MAIN' : 'SUB',
          displayOrder: index,
          isApproved: false,
        })),
      });
    }

    console.log('[PROFILE_SERVICE] Profile updated successfully');
    return profile;
  }

  async getProfile(userId: string | number) {
    const parsedUserId = typeof userId === 'string' ? parseInt(userId) : userId;
    const profile = await prisma.profile.findUnique({
      where: { userId: parsedUserId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            status: true,
            createdAt: true,
          },
        },
        images: {
          orderBy: {
            displayOrder: 'asc',
          },
        },
      },
    });

    return profile;
  }

  async deleteProfile(userId: number) {
    await prisma.profile.delete({
      where: { userId },
    });

    return { success: true };
  }
}
