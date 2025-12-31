# OAuth 인증 아키텍처

## 설계 원칙

### 문제점
각 OAuth 제공자(Google, LINE, Yahoo, Kakao, Apple, Facebook)는 서로 다른 데이터 형식을 반환합니다:
- Google: `sub`, `email_verified`
- LINE: `userId`, `displayName` (이메일 선택적)
- Kakao: `id`, `kakao_account.email`
- Apple: `sub`, `email` (이름 선택적)

이로 인해 각 제공자마다 다른 처리 로직이 필요하고, User 스키마 변경 시 모든 제공자 코드를 수정해야 하는 문제가 발생합니다.

### 해결 방법: DTO 패턴

**DTO (Data Transfer Object)** 패턴을 사용하여 각 OAuth 제공자의 응답을 통합된 형식으로 변환합니다.

```
OAuth 제공자 → 변환 함수 → OAuthProfileDto → 통합 인증 로직 → UserResponseDto → 클라이언트
```

## 아키텍처 구조

### 1. OAuthProfileDto (입력 통합)

**파일**: `src/modules/auth/dto/oauth-profile.dto.ts`

각 OAuth 제공자의 응답을 통합된 형식으로 변환:

```typescript
interface OAuthProfileDto {
  providerId: string;      // 제공자별 고유 ID
  email: string;           // 이메일 (필수)
  emailVerified?: boolean; // 이메일 인증 여부
  name?: string;           // 이름 (선택적)
  picture?: string;        // 프로필 이미지 (선택적)
}
```

**변환 함수들**:
- `googleToOAuthProfile()` - Google 응답 → OAuthProfileDto
- `lineToOAuthProfile()` - LINE 응답 → OAuthProfileDto
- `yahooToOAuthProfile()` - Yahoo 응답 → OAuthProfileDto
- `kakaoToOAuthProfile()` - Kakao 응답 → OAuthProfileDto
- `appleToOAuthProfile()` - Apple 응답 → OAuthProfileDto
- `facebookToOAuthProfile()` - Facebook 응답 → OAuthProfileDto

### 2. 통합 인증 로직

**파일**: `src/modules/auth/auth.service.ts`

```typescript
private async authenticateWithOAuth(
  provider: 'GOOGLE' | 'LINE' | 'YAHOO' | 'KAKAO' | 'APPLE' | 'FACEBOOK',
  oauthProfile: OAuthProfileDto
): Promise<LoginResponseDto>
```

**역할**:
1. OAuthProfileDto를 받아서 User 테이블 조회
2. 신규 사용자인 경우 User 생성
3. 기존 사용자인 경우 로그인 정보 업데이트 (lastLoginAt, loginCount)
4. JWT 토큰 생성
5. UserResponseDto로 변환하여 반환

**장점**:
- 모든 OAuth 제공자가 동일한 로직 사용
- 새로운 제공자 추가 시 변환 함수만 작성하면 됨
- User 스키마 변경 시 한 곳만 수정

### 3. UserResponseDto (출력 통합)

**파일**: `src/modules/auth/dto/user-response.dto.ts`

클라이언트로 전송되는 User 데이터 형식을 표준화:

```typescript
interface UserResponseDto {
  id: string;
  email: string;
  emailVerified: boolean;
  phoneNumber: string | null;
  phoneVerified: boolean;
  authProvider: string;
  authProviderId: string;
  status: string;
  lastLoginAt: string | null;  // ISO 8601 문자열
  lastLoginIp: string | null;
  loginCount: number;
  createdAt: string;
  updatedAt: string;
  deletedAt: string | null;
}
```

**변환 함수**:
```typescript
function toUserResponseDto(user: PrismaUser): UserResponseDto
```

**역할**:
- Prisma User 모델 → UserResponseDto 변환
- DateTime → ISO 8601 문자열 변환
- null 값 처리 및 기본값 설정
- 클라이언트가 필요한 필드만 전송

## OAuth 제공자별 특이사항

### Google
- ✅ 이메일 필수 제공
- ✅ 이메일 인증 여부 제공 (`email_verified`)
- ✅ 이름, 프로필 이미지 제공
- **ID 형식**: `sub` (문자열)

### LINE
- ⚠️ 이메일 선택적 (사용자가 제공 거부 가능)
- ❌ 이메일 인증 여부 미제공
- ✅ displayName, pictureUrl 제공
- **ID 형식**: `userId` (문자열)
- **플레이스홀더**: 이메일 없으면 `{userId}@line.placeholder` 사용

### Yahoo
- ✅ 이메일 필수 제공
- ✅ 이메일 인증 여부 제공
- ✅ 이름, 프로필 이미지 제공
- **ID 형식**: `sub` (문자열)

### Kakao
- ⚠️ 이메일 선택적 (사용자 동의 필요)
- ✅ 이메일 인증 여부 제공 (`is_email_verified`)
- ✅ nickname, profile_image_url 제공
- **ID 형식**: `id` (숫자) → 문자열 변환 필요
- **플레이스홀더**: 이메일 없으면 `{id}@kakao.placeholder` 사용

