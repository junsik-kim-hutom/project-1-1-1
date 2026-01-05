import { OAuth2Client } from 'google-auth-library';
import prisma from '../../config/database';
import { generateAccessToken, generateRefreshToken } from '../../common/utils/jwt';
import {
  LoginResponseDto,
  toUserResponseDto,
} from './dto/user-response.dto';
import {
  OAuthProfileDto,
  googleToOAuthProfile,
  lineToOAuthProfile,
  yahooToOAuthProfile,
  kakaoToOAuthProfile,
  appleToOAuthProfile,
  facebookToOAuthProfile,
} from './dto/oauth-profile.dto';

export class AuthService {
  private googleClient: OAuth2Client;

  constructor() {
    this.googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
  }

  async authenticateWithGoogle(idToken: string): Promise<LoginResponseDto> {
    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID,
      });

      const payload = ticket.getPayload();
      if (!payload || !payload.email) {
        throw new Error('Invalid Google token');
      }

      // Google 응답을 통합 형식으로 변환
      const oauthProfile = googleToOAuthProfile(payload);

      // 통합된 OAuth 프로필로 사용자 인증 처리
      return await this.authenticateWithOAuth('GOOGLE', oauthProfile);
    } catch (error) {
      throw new Error('Google authentication failed');
    }
  }

  /**
   * 통합된 OAuth 인증 로직
   * 모든 OAuth 제공자가 이 메서드를 사용
   */
  private async authenticateWithOAuth(
    provider: 'GOOGLE' | 'LINE' | 'YAHOO' | 'KAKAO' | 'APPLE' | 'FACEBOOK',
    oauthProfile: OAuthProfileDto
  ): Promise<LoginResponseDto> {
    let user = await prisma.user.findFirst({
      where: {
        authProvider: provider,
        authProviderId: oauthProfile.providerId,
      },
    });

    let isNewUser = false;

    if (!user) {
      // 신규 사용자 생성
      user = await prisma.user.create({
        data: {
          email: oauthProfile.email,
          emailVerified: oauthProfile.emailVerified ?? false,
          authProvider: provider,
          authProviderId: oauthProfile.providerId,
          lastLoginAt: new Date(),
          loginCount: 1,
        },
      });
      isNewUser = true;
    } else {
      // 기존 사용자 로그인 정보 업데이트
      user = await prisma.user.update({
        where: { id: user.id },
        data: {
          lastLoginAt: new Date(),
          loginCount: { increment: 1 },
        },
      });
    }

    // 프로필 존재 여부 확인
    console.log('[AUTH] Checking profile for userId:', user.id);
    const profile = await prisma.profile.findUnique({
      where: { userId: user.id },
    });
    console.log('[AUTH] Profile query result:', profile ? 'Profile found' : 'Profile NOT found');
    console.log('[AUTH] Profile data:', JSON.stringify(profile, null, 2));

    const hasProfile = !!profile;
    console.log('[AUTH] hasProfile value:', hasProfile);

    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
    });

    const refreshToken = generateRefreshToken({
      userId: user.id,
      email: user.email,
    });

    const response = {
      user: toUserResponseDto(user),
      accessToken,
      refreshToken,
      isNewUser,
      hasProfile,
    };

    console.log('[AUTH] Final response - isNewUser:', isNewUser, 'hasProfile:', hasProfile);

    // DTO로 변환하여 반환
    return response;
  }

  /**
   * LINE 로그인
   * TODO: LINE SDK 설정 후 구현
   */
  async authenticateWithLine(accessToken: string): Promise<LoginResponseDto> {
    try {
      // LINE API를 사용하여 사용자 정보 조회
      // const profile = await lineClient.getProfile(accessToken);
      // const oauthProfile = lineToOAuthProfile(profile);
      // return await this.authenticateWithOAuth('LINE', oauthProfile);
      throw new Error('LINE login not yet implemented');
    } catch (error) {
      throw new Error('LINE authentication failed');
    }
  }

  /**
   * Yahoo 로그인
   * TODO: Yahoo SDK 설정 후 구현
   */
  async authenticateWithYahoo(idToken: string): Promise<LoginResponseDto> {
    try {
      // Yahoo OAuth2 검증
      // const profile = await yahooClient.verify(idToken);
      // const oauthProfile = yahooToOAuthProfile(profile);
      // return await this.authenticateWithOAuth('YAHOO', oauthProfile);
      throw new Error('Yahoo login not yet implemented');
    } catch (error) {
      throw new Error('Yahoo authentication failed');
    }
  }

  /**
   * Kakao 로그인
   * TODO: Kakao SDK 설정 후 구현
   */
  async authenticateWithKakao(accessToken: string): Promise<LoginResponseDto> {
    try {
      // Kakao API를 사용하여 사용자 정보 조회
      // const profile = await kakaoClient.getProfile(accessToken);
      // const oauthProfile = kakaoToOAuthProfile(profile);
      // return await this.authenticateWithOAuth('KAKAO', oauthProfile);
      throw new Error('Kakao login not yet implemented');
    } catch (error) {
      throw new Error('Kakao authentication failed');
    }
  }

  /**
   * Apple 로그인
   * TODO: Apple SDK 설정 후 구현
   */
  async authenticateWithApple(idToken: string): Promise<LoginResponseDto> {
    try {
      // Apple ID token 검증
      // const payload = await appleClient.verify(idToken);
      // const oauthProfile = appleToOAuthProfile(payload);
      // return await this.authenticateWithOAuth('APPLE', oauthProfile);
      throw new Error('Apple login not yet implemented');
    } catch (error) {
      throw new Error('Apple authentication failed');
    }
  }

  /**
   * Facebook 로그인
   * TODO: Facebook SDK 설정 후 구현
   */
  async authenticateWithFacebook(accessToken: string): Promise<LoginResponseDto> {
    try {
      // Facebook API를 사용하여 사용자 정보 조회
      // const profile = await facebookClient.getProfile(accessToken);
      // const oauthProfile = facebookToOAuthProfile(profile);
      // return await this.authenticateWithOAuth('FACEBOOK', oauthProfile);
      throw new Error('Facebook login not yet implemented');
    } catch (error) {
      throw new Error('Facebook authentication failed');
    }
  }

  async refreshAccessToken(refreshToken: string) {
    try {
      const { verifyRefreshToken } = await import('../../common/utils/jwt');
      const decoded = verifyRefreshToken(refreshToken);

      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
      });

      if (!user) {
        throw new Error('User not found');
      }

      const accessToken = generateAccessToken({
        userId: user.id,
        email: user.email,
      });

      return { accessToken };
    } catch (error) {
      throw new Error('Invalid refresh token');
    }
  }

  async logout(userId: string) {
    // Redis에서 세션 정보 삭제 등의 로직 추가 가능
    return { success: true };
  }
}
