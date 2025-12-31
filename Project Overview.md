# 결혼 매칭 앱 개발 명세서 (Marriage Matching App Specification)

## 프로젝트 개요 (Project Overview)

### 프로젝트 목적
위치 기반 결혼 상대 매칭 서비스를 제공하는 크로스 플랫폼 모바일 애플리케이션 개발

### 기술 스택 (Tech Stack)

#### Frontend
- **Framework**: Flutter (latest stable version)
- **상태관리**: Provider / Riverpod (권장)
- **HTTP 통신**: dio
- **소켓 통신**: socket_io_client
- **지도**: google_maps_flutter
- **위치**: geolocator, geocoding
- **인증**: flutter_login, google_sign_in, flutter_line_sdk

#### Backend
- **Framework**: Node.js (Express.js or Fastify)
- **언어**: TypeScript (타입 안정성)
- **아키텍처**: 모듈화된 레이어드 아키텍처
- **실시간 통신**: Socket.IO
- **인증**: Passport.js (Google, LINE, Yahoo OAuth)
- **검증**: Joi / Zod
- **ORM**: Prisma (PostgreSQL)
- **캐싱**: Redis (세션, 실시간 데이터)
- **파일 스토리지**: AWS S3 / Google Cloud Storage

#### Database
- **DBMS**: PostgreSQL (v14+)
- **인덱싱 전략**: 위치 기반 검색 최적화 (PostGIS 확장)
- **Connection Pool**: pg-pool

#### Infrastructure
- **배포**: Docker + Kubernetes / AWS ECS
- **CI/CD**: GitHub Actions / GitLab CI
- **모니터링**: Prometheus + Grafana
- **로깅**: Winston + ELK Stack

---

## 핵심 기능 명세 (Core Features Specification)

### 1. 인증 및 회원가입 (Authentication & Registration)

#### 1.1 소셜 로그인
```yaml
지원 플랫폼:
  - Google OAuth 2.0
  - LINE Login
  - Yahoo OAuth

구현 요구사항:
  - JWT 기반 토큰 인증
  - Refresh Token 자동 갱신
  - 디바이스별 세션 관리
  - 로그아웃 시 토큰 무효화
```

#### 1.2 회원가입 플로우
1. 소셜 로그인 선택
2. OAuth 인증 처리
3. 기본 정보 수집 (이메일, 이름)
4. **프로필 작성 강제** (서비스 이용 필수 조건)
5. 위치 권한 요청 및 인증

#### 1.3 프로필 필수 정보
```typescript
interface UserProfile {
  userId: string;
  displayName: string;
  gender: 'male' | 'female' | 'other';
  birthDate: Date;
  height: number;
  occupation: string;
  education: string;
  religion?: string;
  smoking: 'yes' | 'no' | 'sometimes';
  drinking: 'yes' | 'no' | 'sometimes';
  profileImages: string[]; // 최소 1장, 최대 6장
  bio: string; // 자기소개 (최대 500자)
  interests: string[]; // 관심사 태그
  locationAreas: LocationArea[]; // 활동 지역 (최대 2개)
}
```

---

### 2. 위치 기반 기능 (Location-Based Features)

#### 2.1 활동 지역 설정
```typescript
interface LocationArea {
  id: string;
  userId: string;
  latitude: number;
  longitude: number;
  address: string;
  radius: number; // 10km, 20km, 30km, 40km
  isPrimary: boolean;
  verifiedAt: Date;
  createdAt: Date;
}

제약사항:
  - 최대 2개 지역 설정 가능
  - 각 지역은 위치 인증 필수
  - 인증 유효기간: 30일 (재인증 필요)
```

#### 2.2 위치 인증 프로세스
1. GPS를 통한 현재 위치 획득
2. Google Maps API로 주소 변환
3. 사용자 확인 후 저장
4. 타임스탬프 기록
5. 30일 후 재인증 알림

#### 2.3 매칭 거리 로직
```javascript
// 매칭 거리 우선순위
const MATCHING_DISTANCE_PRIORITY = {
  PRIMARY: 10, // 10km 이내 우선 검색
  SECONDARY: 20, // 20km 확장
  TERTIARY: 30, // 30km 확장
  MAX: 40 // 최대 40km
};

// PostGIS를 활용한 거리 계산 쿼리
SELECT * FROM users 
WHERE ST_DWithin(
  location::geography,
  ST_SetSRID(ST_MakePoint($longitude, $latitude), 4326)::geography,
  10000 -- 10km in meters
);
```

