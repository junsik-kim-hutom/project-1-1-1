# Backend - Marriage Matching App

Node.js + TypeScript + Express 기반 백엔드 API 서버입니다.

## 🛠 기술 스택

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **언어**: TypeScript
- **ORM**: Prisma
- **데이터베이스**: PostgreSQL 15
- **캐싱**: Redis
- **실시간 통신**: Socket.IO
- **인증**: JWT, Google OAuth 2.0

## 📁 프로젝트 구조

```
backend/
├── src/
│   ├── config/              # 설정 파일
│   │   ├── database.ts      # Prisma 데이터베이스
│   │   ├── redis.ts         # Redis 캐시
│   │   └── oauth.ts         # OAuth 설정
│   ├── modules/             # 기능별 모듈
│   │   ├── auth/           # 인증 (Google OAuth, JWT)
│   │   ├── profile/        # 프로필 관리
│   │   ├── profile-field/  # 동적 프로필 필드
│   │   ├── location/       # 위치 기반 기능
│   │   ├── matching/       # 매칭 시스템
│   │   ├── balance-game/   # 밸런스 게임
│   │   ├── eq-test/        # EQ 감성 지능 테스트
│   │   ├── chat/           # 채팅 (REST API)
│   │   └── payment/        # 결제
│   ├── common/             # 공통 유틸리티
│   │   ├── middleware/     # 미들웨어
│   │   ├── validators/     # 유효성 검증
│   │   └── utils/          # 유틸 함수
│   ├── socket/             # Socket.IO 핸들러
│   │   ├── chat.handler.ts
│   │   └── index.ts
│   └── app.ts              # 애플리케이션 진입점
├── prisma/
│   └── schema.prisma       # Prisma 스키마
├── Dockerfile
├── package.json
└── tsconfig.json
```

## 🚀 시작하기

### 사전 요구사항

- Node.js 18 이상
- PostgreSQL 15 이상
- Redis (선택사항, Docker 사용 가능)

### 설치 및 실행

#### 1. 의존성 설치

```bash
cd backend
npm install
```

#### 2. 환경 변수 설정

```bash
cp .env.example .env
```

`.env` 파일을 열어 다음 항목들을 설정:

```env
# Database
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/marriage_matching?schema=public"

# JWT
JWT_SECRET="your-jwt-secret-key-here"
JWT_REFRESH_SECRET="your-jwt-refresh-secret-key-here"

# OAuth - Google
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"
GOOGLE_CALLBACK_URL="http://localhost:3000/api/auth/google/callback"

# Redis
REDIS_HOST="localhost"
REDIS_PORT="6379"

# Server
PORT=3000
NODE_ENV="development"
```

#### 3. 데이터베이스 설정

PostgreSQL 데이터베이스를 생성합니다:

```sql
CREATE DATABASE marriage_matching;
```

Prisma 마이그레이션 실행:

```bash
npm run prisma:generate
npm run prisma:migrate
```

#### 4. 개발 서버 실행

```bash
npm run dev
```

서버가 http://localhost:3000 에서 실행됩니다.

#### 5. 프로덕션 빌드

```bash
npm run build
npm start
```

## 📝 API 문서

### 인증 API

#### POST /api/auth/google
Google OAuth 로그인

**Request Body:**
```json
{
  "idToken": "google-id-token"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "profile": { ... }
    },
    "accessToken": "jwt-access-token",
    "refreshToken": "jwt-refresh-token",
    "isNewUser": false
  }
}
```

#### POST /api/auth/refresh
Access Token 갱신

**Request Body:**
```json
{
  "refreshToken": "jwt-refresh-token"
}
```

#### POST /api/auth/logout
로그아웃 (인증 필요)

**Headers:**
```
Authorization: Bearer <access-token>
```

### 프로필 API

#### POST /api/profile
프로필 생성 (인증 필요)

**Request Body:**
```json
{
  "displayName": "홍길동",
  "gender": "male",
  "birthDate": "1990-01-01",
  "height": 175,
  "occupation": "개발자",
  "education": "대학교 졸업",
  "bio": "안녕하세요!",
  "profileImages": ["url1", "url2"],
  "interests": ["영화", "음악", "여행"]
}
```

#### PUT /api/profile
프로필 수정 (인증 필요)

#### GET /api/profile/me
내 프로필 조회 (인증 필요)

#### GET /api/profile/:userId
특정 사용자 프로필 조회 (인증 필요)

#### DELETE /api/profile
프로필 삭제 (인증 필요)

### 위치 API (구현 예정)

#### POST /api/location/areas
활동 지역 추가

#### GET /api/location/areas
내 활동 지역 목록

#### PUT /api/location/areas/:id/verify
위치 재인증

### 매칭 API (구현 예정)

#### GET /api/matching
매칭 목록 조회

**Query Parameters:**
- `distance`: 10, 20, 30, 40 (km)
- `ageMin`, `ageMax`: 나이 범위
- `heightMin`, `heightMax`: 키 범위

#### GET /api/balance-games
밸런스 게임 목록

#### POST /api/balance-games/answers
밸런스 게임 응답

### EQ 테스트 API

#### GET /api/eq-test/questions
활성화된 EQ 테스트 질문 조회

