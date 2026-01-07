/**
 * 클라이언트로 전송되는 User 응답 DTO
 * 다양한 OAuth 제공자의 데이터를 통합된 형식으로 변환
 */
export interface UserResponseDto {
  id: number;
  email: string;
  emailVerified: boolean;
  phoneNumber: string | null;
  phoneVerified: boolean;
  authProvider: string;
  authProviderId: string;
  status: string;
  lastLoginAt: string | null;
  lastLoginIp: string | null;
  loginCount: number;
  createdAt: string;
  updatedAt: string;
  deletedAt: string | null;
}

/**
 * 로그인 응답 DTO
 */
export interface LoginResponseDto {
  user: UserResponseDto;
  accessToken: string;
  refreshToken: string;
  isNewUser: boolean;
  hasProfile: boolean;
}

/**
 * Prisma User 모델을 UserResponseDto로 변환
 */
export function toUserResponseDto(user: any): UserResponseDto {
  return {
    id: user.id,
    email: user.email,
    emailVerified: user.emailVerified ?? false,
    phoneNumber: user.phoneNumber ?? null,
    phoneVerified: user.phoneVerified ?? false,
    authProvider: user.authProvider,
    authProviderId: user.authProviderId,
    status: user.status ?? 'ACTIVE',
    lastLoginAt: user.lastLoginAt ? user.lastLoginAt.toISOString() : null,
    lastLoginIp: user.lastLoginIp ?? null,
    loginCount: user.loginCount ?? 0,
    createdAt: user.createdAt.toISOString(),
    updatedAt: user.updatedAt.toISOString(),
    deletedAt: user.deletedAt ? user.deletedAt.toISOString() : null,
  };
}
