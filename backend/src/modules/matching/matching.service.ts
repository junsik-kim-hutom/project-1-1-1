import prisma from '../../config/database';

export interface GetMatchesQuery {
  distanceKm?: number;
  limit?: number;
}

export type MatchingActionType = 'LIKE' | 'PASS' | 'SUPER_LIKE' | 'BLOCK';
export type MatchingActionDirection = 'sent' | 'received';

export interface RecordActionInput {
  userId: number;
  targetUserId: number;
  action: MatchingActionType;
  matchScore?: number;
  viewedProfile?: boolean;
  viewDuration?: number;
}

export type MatchingActivity = {
  interestSent: number;
  boostSent: number;
  interestReceived: number;
  boostReceived: number;
  ongoingChats: number;
};

export type MatchingCandidate = {
  userId: string;
  displayName: string;
  age: number | null;
  height: number | null;
  occupation: string | null;
  education: string | null;
  bio: string | null;
  locationAddress: string | null;
  distanceKm: number;
  matchScore: number;
  imageUrl: string | null;
};

export type MatchingActionUser = {
  userId: number;
  displayName: string;
  age: number | null;
  imageUrl: string | null;
  action: MatchingActionType;
  createdAt: Date;
};

export class MatchingService {
  async recordAction(input: RecordActionInput) {
    if (input.userId === input.targetUserId) {
      throw new Error('Invalid target user');
    }

    const score = this.clampInt(input.matchScore ?? 0, 0, 100);

    const previous = await prisma.matchingHistory.findUnique({
      where: {
        userId_targetUserId: { userId: input.userId, targetUserId: input.targetUserId },
      },
      select: { action: true },
    });

    // Enforce mutual blocks at write time too.
    const isBlocked = await prisma.userBlock.findFirst({
      where: {
        OR: [
          { userId: input.userId, blockedUserId: input.targetUserId },
          { userId: input.targetUserId, blockedUserId: input.userId },
        ],
      },
      select: { id: true },
    });
    if (isBlocked) throw new Error('User is blocked');

    if (input.action === 'BLOCK') {
      await prisma.userBlock.upsert({
        where: {
          userId_blockedUserId: { userId: input.userId, blockedUserId: input.targetUserId },
        },
        create: {
          userId: input.userId,
          blockedUserId: input.targetUserId,
        },
        update: {},
      });
    }

    const history = await prisma.matchingHistory.upsert({
      where: {
        userId_targetUserId: { userId: input.userId, targetUserId: input.targetUserId },
      },
      create: {
        userId: input.userId,
        targetUserId: input.targetUserId,
        matchScore: score,
        action: input.action,
        viewedProfile: input.viewedProfile ?? false,
        viewDuration: input.viewDuration ?? null,
      },
      update: {
        matchScore: score,
        action: input.action,
        viewedProfile: input.viewedProfile ?? false,
        viewDuration: input.viewDuration ?? null,
      },
    });

    await prisma.matchingActionLog.create({
      data: {
        userId: input.userId,
        targetUserId: input.targetUserId,
        action: input.action as any,
        matchScore: score,
      },
    });

    if (
      (input.action === 'LIKE' || input.action === 'SUPER_LIKE') &&
      previous?.action !== input.action
    ) {
      const type = input.action === 'LIKE' ? 'MATCH_LIKE' : 'MATCH_SUPER_LIKE';
      const actionUrl =
        input.action === 'LIKE'
          ? '/matching/actions?action=LIKE&direction=received'
          : '/matching/actions?action=SUPER_LIKE&direction=received';

      await prisma.notification.create({
        data: {
          userId: input.targetUserId,
          type: type as any,
          title: {
            ko: input.action === 'LIKE' ? '새 관심' : '새 부스트',
            ja: input.action === 'LIKE' ? '新しいいいね！' : '新しいスーパーいいね！',
            en: input.action === 'LIKE' ? 'New Like' : 'New Super Like',
          },
          message: {
            ko: input.action === 'LIKE'
              ? '누군가 회원님에게 관심을 보냈어요.'
              : '누군가 회원님에게 부스트를 보냈어요.',
            ja: input.action === 'LIKE'
              ? '誰かがあなたにいいね！を送りました。'
              : '誰かがあなたにスーパーいいね！を送りました。',
            en: input.action === 'LIKE'
              ? 'Someone liked you.'
              : 'Someone sent you a super like.',
          },
          relatedUserId: input.userId,
          relatedMatchingId: history.id,
          isPushSent: false,
          isActionable: true,
          actionUrl,
        },
      });
    }

    return history;
  }