**Query Parameters:**
- `category`: (선택) empathy, self_awareness, social_skills, motivation, emotion_regulation

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "questionKey": "empathy_1",
      "category": "empathy",
      "questionText": {
        "ko": "친구가 슬퍼하면 나도 함께 슬퍼집니다",
        "ja": "友達が悲しんでいると、私も一緒に悲しくなります",
        "en": "When a friend is sad, I feel sad too"
      },
      "answerType": "scale_5",
      "scoring": { "1": 1, "2": 2, "3": 3, "4": 4, "5": 5 },
      "displayOrder": 1
    }
  ]
}
```

#### POST /api/eq-test/answers
답변 제출 (인증 필요)

**Request Body:**
```json
{
  "questionId": "uuid",
  "answer": 4
}
```

#### POST /api/eq-test/results/calculate
테스트 결과 계산 (인증 필요)

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "totalScore": 4,
    "empathyScore": 4,
    "selfAwarenessScore": 5,
    "socialSkillsScore": 3,
    "motivationScore": 4,
    "emotionRegulationScore": 4,
    "personalityType": "empathetic",
    "insights": {
      "strengths": [
        {
          "ko": "타인의 감정을 잘 이해하고 공감하는 능력이 뛰어납니다",
          "ja": "他人の感情をよく理解し共感する能力が優れています",
          "en": "Excellent ability to understand and empathize with others"
        }
      ],
      "improvements": [],
      "matchingTips": [
        {
          "ko": "감정적 교류를 중요하게 생각하는 상대와 잘 맞습니다",
          "ja": "感情的な交流を重要視する相手とよく合います",
          "en": "You match well with partners who value emotional connection"
        }
      ]
    },
    "completedAt": "2025-12-30T12:00:00Z"
  }
}
```

#### GET /api/eq-test/results
내 테스트 결과 조회 (인증 필요)

#### POST /api/eq-test/seed
초기 질문 데이터 생성 (개발용)

### 채팅 API (구현 예정)

#### POST /api/chat/requests
대화 요청 보내기

#### GET /api/chat/requests
받은/보낸 대화 요청 목록

#### POST /api/chat/requests/:id/accept
대화 요청 수락

#### GET /api/chat/rooms
채팅방 목록

#### GET /api/chat/rooms/:roomId/messages
메시지 내역

## 🔌 Socket.IO 이벤트

### Client -> Server

#### `connection`
소켓 연결 (인증 필요)

**Auth:**
```javascript
socket = io('http://localhost:3000', {
  auth: {
    token: 'jwt-access-token'
  }
});
```

#### `chat:send`
메시지 전송

**Payload:**
```javascript
{
  roomId: 'room-uuid',
  content: '메시지 내용'
}
```

#### `chat:typing`
타이핑 중 표시

**Payload:**
```javascript
{
  roomId: 'room-uuid',
  isTyping: true
}
```

#### `chat:read`
메시지 읽음 표시

**Payload:**
```javascript
{
  messageId: 'message-uuid'
}
```

### Server -> Client

#### `chat:receive`
메시지 수신

**Payload:**
```javascript
{
  id: 'message-uuid',
  roomId: 'room-uuid',
  senderId: 'user-uuid',
  content: '메시지 내용',
  createdAt: '2025-12-30T12:00:00Z'
}
```

#### `chat:sent`
메시지 전송 성공

#### `chat:time:expired`
무료 사용자 시간 만료

#### `user:status:update`
사용자 온라인 상태 변경

#### `system:users:count`
현재 접속자 수

## 🗄 데이터베이스 스키마

### 주요 테이블

- **users** - 사용자 계정
- **profiles** - 프로필 정보
- **profile_fields** - 동적 프로필 필드 정의
- **user_profile_values** - 사용자 프로필 값
- **location_areas** - 활동 지역 (위도/경도 기반)
- **balance_games** - 밸런스 게임 문제
- **user_balance_game_answers** - 사용자 응답
- **eq_test_questions** - EQ 테스트 질문
- **eq_test_answers** - 사용자 EQ 테스트 응답
- **eq_test_results** - EQ 테스트 결과 요약
- **chat_requests** - 대화 요청
- **chat_rooms** - 채팅방
- **chat_messages** - 메시지
- **payments** - 결제 내역
- **subscriptions** - 구독 정보

자세한 스키마는 [prisma/schema.prisma](./prisma/schema.prisma)를 참조하세요.

### Prisma Studio

데이터베이스를 시각적으로 관리:

```bash
npm run prisma:studio
```

## 🧪 테스트

```bash
npm test
```

## 🐳 Docker

### Docker로 실행

```bash
docker build -t marriage-matching-backend .
docker run -p 3000:3000 --env-file .env marriage-matching-backend
```

### Docker Compose (권장)

프로젝트 루트에서:

```bash
docker-compose up -d
```

## 📊 로깅

Winston을 사용한 구조화된 로깅 (구현 예정):

- `error.log` - 에러 로그
- `combined.log` - 전체 로그

## 🔒 보안

- JWT 기반 인증
- Refresh Token 로테이션
- HTTPS 통신 (프로덕션)
- SQL Injection 방지 (Prisma Prepared Statements)
- XSS 방지 (입력 검증)

## 🚀 배포

### 환경 변수 설정

프로덕션 환경에서는 반드시 다음을 변경:

- `JWT_SECRET`, `JWT_REFRESH_SECRET` - 강력한 랜덤 문자열
- `NODE_ENV=production`
- `DATABASE_URL` - 프로덕션 데이터베이스
- `CORS_ORIGIN` - 허용된 도메인만

### 빌드 및 실행

```bash
npm run build
NODE_ENV=production npm start
```

## 📝 스크립트

- `npm run dev` - 개발 서버 실행
- `npm run build` - TypeScript 빌드
- `npm start` - 프로덕션 서버 실행
- `npm run prisma:generate` - Prisma Client 생성
- `npm run prisma:migrate` - 데이터베이스 마이그레이션
- `npm run prisma:studio` - Prisma Studio 실행
- `npm test` - 테스트 실행

## 🤝 기여하기

버그 리포트 및 기능 제안은 Issue를 통해 부탁드립니다.

## 📄 라이선스

MIT License