---

### 3. 매칭 시스템 (Matching System)

#### 3.1 매칭 필터링 조건
```typescript
interface MatchingFilter {
  ageRange: { min: number; max: number };
  heightRange: { min: number; max: number };
  distance: number; // 10, 20, 30, 40 km
  education?: string[];
  occupation?: string[];
  religion?: string[];
  smoking?: string[];
  drinking?: string[];
}
```

#### 3.2 매칭 알고리즘
```
1. 기본 필터링 (위치, 나이, 성별)
2. 사용자 지정 조건 적용
3. 밸런스 게임 유사도 계산
4. 활동성 점수 (최근 접속, 프로필 완성도)
5. 종합 점수 계산 및 정렬
```

#### 3.3 밸런스 게임 매칭
```typescript
interface BalanceGame {
  id: string;
  question: string;
  optionA: string;
  optionB: string;
  category: string;
  isActive: boolean;
}

interface UserBalanceGameAnswer {
  userId: string;
  gameId: string;
  selectedOption: 'A' | 'B';
  answeredAt: Date;
}

// 유사도 계산
const calculateCompatibility = (user1Answers, user2Answers) => {
  const matchCount = user1Answers.filter((ans1, idx) => 
    ans1.selectedOption === user2Answers[idx].selectedOption
  ).length;
  
  return (matchCount / user1Answers.length) * 100;
};
```

#### 3.4 밸런스 게임 제공 로직
- DB에서 활성화된 게임 중 랜덤 선택
- 사용자당 10~20개 제공 (설정 가능)
- 응답률 추적 및 분석
- 카테고리별 균형 있게 선택

---

### 4. 대화 시스템 (Chat System)

#### 4.1 대화 요청 플로우
```typescript
interface ChatRequest {
  id: string;
  senderId: string;
  receiverId: string;
  message: string; // 첫 메시지
  status: 'pending' | 'accepted' | 'rejected' | 'expired';
  createdAt: Date;
  expiresAt: Date; // 48시간 후 자동 만료
}
```

#### 4.2 대화 제한 (Limitation)

##### 무료 사용자
```yaml
대화 시간 제한:
  - 1회 대화: 최대 30분
  - 30분 경과 시 유료 전환 유도
  
대화 요청 제한:
  - 일일 최대: 3회
  - 월간 최대: 30회
  - 제한 초과 시 유료 전환 유도
```

##### 유료 사용자
```yaml
무제한 대화:
  - 시간 제한 없음
  - 요청 횟수 제한 없음
  - 우선 매칭 혜택
```

#### 4.3 실시간 채팅 (Socket.IO)
```typescript
// Socket Event 정의
interface SocketEvents {
  // Client -> Server
  'chat:send': (data: { roomId: string; message: string }) => void;
  'chat:typing': (data: { roomId: string; isTyping: boolean }) => void;
  'user:status': (status: 'online' | 'away' | 'offline') => void;
  
  // Server -> Client
  'chat:receive': (data: ChatMessage) => void;
  'chat:read': (data: { messageId: string }) => void;
  'user:status:update': (data: { userId: string; status: string }) => void;
  'system:users:count': (count: number) => void;
}

interface ChatMessage {
  id: string;
  roomId: string;
  senderId: string;
  content: string;
  type: 'text' | 'image' | 'system';
  createdAt: Date;
  readAt?: Date;
}
```

#### 4.4 대화 타이머 구현
```javascript
// Backend: 대화 시간 추적
class ChatSessionManager {
  private sessions: Map<string, ChatSession>;
  
  startSession(roomId: string, userId: string, isPremium: boolean) {
    const session = {
      roomId,
      userId,
      startTime: Date.now(),
      duration: isPremium ? Infinity : 30 * 60 * 1000, // 30분
      timer: null
    };
    
    if (!isPremium) {
      session.timer = setTimeout(() => {
        this.endSession(roomId);
        io.to(roomId).emit('chat:time:expired');
      }, session.duration);
    }
    
    this.sessions.set(roomId, session);
  }
}
```

---

### 5. 결제 시스템 (Payment System)