  async getMyActivity(userId: number): Promise<MatchingActivity> {
    const [interestSent, boostSent, interestReceived, boostReceived, ongoingChats] =
      await Promise.all([
        prisma.matchingActionLog.count({ where: { userId, action: 'LIKE' } }),
        prisma.matchingActionLog.count({ where: { userId, action: 'SUPER_LIKE' } }),
        prisma.matchingActionLog.count({ where: { targetUserId: userId, action: 'LIKE' } }),
        prisma.matchingActionLog.count({ where: { targetUserId: userId, action: 'SUPER_LIKE' } }),
        prisma.chatRoom.count({
          where: {
            status: 'ACTIVE',
            participants: { some: { userId, leftAt: null } },
            // 메시지가 1개도 없는 방은 제외
            messages: { some: {} },
          },
        }),
      ]);

    return {
      interestSent,
      boostSent,
      interestReceived,
      boostReceived,
      ongoingChats,
    };
  }

  async getActionUsers(
    userId: number,
    params: {
      action: MatchingActionType;
      direction: MatchingActionDirection;
      limit?: number;
    },
  ): Promise<MatchingActionUser[]> {
    const limit = this.clampInt(params.limit ?? 50, 1, 200);
    const action = params.action;

    if (params.direction === 'sent') {
      const rows = await prisma.matchingActionLog.findMany({
        where: { userId, action },
        orderBy: { createdAt: 'desc' },
        take: limit,
        select: {
          action: true,
          createdAt: true,
          target: {
            select: {
              id: true,
              profile: {
                select: {
                  displayName: true,
                  age: true,
                  images: {
                    orderBy: [{ displayOrder: 'asc' }],
                    take: 1,
                    select: { imageUrl: true },
                  },
                },
              },
            },
          },
        },
      });

      return rows.map((row) => ({
        userId: row.target.id,
        displayName: row.target.profile?.displayName ?? '사용자',
        age: row.target.profile?.age ?? null,
        imageUrl: row.target.profile?.images?.[0]?.imageUrl ?? null,
        action: row.action as MatchingActionType,
        createdAt: row.createdAt,
      }));
    }

    const rows = await prisma.matchingActionLog.findMany({
      where: { targetUserId: userId, action },
      orderBy: { createdAt: 'desc' },
      take: limit,
      select: {
        action: true,
        createdAt: true,
        user: {
          select: {
            id: true,
            profile: {
              select: {
                displayName: true,
                age: true,
                images: {
                  orderBy: [{ displayOrder: 'asc' }],
                  take: 1,
                  select: { imageUrl: true },
                },
              },
            },
          },
        },
      },
    });

    return rows.map((row) => ({
      userId: row.user.id,
      displayName: row.user.profile?.displayName ?? '사용자',
      age: row.user.profile?.age ?? null,
      imageUrl: row.user.profile?.images?.[0]?.imageUrl ?? null,
      action: row.action as MatchingActionType,
      createdAt: row.createdAt,
    }));
  }

