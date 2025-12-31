/**
 * OAuth 제공자로부터 받은 프로필 정보를 통합된 형식으로 변환하기 위한 인터페이스
 */
export interface OAuthProfileDto {
  /** OAuth 제공자 고유 ID */
  providerId: string;

  /** 이메일 */
  email: string;

  /** 이메일 인증 여부 */
  emailVerified?: boolean;

  /** 이름 (선택적) */
  name?: string;

  /** 프로필 이미지 URL (선택적) */
  picture?: string;
}

/**
 * Google OAuth 응답을 OAuthProfileDto로 변환
 */
export function googleToOAuthProfile(payload: any): OAuthProfileDto {
  return {
    providerId: payload.sub,
    email: payload.email,
    emailVerified: payload.email_verified ?? false,
    name: payload.name,
    picture: payload.picture,
  };
}

/**
 * LINE OAuth 응답을 OAuthProfileDto로 변환
 */
export function lineToOAuthProfile(profile: any): OAuthProfileDto {
  return {
    providerId: profile.userId,
    email: profile.email || `${profile.userId}@line.placeholder`,
    emailVerified: false, // LINE은 이메일 인증 여부를 제공하지 않음
    name: profile.displayName,
    picture: profile.pictureUrl,
  };
}

/**
 * Yahoo OAuth 응답을 OAuthProfileDto로 변환
 */
export function yahooToOAuthProfile(profile: any): OAuthProfileDto {
  return {
    providerId: profile.sub,
    email: profile.email,
    emailVerified: profile.email_verified ?? false,
    name: profile.name,
    picture: profile.picture,
  };
}

/**
 * Kakao OAuth 응답을 OAuthProfileDto로 변환
 */
export function kakaoToOAuthProfile(profile: any): OAuthProfileDto {
  const kakaoAccount = profile.kakao_account || {};
  const kakaoProfile = kakaoAccount.profile || {};

  return {
    providerId: profile.id.toString(),
    email: kakaoAccount.email || `${profile.id}@kakao.placeholder`,
    emailVerified: kakaoAccount.is_email_verified ?? false,
    name: kakaoProfile.nickname,
    picture: kakaoProfile.profile_image_url,
  };
}

/**
 * Apple OAuth 응답을 OAuthProfileDto로 변환
 */
export function appleToOAuthProfile(payload: any): OAuthProfileDto {
  return {
    providerId: payload.sub,
    email: payload.email,
    emailVerified: payload.email_verified === 'true',
    name: payload.name,
    picture: undefined, // Apple은 프로필 이미지를 제공하지 않음
  };
}

/**
 * Facebook OAuth 응답을 OAuthProfileDto로 변환
 */
export function facebookToOAuthProfile(profile: any): OAuthProfileDto {
  return {
    providerId: profile.id,
    email: profile.email,
    emailVerified: false, // Facebook은 이메일 인증 여부를 제공하지 않음
    name: profile.name,
    picture: profile.picture?.data?.url,
  };
}