#### 5.1 결제 플랜
```typescript
enum PaymentPlan {
  SUBSCRIPTION_MONTHLY = 'subscription_monthly',
  CHAT_PACK_10 = 'chat_pack_10',
  CHAT_PACK_30 = 'chat_pack_30',
  CHAT_PACK_50 = 'chat_pack_50'
}

interface PaymentPlanDetail {
  planId: PaymentPlan;
  name: {
    ko: string;
    ja: string;
    en: string;
  };
  price: number;
  currency: string;
  features: string[];
  duration?: number; // 일 단위 (구독만 해당)
}

// 플랜 상세
const PAYMENT_PLANS: PaymentPlanDetail[] = [
  {
    planId: PaymentPlan.SUBSCRIPTION_MONTHLY,
    name: {
      ko: '프리미엄 월간 구독',
      ja: 'プレミアム月間サブスクリプション',
      en: 'Premium Monthly Subscription'
    },
    price: 29900,
    currency: 'KRW',
    features: ['무제한 대화', '무제한 요청', '우선 매칭', '광고 제거'],
    duration: 30
  },
  {
    planId: PaymentPlan.CHAT_PACK_10,
    name: { ko: '대화 10회권', ja: 'チャット10回券', en: '10 Chat Pack' },
    price: 9900,
    currency: 'KRW',
    features: ['10회 대화 요청']
  },
  // ... 추가 플랜
];
```

#### 5.2 결제 통합 (Payment Gateway)
```yaml
지원 결제 수단:
  - 신용카드 (Stripe / Toss Payments)
  - Google Play 인앱결제
  - Apple In-App Purchase
  - 편의점 결제 (일본)
  
구현 요구사항:
  - 결제 내역 저장 및 관리
  - 구독 자동 갱신
  - 환불 처리 로직
  - 결제 실패 재시도
```

---

### 6. 다국어 지원 (Internationalization)

#### 6.1 지원 언어
- 한국어 (ko)
- 일본어 (ja)
- 영어 (en)

#### 6.2 구현 방식
```dart
// Flutter: flutter_localizations
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    AppLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('ko', 'KR'),
    Locale('ja', 'JP'),
    Locale('en', 'US'),
  ],
);
```

```json
// i18n/ko.json
{
  "app.title": "TruePair",
  "auth.login": "로그인",
  "auth.google": "Google로 로그인",
  "profile.required": "프로필 작성이 필요합니다",
  "chat.time.limit": "대화 시간이 {minutes}분 남았습니다"
}
```

---

## 데이터베이스 스키마 (Database Schema)

### ERD 개요
```sql
-- 핵심 테이블
Users (사용자)
Profiles (프로필)
LocationAreas (활동 지역)
BalanceGames (밸런스 게임)
UserBalanceGameAnswers (게임 응답)
ChatRequests (대화 요청)
ChatRooms (채팅방)
ChatMessages (메시지)
Payments (결제)
Subscriptions (구독)
```

### 주요 테이블 상세

#### Users
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  auth_provider VARCHAR(50) NOT NULL, -- 'google', 'line', 'yahoo'
  auth_provider_id VARCHAR(255) NOT NULL,
  status VARCHAR(20) DEFAULT 'active', -- 'active', 'suspended', 'deleted'
  last_login_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(auth_provider, auth_provider_id)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
```

#### Profiles
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  display_name VARCHAR(100) NOT NULL,
  gender VARCHAR(20) NOT NULL,
  birth_date DATE NOT NULL,
  height INTEGER,
  occupation VARCHAR(100),
  education VARCHAR(100),
  religion VARCHAR(50),
  smoking VARCHAR(20),
  drinking VARCHAR(20),
  bio TEXT,
  profile_images JSONB, -- ["url1", "url2", ...]
  interests JSONB, -- ["interest1", "interest2", ...]
  is_complete BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id)
);

CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_gender ON profiles(gender);
CREATE INDEX idx_profiles_birth_date ON profiles(birth_date);
```