  async getCandidates(userId: number, query: GetMatchesQuery): Promise<MatchingCandidate[]> {
    const myProfile = await prisma.profile.findUnique({
      where: { userId },
      select: { gender: true },
    });
    const myGender = myProfile?.gender ?? null;

    const rawDistance = query.distanceKm ?? 0;
    let useDistanceLimit = rawDistance > 0;
    let distanceKm = useDistanceLimit ? this.clampInt(rawDistance, 1, 100) : 0;
    const limit = this.clampInt(query.limit ?? 20, 1, 100);
    let maxDistanceMeters = useDistanceLimit ? distanceKm * 1000 : 0;

    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    let baseArea = null;
    if (useDistanceLimit) {
      baseArea = await prisma.locationArea.findFirst({
        where: { userId },
        orderBy: [{ isPrimary: 'desc' }, { verifiedAt: 'desc' }, { createdAt: 'desc' }],
      });
      if (!baseArea) {
        useDistanceLimit = false;
        distanceKm = 0;
        maxDistanceMeters = 0;
      }
    }

    const userLat = baseArea?.latitude ?? 0;
    const userLng = baseArea?.longitude ?? 0;

    const rows = !useDistanceLimit
      ? await prisma.$queryRaw<
          Array<{
            userId: string;
            displayName: string;
            age: number | null;
            height: number | null;
            occupation: string | null;
            education: string | null;
            bio: string | null;
            locationAddress: string | null;
            distanceMeters: number | null;
            imageUrl: string | null;
          }>
        >`
          SELECT
            u.id as "userId",
            p.display_name as "displayName",
            p.age as "age",
            p.height as "height",
            p.occupation as "occupation",
            p.education as "education",
            p.bio as "bio",
            la.address as "locationAddress",
            NULL as "distanceMeters",
            (
              SELECT pi.image_url
              FROM profile_images pi
              WHERE pi.profile_id = p.id
              ORDER BY (CASE WHEN pi.image_type = 'MAIN' THEN 1 ELSE 0 END) DESC,
                       pi.display_order ASC
              LIMIT 1
            ) as "imageUrl"
          FROM users u
          INNER JOIN profiles p ON u.id = p.user_id
          LEFT JOIN (
            SELECT DISTINCT ON (user_id)
              user_id,
              latitude,
              longitude,
              address,
              verified_at
            FROM location_areas
            ORDER BY user_id, is_primary DESC, verified_at DESC
          ) la ON la.user_id = u.id
          WHERE u.id != ${userId}
            AND u.status = 'ACTIVE'
            AND p.is_complete = true
            AND (${myGender} IS NULL OR p.gender <> (${myGender}::"Gender"))
            AND NOT EXISTS (
              SELECT 1
              FROM user_blocks ub
              WHERE (ub.user_id = ${userId} AND ub.blocked_user_id = u.id)
                 OR (ub.user_id = u.id AND ub.blocked_user_id = ${userId})
            )
          ORDER BY p.updated_at DESC
          LIMIT ${limit}
        `
      : await prisma.$queryRaw<
          Array<{
            userId: string;
            displayName: string;
            age: number | null;
            height: number | null;
            occupation: string | null;
            education: string | null;
            bio: string | null;
            locationAddress: string | null;
            distanceMeters: number;
            imageUrl: string | null;
          }>
        >`
          SELECT
            u.id as "userId",
            p.display_name as "displayName",
            p.age as "age",
            p.height as "height",
            p.occupation as "occupation",
            p.education as "education",
            p.bio as "bio",
            la.address as "locationAddress",
            (
              6371000 * acos(
                cos(radians(${userLat})) * cos(radians(la.latitude)) *
                cos(radians(la.longitude) - radians(${userLng})) +
                sin(radians(${userLat})) * sin(radians(la.latitude))
              )
            ) as "distanceMeters",
            (
              SELECT pi.image_url
              FROM profile_images pi
              WHERE pi.profile_id = p.id
              ORDER BY (CASE WHEN pi.image_type = 'MAIN' THEN 1 ELSE 0 END) DESC,
                       pi.display_order ASC
              LIMIT 1
            ) as "imageUrl"
          FROM users u
          INNER JOIN profiles p ON u.id = p.user_id
          INNER JOIN (
            SELECT DISTINCT ON (user_id)
              user_id,
              latitude,
              longitude,
              address,
              verified_at
            FROM location_areas
            ORDER BY user_id, is_primary DESC, verified_at DESC
          ) la ON la.user_id = u.id
          WHERE u.id != ${userId}
            AND u.status = 'ACTIVE'
            AND p.is_complete = true
            AND (${myGender} IS NULL OR p.gender <> (${myGender}::"Gender"))
            AND la.verified_at > ${thirtyDaysAgo}
            AND (
              6371000 * acos(
                cos(radians(${userLat})) * cos(radians(la.latitude)) *
                cos(radians(la.longitude) - radians(${userLng})) +
                sin(radians(${userLat})) * sin(radians(la.latitude))
              )
            ) <= ${maxDistanceMeters}
            AND NOT EXISTS (
              SELECT 1
              FROM user_blocks ub
              WHERE (ub.user_id = ${userId} AND ub.blocked_user_id = u.id)
                 OR (ub.user_id = u.id AND ub.blocked_user_id = ${userId})
            )
          ORDER BY "distanceMeters" ASC
          LIMIT ${limit}
        `;

    return rows.map((row) => {
      const distanceKmValue = row.distanceMeters == null ? 0 : Math.max(0, row.distanceMeters / 1000);
      const matchScore = row.distanceMeters == null ? 80 : this.computeMatchScore(distanceKmValue);
      return {
        userId: row.userId,
        displayName: row.displayName,
        age: row.age,
        height: row.height,
        occupation: row.occupation,
        education: row.education,
        bio: row.bio,
        locationAddress: row.locationAddress,
        distanceKm: Math.round(distanceKmValue * 10) / 10,
        matchScore,
        imageUrl: row.imageUrl,
      };
    });
  }

  private computeMatchScore(distanceKm: number): number {
    // Lightweight heuristic until a real matching model exists.
    const score = 92 - Math.round(distanceKm * 1.2);
    return this.clampInt(score, 55, 98);
  }

  private clampInt(value: number, min: number, max: number): number {
    if (Number.isNaN(value) || !Number.isFinite(value)) return min;
    return Math.min(max, Math.max(min, Math.trunc(value)));
  }
}
