import prisma from '../../config/database';
import { NotificationType } from '@prisma/client';

export class NotificationsService {
  async listNotifications(
    userId: number,
    params: {
      types?: string[];
      limit?: number;
    },
  ) {
    const limit = this.clampInt(params.limit ?? 50, 1, 200);
    const types = (params.types ?? []).map((t) => t.trim()).filter(Boolean);

    if (types.length > 0) {
      const allowed = new Set<string>(Object.values(NotificationType));
      const invalid = types.filter((t) => !allowed.has(t));
      if (invalid.length > 0) {
        throw new Error(`Invalid notification type: ${invalid[0]}`);
      }
    }

    const notifications = await prisma.notification.findMany({
      where: {
        userId,
        ...(types.length > 0 ? { type: { in: types as any } } : {}),
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });

    return notifications;
  }

  private clampInt(value: number, min: number, max: number): number {
    if (Number.isNaN(value) || !Number.isFinite(value)) return min;
    return Math.min(max, Math.max(min, Math.trunc(value)));
  }
}