#### LocationAreas (PostGIS 확장 사용)
```sql
-- PostGIS 확장 활성화
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE location_areas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  location GEOGRAPHY(POINT, 4326) NOT NULL, -- PostGIS 타입
  address VARCHAR(500) NOT NULL,
  radius INTEGER DEFAULT 10000, -- 미터 단위
  is_primary BOOLEAN DEFAULT false,
  verified_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CHECK (radius IN (10000, 20000, 30000, 40000))
);

CREATE INDEX idx_location_areas_user_id ON location_areas(user_id);
CREATE INDEX idx_location_areas_location ON location_areas USING GIST(location);
CREATE INDEX idx_location_areas_verified_at ON location_areas(verified_at);

-- 거리 기반 검색을 위한 함수
CREATE OR REPLACE FUNCTION find_nearby_users(
  user_location GEOGRAPHY,
  max_distance INTEGER DEFAULT 10000
)
RETURNS TABLE(user_id UUID, distance DOUBLE PRECISION) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    la.user_id,
    ST_Distance(la.location, user_location) as distance
  FROM location_areas la
  WHERE ST_DWithin(la.location, user_location, max_distance)
    AND la.verified_at > NOW() - INTERVAL '30 days'
  ORDER BY distance;
END;
$$ LANGUAGE plpgsql;
```

#### BalanceGames
```sql
CREATE TABLE balance_games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question JSONB NOT NULL, -- {"ko": "질문", "ja": "質問", "en": "Question"}
  option_a JSONB NOT NULL,
  option_b JSONB NOT NULL,
  category VARCHAR(50),
  display_order INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_balance_games_category ON balance_games(category);
CREATE INDEX idx_balance_games_is_active ON balance_games(is_active);
```

#### UserBalanceGameAnswers
```sql
CREATE TABLE user_balance_game_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  game_id UUID NOT NULL REFERENCES balance_games(id) ON DELETE CASCADE,
  selected_option CHAR(1) NOT NULL CHECK (selected_option IN ('A', 'B')),
  answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, game_id)
);

CREATE INDEX idx_ubga_user_id ON user_balance_game_answers(user_id);
CREATE INDEX idx_ubga_game_id ON user_balance_game_answers(game_id);
```

#### ChatRequests
```sql
CREATE TABLE chat_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  initial_message TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'accepted', 'rejected', 'expired'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  responded_at TIMESTAMP,
  CHECK (sender_id != receiver_id)
);

CREATE INDEX idx_chat_requests_sender ON chat_requests(sender_id);
CREATE INDEX idx_chat_requests_receiver ON chat_requests(receiver_id);
CREATE INDEX idx_chat_requests_status ON chat_requests(status);
CREATE INDEX idx_chat_requests_expires_at ON chat_requests(expires_at);
```

#### ChatRooms
```sql
CREATE TABLE chat_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP, -- 무료 사용자의 경우 시간 제한
  is_premium BOOLEAN DEFAULT false,
  status VARCHAR(20) DEFAULT 'active', -- 'active', 'expired', 'closed'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CHECK (user1_id < user2_id), -- 중복 방지
  UNIQUE(user1_id, user2_id)
);

CREATE INDEX idx_chat_rooms_user1 ON chat_rooms(user1_id);
CREATE INDEX idx_chat_rooms_user2 ON chat_rooms(user2_id);
CREATE INDEX idx_chat_rooms_status ON chat_rooms(status);
```

#### ChatMessages
```sql
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type VARCHAR(20) DEFAULT 'text', -- 'text', 'image', 'system'
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_messages_room_id ON chat_messages(room_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at DESC);
CREATE INDEX idx_chat_messages_is_read ON chat_messages(is_read);
```

#### Payments & Subscriptions
```sql
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan_id VARCHAR(50) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'KRW',
  payment_method VARCHAR(50) NOT NULL,
  transaction_id VARCHAR(255) UNIQUE,
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'completed', 'failed', 'refunded'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP
);

CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan_id VARCHAR(50) NOT NULL,
  status VARCHAR(20) DEFAULT 'active', -- 'active', 'cancelled', 'expired'
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  auto_renew BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_expires_at ON subscriptions(expires_at);
```

---

## 백엔드 아키텍처 (Backend Architecture)

### 디렉토리 구조
```
backend/
├── src/
│   ├── config/          # 설정 파일
│   │   ├── database.ts
│   │   ├── redis.ts
│   │   └── oauth.ts
│   ├── modules/         # 기능별 모듈
│   │   ├── auth/
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.routes.ts
│   │   │   └── auth.types.ts
│   │   ├── user/
│   │   ├── profile/
│   │   ├── location/
│   │   ├── matching/
│   │   ├── chat/
│   │   ├── payment/
│   │   └── balance-game/
│   ├── common/          # 공통 유틸리티
│   │   ├── middleware/
│   │   ├── validators/
│   │   ├── utils/
│   │   └── types/
│   ├── socket/          # Socket.IO 핸들러
│   │   ├── chat.handler.ts
│   │   ├── presence.handler.ts
│   │   └── index.ts
│   ├── database/        # Prisma 스키마
│   │   └── schema.prisma
│   └── app.ts           # 앱 진입점
├── tests/
├── .env
├── package.json
└── tsconfig.json
```

