import prisma from '../../config/database';
import { Gender } from '@prisma/client';

export interface DynamicProfileData {
  userId: string;
  displayName: string;
  gender: Gender;
  birthDate: Date;
  bio?: string;
  profileImages?: string[];
  fields: {
    [fieldKey: string]: any; // 동적 필드 값
  };
}

export class DynamicProfileService {
  async createProfile(data: DynamicProfileData) {
    const profile = await prisma.profile.create({
      data: {
        userId: data.userId,
        displayName: data.displayName,
        gender: data.gender,
        birthDate: data.birthDate,
        bio: data.bio,
        images: data.profileImages
          ? {
              create: data.profileImages.map((url, index) => ({
                imageUrl: url,
                displayOrder: index,
                imageType: 'SUB',
              })),
            }
          : undefined,
        isComplete: true,
      },
    });

    if (data.fields) {
      await this.updateProfileFields(data.userId, data.fields);
    }

    return this.getProfileWithFields(data.userId);
  }

  async updateProfile(userId: string, data: Partial<DynamicProfileData>) {
    const profile = await prisma.profile.update({
      where: { userId },
      data: {
        displayName: data.displayName,
        gender: data.gender,
        birthDate: data.birthDate,
        bio: data.bio,
        images: data.profileImages
          ? {
              deleteMany: {},
              create: data.profileImages.map((url, index) => ({
                imageUrl: url,
                displayOrder: index,
                imageType: 'SUB',
              })),
            }
          : undefined,
      },
    });

    if (data.fields) {
      await this.updateProfileFields(userId, data.fields);
    }

    return this.getProfileWithFields(userId);
  }

  async updateProfileFields(userId: string, fields: { [fieldKey: string]: any }) {
    for (const [fieldKey, value] of Object.entries(fields)) {
      const field = await prisma.profileField.findUnique({
        where: { fieldKey },
      });

      if (!field) {
        console.warn(`Field ${fieldKey} not found, skipping`);
        continue;
      }

      await prisma.userProfileValue.upsert({
        where: {
          userId_fieldId: {
            userId,
            fieldId: field.id,
          },
        },
        update: {
          value: value as any,
        },
        create: {
          userId,
          fieldId: field.id,
          value: value as any,
        },
      });
    }
  }

  async getProfileWithFields(userId: string) {
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
        profileValues: {
          include: {
            field: true,
          },
        },
      },
    });

    if (!profile) {
      throw new Error('Profile not found');
    }

    // 동적 필드를 객체로 변환
    const fields: { [key: string]: any } = {};
    profile.profileValues.forEach((pv: any) => {
      fields[pv.field.fieldKey] = pv.value;
    });

    return {
      ...profile,
      fields,
    };
  }

  async getProfile(userId: string) {
    return this.getProfileWithFields(userId);
  }

  async deleteProfile(userId: string) {
    await prisma.profile.delete({
      where: { userId },
    });

    return { success: true };
  }

  async searchProfiles(filters: {
    gender?: Gender;
    minAge?: number;
    maxAge?: number;
    fields?: { [fieldKey: string]: any };
  }) {
    const today = new Date();
    const maxBirthDate = new Date(
      today.getFullYear() - (filters.minAge || 18),
      today.getMonth(),
      today.getDate()
    );
    const minBirthDate = new Date(
      today.getFullYear() - (filters.maxAge || 100),
      today.getMonth(),
      today.getDate()
    );

    const profiles = await prisma.profile.findMany({
      where: {
        ...(filters.gender && { gender: filters.gender }),
        birthDate: {
          gte: minBirthDate,
          lte: maxBirthDate,
        },
      },
      include: {
        user: {
          select: {
            id: true,
            status: true,
          },
        },
        profileValues: {
          include: {
            field: true,
          },
        },
      },
      take: 50,
    });

    return profiles.map((profile) => {
      const fields: { [key: string]: any } = {};
      profile.profileValues.forEach((pv: any) => {
        fields[pv.field.fieldKey] = pv.value;
      });

      return {
        ...profile,
        fields,
      };
    });
  }
}
