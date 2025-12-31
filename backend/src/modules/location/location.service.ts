import prisma from '../../config/database';

export interface CreateLocationAreaDto {
  userId: string;
  latitude: number;
  longitude: number;
  address: string;
  radius: number;
  isPrimary: boolean;
}

export class LocationService {
  async createLocationArea(data: CreateLocationAreaDto) {
    const userAreas = await prisma.locationArea.count({
      where: { userId: data.userId },
    });

    if (userAreas >= 2) {
      throw new Error('Maximum 2 location areas allowed');
    }

    if (![10000, 20000, 30000, 40000].includes(data.radius)) {
      throw new Error('Radius must be 10000, 20000, 30000, or 40000 meters');
    }

    const locationArea = await prisma.locationArea.create({
      data: {
        userId: data.userId,
        latitude: data.latitude,
        longitude: data.longitude,
        address: data.address,
        radius: data.radius,
        isPrimary: data.isPrimary,
        verifiedAt: new Date(),
      },
    });

    return locationArea;
  }

  async getLocationAreas(userId: string) {
    const areas = await prisma.locationArea.findMany({
      where: { userId },
      orderBy: [
        { isPrimary: 'desc' },
        { createdAt: 'desc' },
      ],
    });

    return areas;
  }

  async verifyLocation(areaId: string, userId: string, latitude: number, longitude: number) {
    const area = await prisma.locationArea.findFirst({
      where: {
        id: areaId,
        userId,
      },
    });

    if (!area) {
      throw new Error('Location area not found');
    }

    const distance = this.calculateDistance(
      area.latitude,
      area.longitude,
      latitude,
      longitude
    );

    if (distance > area.radius) {
      throw new Error('Current location is too far from saved location');
    }

    const updatedArea = await prisma.locationArea.update({
      where: { id: areaId },
      data: { verifiedAt: new Date() },
    });

    return updatedArea;
  }

  async updateLocationArea(areaId: string, userId: string, data: Partial<CreateLocationAreaDto>) {
    const area = await prisma.locationArea.findFirst({
      where: {
        id: areaId,
        userId,
      },
    });

    if (!area) {
      throw new Error('Location area not found');
    }

    const updatedArea = await prisma.locationArea.update({
      where: { id: areaId },
      data: {
        latitude: data.latitude,
        longitude: data.longitude,
        address: data.address,
        radius: data.radius,
        isPrimary: data.isPrimary,
        verifiedAt: new Date(),
      },
    });

    return updatedArea;
  }

  async deleteLocationArea(areaId: string, userId: string) {
    const area = await prisma.locationArea.findFirst({
      where: {
        id: areaId,
        userId,
      },
    });

    if (!area) {
      throw new Error('Location area not found');
    }

    await prisma.locationArea.delete({
      where: { id: areaId },
    });

    return { success: true };
  }

  async findNearbyUsers(userId: string, maxDistance: number = 10000) {
    const userAreas = await prisma.locationArea.findMany({
      where: { userId },
    });

    if (userAreas.length === 0) {
      throw new Error('No location areas set');
    }

    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const userLat = userAreas[0].latitude;
    const userLng = userAreas[0].longitude;

    // Using Haversine formula to calculate distance in PostgreSQL
    const nearbyUsers = await prisma.$queryRaw<any[]>`
      SELECT DISTINCT
        u.id,
        u.email,
        p.display_name,
        p.gender,
        p.birth_date,
        la.latitude,
        la.longitude,
        (
          6371000 * acos(
            cos(radians(${userLat})) * cos(radians(la.latitude)) *
            cos(radians(la.longitude) - radians(${userLng})) +
            sin(radians(${userLat})) * sin(radians(la.latitude))
          )
        ) as distance
      FROM users u
      INNER JOIN profiles p ON u.id = p.user_id
      INNER JOIN location_areas la ON u.id = la.user_id
      WHERE u.id != ${userId}
        AND u.status = 'ACTIVE'
        AND la.verified_at > ${thirtyDaysAgo}
        AND (
          6371000 * acos(
            cos(radians(${userLat})) * cos(radians(la.latitude)) *
            cos(radians(la.longitude) - radians(${userLng})) +
            sin(radians(${userLat})) * sin(radians(la.latitude))
          )
        ) <= ${maxDistance}
      ORDER BY distance
      LIMIT 50
    `;

    return nearbyUsers;
  }

  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371e3; // Earth radius in meters
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const a =
      Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // Distance in meters
  }
}