### 모듈 예시: Auth Module
```typescript
// auth.service.ts
import { OAuth2Client } from 'google-auth-library';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';

export class AuthService {
  private prisma: PrismaClient;
  private googleClient: OAuth2Client;

  constructor() {
    this.prisma = new PrismaClient();
    this.googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
  }

  async authenticateWithGoogle(idToken: string) {
    const ticket = await this.googleClient.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID
    });
    
    const payload = ticket.getPayload();
    if (!payload) throw new Error('Invalid token');

    let user = await this.prisma.users.findUnique({
      where: {
        auth_provider_auth_provider_id: {
          auth_provider: 'google',
          auth_provider_id: payload.sub
        }
      }
    });

    if (!user) {
      user = await this.prisma.users.create({
        data: {
          email: payload.email!,
          auth_provider: 'google',
          auth_provider_id: payload.sub
        }
      });
    }

    const accessToken = this.generateAccessToken(user.id);
    const refreshToken = this.generateRefreshToken(user.id);

    return { user, accessToken, refreshToken };
  }

  private generateAccessToken(userId: string): string {
    return jwt.sign({ userId }, process.env.JWT_SECRET!, {
      expiresIn: '1h'
    });
  }

  private generateRefreshToken(userId: string): string {
    return jwt.sign({ userId }, process.env.JWT_REFRESH_SECRET!, {
      expiresIn: '30d'
    });
  }
}
```

### Socket.IO 구현
```typescript
// socket/chat.handler.ts
import { Server, Socket } from 'socket.io';
import { PrismaClient } from '@prisma/client';
import { verifyToken } from '../common/utils/jwt';

export class ChatSocketHandler {
  private io: Server;
  private prisma: PrismaClient;
  private userSockets: Map<string, string>; // userId -> socketId

  constructor(io: Server) {
    this.io = io;
    this.prisma = new PrismaClient();
    this.userSockets = new Map();
  }

  handleConnection(socket: Socket) {
    // 인증 검증
    const token = socket.handshake.auth.token;
    const user = verifyToken(token);
    
    if (!user) {
      socket.disconnect();
      return;
    }

    this.userSockets.set(user.userId, socket.id);
    
    // 사용자 상태 업데이트
    this.broadcastUserStatus(user.userId, 'online');
    
    // 접속자 수 브로드캐스트
    this.broadcastOnlineCount();

    // 이벤트 핸들러 등록
    socket.on('chat:send', (data) => this.handleChatSend(socket, user.userId, data));
    socket.on('chat:typing', (data) => this.handleTyping(socket, user.userId, data));
    socket.on('disconnect', () => this.handleDisconnect(user.userId));
  }

  private async handleChatSend(socket: Socket, senderId: string, data: any) {
    const { roomId, content } = data;

    // 채팅방 권한 확인
    const room = await this.prisma.chat_rooms.findFirst({
      where: {
        id: roomId,
        OR: [
          { user1_id: senderId },
          { user2_id: senderId }
        ]
      }
    });

    if (!room) {
      socket.emit('error', { message: 'Unauthorized' });
      return;
    }

    // 시간 제한 확인 (무료 사용자)
    if (!room.is_premium && room.expires_at && new Date() > room.expires_at) {
      socket.emit('chat:time:expired');
      return;
    }

    // 메시지 저장
    const message = await this.prisma.chat_messages.create({
      data: {
        room_id: roomId,
        sender_id: senderId,
        content,
        message_type: 'text'
      }
    });

    // 상대방에게 전송
    const receiverId = room.user1_id === senderId ? room.user2_id : room.user1_id;
    const receiverSocketId = this.userSockets.get(receiverId);
    
    if (receiverSocketId) {
      this.io.to(receiverSocketId).emit('chat:receive', message);
    }

    socket.emit('chat:sent', { messageId: message.id });
  }

  private broadcastOnlineCount() {
    const count = this.userSockets.size;
    this.io.emit('system:users:count', count);
  }
}
```

---

## 프론트엔드 아키텍처 (Frontend Architecture)