### Apple
- ✅ 이메일 필수 제공
- ✅ 이메일 인증 여부 제공 (`email_verified`)
- ⚠️ 이름은 최초 로그인 시에만 제공
- ❌ 프로필 이미지 미제공
- **ID 형식**: `sub` (문자열)

### Facebook
- ✅ 이메일 필수 제공
- ❌ 이메일 인증 여부 미제공
- ✅ 이름 제공
- ✅ 프로필 이미지 제공 (`picture.data.url`)
- **ID 형식**: `id` (문자열)

## 새로운 OAuth 제공자 추가 방법

### 1. 변환 함수 작성

`src/modules/auth/dto/oauth-profile.dto.ts`에 추가:

```typescript
export function newProviderToOAuthProfile(profile: any): OAuthProfileDto {
  return {
    providerId: profile.id.toString(),
    email: profile.email || `${profile.id}@newprovider.placeholder`,
    emailVerified: profile.email_verified ?? false,
    name: profile.name,
    picture: profile.avatar_url,
  };
}
```

### 2. AuthService에 메서드 추가

```typescript
async authenticateWithNewProvider(token: string): Promise<LoginResponseDto> {
  try {
    // 제공자 API 호출
    const profile = await newProviderClient.getProfile(token);

    // 통합 형식으로 변환
    const oauthProfile = newProviderToOAuthProfile(profile);

    // 통합 인증 로직 사용
    return await this.authenticateWithOAuth('NEW_PROVIDER', oauthProfile);
  } catch (error) {
    throw new Error('New Provider authentication failed');
  }
}
```

### 3. Prisma 스키마 업데이트

`prisma/schema.prisma`:

```prisma
enum AuthProvider {
  GOOGLE
  LINE
  YAHOO
  KAKAO
  APPLE
  FACEBOOK
  NEW_PROVIDER  // 추가
}
```

### 4. Controller와 Routes 추가

```typescript
async newProviderLogin(req: Request, res: Response) {
  const { token } = req.body;
  const result = await authService.authenticateWithNewProvider(token);
  return res.status(200).json({ success: true, data: result });
}
```

## 데이터 흐름

### 로그인 요청
```
1. 클라이언트: Google 로그인 → idToken 받음
2. 클라이언트: POST /api/auth/google { idToken }
3. AuthController.googleLogin()
4. AuthService.authenticateWithGoogle(idToken)
5. Google ID Token 검증
6. googleToOAuthProfile(payload) → OAuthProfileDto
7. authenticateWithOAuth('GOOGLE', oauthProfile)
8. User 조회/생성
9. JWT 토큰 생성
10. toUserResponseDto(user) → UserResponseDto
11. LoginResponseDto 반환 → 클라이언트
```

### 응답 형식
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "emailVerified": true,
      "authProvider": "GOOGLE",
      "authProviderId": "google-user-id",
      "status": "ACTIVE",
      "lastLoginAt": "2025-12-31T10:00:00.000Z",
      "loginCount": 5,
      "createdAt": "2025-01-01T00:00:00.000Z",
      "updatedAt": "2025-12-31T10:00:00.000Z"
    },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "isNewUser": false
  }
}
```

## 보안 고려사항

### 1. 플레이스홀더 이메일
LINE, Kakao 같이 이메일이 선택적인 경우:
- `{providerId}@{provider}.placeholder` 형식 사용
- **문제점**: 실제 이메일이 아니므로 이메일 발송 불가
- **해결책**: Profile에서 실제 이메일 입력 유도

### 2. 이메일 중복 방지
- User 테이블은 `(authProvider, authProviderId)` 조합으로 고유성 보장
- 같은 이메일이라도 다른 제공자면 별도 계정으로 처리
- 계정 통합 기능은 별도 구현 필요

### 3. 토큰 검증
- 각 제공자의 공식 SDK 사용 필수
- ID Token은 반드시 서버에서 검증
- Access Token의 만료 시간 확인

## 프론트엔드 연동

프론트엔드는 제공자에 관계없이 동일한 `UserResponseDto` 형식을 받으므로:

```dart
// Flutter UserModel.fromJson()
factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'],
    email: json['email'],
    authProvider: json['authProvider'],
    authProviderId: json['authProviderId'],
    // ... 모든 제공자에서 동일한 필드
  );
}
```

**장점**:
- 프론트엔드는 OAuth 제공자를 신경 쓸 필요 없음
- 백엔드에서 새 제공자 추가해도 프론트엔드 수정 불필요
- 일관된 데이터 형식으로 버그 감소

## 요약

### Before (문제점)
- ❌ 각 OAuth 제공자마다 다른 데이터 처리 로직
- ❌ 코드 중복
- ❌ 유지보수 어려움
- ❌ 새 제공자 추가 시 전체 코드 수정

### After (DTO 패턴)
- ✅ 통합된 인증 로직 (`authenticateWithOAuth`)
- ✅ 제공자별 변환 함수만 작성
- ✅ 유지보수 용이
- ✅ 새 제공자 추가 간편
- ✅ 일관된 응답 형식 (`UserResponseDto`)
- ✅ 프론트엔드 독립성 유지