### Flutter 디렉토리 구조
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── network/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   ├── profile/
│   ├── matching/
│   ├── chat/
│   ├── payment/
│   └── settings/
├── shared/
│   ├── widgets/
│   ├── models/
│   └── services/
└── l10n/
    ├── app_ko.arb
    ├── app_ja.arb
    └── app_en.arb
```

### 상태 관리 예시 (Riverpod)
```dart
// features/chat/presentation/providers/chat_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final socketProvider = Provider<IO.Socket>((ref) {
  final socket = IO.io('https://api.example.com', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
    'auth': {
      'token': ref.read(authProvider).token,
    },
  });

  socket.connect();
  
  ref.onDispose(() {
    socket.disconnect();
  });

  return socket;
});

final chatMessagesProvider = StateNotifierProvider.family
  ChatMessagesNotifier, 
  AsyncValue<List<ChatMessage>>, 
  String
>((ref, roomId) {
  return ChatMessagesNotifier(ref.read, roomId);
});

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final Reader read;
  final String roomId;

  ChatMessagesNotifier(this.read, this.roomId) : super(const AsyncValue.loading()) {
    _initialize();
  }

  void _initialize() async {
    // 기존 메시지 로드
    await _loadMessages();
    
    // 실시간 메시지 리스닝
    _listenToSocket();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await read(chatRepositoryProvider).getMessages(roomId);
      state = AsyncValue.data(messages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _listenToSocket() {
    final socket = read(socketProvider);
    
    socket.on('chat:receive', (data) {
      final message = ChatMessage.fromJson(data);
      if (message.roomId == roomId) {
        state.whenData((messages) {
          state = AsyncValue.data([...messages, message]);
        });
      }
    });
  }

  Future<void> sendMessage(String content) async {
    final socket = read(socketProvider);
    socket.emit('chat:send', {
      'roomId': roomId,
      'content': content,
    });
  }
}
```

### 위치 기반 기능 구현
```dart
// features/location/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isEmpty) return 'Unknown location';

    final place = placemarks.first;
    return '${place.locality}, ${place.administrativeArea}, ${place.country}';
  }

  Future<bool> verifyLocation(LatLng target, double maxDistance) async {
    final current = await getCurrentPosition();
    final distance = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      target.latitude,
      target.longitude,
    );

    return distance <= maxDistance;
  }
}
```

---

## 보안 고려사항 (Security Considerations)

### 1. 인증 보안
- JWT 토큰 암호화 및 만료 시간 관리
- Refresh Token 로테이션
- HTTPS 통신 강제
- OAuth2 상태 파라미터 검증

### 2. 데이터 보안
- 개인정보 암호화 (AES-256)
- 데이터베이스 백업 및 암호화
- SQL Injection 방어 (Prepared Statements)
- XSS 방어 (입력 검증 및 Sanitization)

### 3. 위치 정보 보호
- 정확한 좌표가 아닌 반경 기반 표시
- 위치 인증 시간 제한
- 위치 기록 최소화

### 4. 채팅 보안
- End-to-end 암호화 고려
- 부적절한 콘텐츠 필터링
- 신고 및 차단 기능

---

## 성능 최적화 (Performance Optimization)

### 1. 데이터베이스 최적화
```sql
-- 인덱스 최적화
CREATE INDEX CONCURRENTLY idx_chat_messages_room_created 
ON chat_messages(room_id, created_at DESC);

-- 파티셔닝 (대용량 메시지 테이블)
CREATE TABLE chat_messages (
  ...
) PARTITION BY RANGE (created_at);

-- 쿼리 최적화 (EXPLAIN ANALYZE 사용)
```

### 2. Redis 캐싱
```typescript
// 온라인 사용자 캐싱
await redis.setex(`user:${userId}:status`, 300, 'online');

// 매칭 결과 캐싱
const cacheKey = `matching:${userId}:${filterHash}`;
const cached = await redis.get(cacheKey);
if (cached) return JSON.parse(cached);

// 계산 후 캐싱
await redis.setex(cacheKey, 600, JSON.stringify(results));
```

### 3. 이미지 최적화
- CDN 사용 (CloudFlare / AWS CloudFront)
- 이미지 리사이징 및 압축
- WebP 포맷 사용
- Lazy Loading

### 4. Socket.IO 최적화
- Redis Adapter 사용 (다중 서버 환경)
- 메시지 배치 처리
- 연결 풀링

---

## 테스트 전략 (Testing Strategy)

### 1. 단위 테스트
```typescript
// auth.service.test.ts
import { AuthService } from './auth.service';

describe('AuthService', () => {
  it('should authenticate user with valid Google token', async () => {
    const service = new AuthService();
    const result = await service.authenticateWithGoogle(validToken);
    
    expect(result.user).toBeDefined();
    expect(result.accessToken).toBeDefined();
  });
});
```

### 2. 통합 테스트
```typescript
// chat.integration.test.ts
describe('Chat Integration', () => {
  it('should create chat room and send message', async () => {
    const request1 = await sendChatRequest(user1, user2);
    const room = await acceptChatRequest(user2, request1.id);
    const message = await sendMessage(room.id, 'Hello!');
    
    expect(message.content).toBe('Hello!');
  });
});
```

### 3. E2E 테스트 (Flutter)
```dart
// test_driver/app_test.dart
testWidgets('Complete user flow', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  // 로그인
  await tester.tap(find.text('Google로 로그인'));
  await tester.pumpAndSettle();
  
  // 프로필 작성
  await tester.enterText(find.byKey(Key('name_field')), 'Test User');
  await tester.tap(find.text('저장'));
  
  // 매칭 화면 진입
  expect(find.text('주변 사람 찾기'), findsOneWidget);
});
```

---

## 모니터링 및 로깅 (Monitoring & Logging)

### 1. 로깅 전략
```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

// 사용
logger.info('User authenticated', { userId, provider: 'google' });
logger.error('Payment failed', { userId, error: err.message });
```

### 2. 메트릭 수집
```typescript
// Prometheus 메트릭
import client from 'prom-client';

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const activeUsers = new client.Gauge({
  name: 'active_users_total',
  help: 'Total number of active users'
});
```

### 3. 알림 설정
- 서버 다운타임 알림
- 결제 실패율 임계값 초과
- 데이터베이스 연결 실패
- 높은 에러율 감지

---

## 배포 전략 (Deployment Strategy)

### 1. Docker 구성
```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
```

### 2. Kubernetes 배포
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: marriage-app-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: marriage-app
  template:
    metadata:
      labels:
        app: marriage-app
    spec:
      containers:
      - name: backend
        image: marriage-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: url
```

### 3. CI/CD 파이프라인
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: npm test
  
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build and push Docker image
        run: |
          docker build -t marriage-app:${{ github.sha }} .
          docker push marriage-app:${{ github.sha }}
      
      - name: Deploy to Kubernetes
        run: kubectl apply -f k8s/
```

---

## 개발 로드맵 (Development Roadmap)

### Phase 1: MVP (2-3개월)
- [x] 프로젝트 설정 및 환경 구축
- [ ] 인증 시스템 (소셜 로그인)
- [ ] 프로필 등록 및 관리
- [ ] 위치 설정 및 인증
- [ ] 기본 매칭 시스템
- [ ] 1:1 채팅 (시간 제한 포함)
- [ ] 결제 시스템 (기본)

### Phase 2: 핵심 기능 (1-2개월)
- [ ] 밸런스 게임 시스템
- [ ] 고급 필터링 및 검색
- [ ] 대화 요청 관리
- [ ] 알림 시스템
- [ ] 관리자 대시보드

### Phase 3: 최적화 및 출시 (1개월)
- [ ] 성능 최적화
- [ ] 보안 강화
- [ ] 다국어 완성도 향상
- [ ] 베타 테스트
- [ ] 스토어 출시 준비

### Phase 4: 출시 후 개선
- [ ] 사용자 피드백 반영
- [ ] A/B 테스트
- [ ] 추가 기능 개발
- [ ] 마케팅 및 확장

---

## 결론

이 문서는 위치 기반 결혼 매칭 앱 개발을 위한 종합적인 기술 명세서입니다. Flutter와 Node.js를 기반으로 한 모던한 아키텍처를 채택하며, PostgreSQL과 PostGIS를 활용한 효율적인 위치 기반 검색, Socket.IO를 통한 실시간 채팅, 그리고 다양한 결제 옵션을 제공합니다.

모듈화된 구조와 확장 가능한 설계를 통해 향후 기능 추가와 유지보수가 용이하며, 보안과 성능을 최우선으로 고려한 구현 전략을 제시합니다.

**다음 단계**: 개발 환경 설정 및 프로토타입 개발 시작

---

**문서 버전**: 1.0  
**작성일**: 2025-12-30  
**작성자**: 김준식