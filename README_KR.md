# 결혼 매칭 앱 (Marriage Matching App)

위치 기반 결혼 상대 매칭 서비스를 제공하는 크로스 플랫폼 모바일 애플리케이션입니다.

## 📋 프로젝트 개요

이 프로젝트는 위치 기반으로 결혼 상대를 찾을 수 있는 모바일 애플리케이션입니다. Flutter를 사용한 크로스 플랫폼 프론트엔드와 Node.js(TypeScript) 기반의 백엔드로 구성되어 있습니다.

## 🛠 기술 스택

### Frontend
- **Framework**: Flutter
- **상태관리**: Riverpod
- **HTTP 통신**: Dio
- **소켓 통신**: socket_io_client
- **지도**: google_maps_flutter
- **위치**: geolocator, geocoding
- **인증**: Google Sign-In

### Backend
- **Framework**: Node.js + Express.js
- **언어**: TypeScript
- **실시간 통신**: Socket.IO
- **ORM**: Prisma
- **데이터베이스**: PostgreSQL (with PostGIS)
- **캐싱**: Redis
- **인증**: JWT, Google OAuth 2.0

### Infrastructure
- **컨테이너**: Docker, Docker Compose
- **데이터베이스**: PostgreSQL 15 with PostGIS

## 🚀 시작하기

### 사전 요구사항

- Node.js 18+
- Flutter 3.0+
- Docker & Docker Compose
- PostgreSQL 15+ (or use Docker)
- Redis (or use Docker)

### 백엔드 설정

1. 백엔드 디렉토리로 이동:
```bash
cd backend
```

2. 환경 변수 설정:
```bash
cp .env.example .env
# .env 파일을 열어 필요한 값들을 설정하세요
```

3. 의존성 설치:
```bash
npm install
```

4. Prisma 마이그레이션 실행:
```bash
npm run prisma:migrate
npm run prisma:generate
```

5. 개발 서버 실행:
```bash
npm run dev
```

### 프론트엔드 설정

1. 프론트엔드 디렉토리로 이동:
```bash
cd frontend
```

2. 의존성 설치:
```bash
flutter pub get
```

3. 앱 실행:
```bash
flutter run
```

### Docker로 실행하기

프로젝트 루트 디렉토리에서:

```bash
# 모든 서비스 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 서비스 중지
docker-compose down
```

## 📁 프로젝트 구조

```
project-1-1-1/
├── backend/                 # Node.js 백엔드
│   ├── src/
│   │   ├── config/         # 설정 파일
│   │   ├── modules/        # 기능별 모듈
│   │   │   ├── auth/       # 인증
│   │   │   ├── profile/    # 프로필
│   │   │   ├── chat/       # 채팅
│   │   │   ├── matching/   # 매칭
│   │   │   └── payment/    # 결제
│   │   ├── common/         # 공통 유틸리티
│   │   ├── socket/         # Socket.IO
│   │   └── app.ts          # 앱 진입점
│   ├── prisma/             # Prisma 스키마
│   └── package.json
│
├── frontend/               # Flutter 프론트엔드
│   ├── lib/
│   │   ├── core/          # 코어 기능
│   │   ├── features/      # 기능별 모듈
│   │   │   ├── auth/      # 인증
│   │   │   ├── profile/   # 프로필
│   │   │   ├── chat/      # 채팅
│   │   │   ├── matching/  # 매칭
│   │   │   └── payment/   # 결제
│   │   └── shared/        # 공유 컴포넌트
│   └── pubspec.yaml
│
├── docker-compose.yml     # Docker Compose 설정
├── Project Overview.md    # 프로젝트 상세 명세
└── README.md
```

## 🔑 핵심 기능

### 1. 인증 및 회원가입
- Google OAuth 2.0 소셜 로그인
- LINE, Yahoo 로그인 (준비 중)
- JWT 기반 토큰 인증
- 자동 Refresh Token 갱신

### 2. 프로필 관리
- 필수 프로필 정보 입력
- 사진 업로드 (최대 6장)
- 자기소개 및 관심사 태그
- 프로필 수정 및 삭제

### 3. 위치 기반 기능
- GPS를 통한 현재 위치 확인
- 활동 지역 설정 (최대 2개)
- 반경 설정 (10km, 20km, 30km, 40km)
- 30일마다 위치 재인증

### 4. 매칭 시스템
- 거리 기반 매칭
- 나이, 키, 학력, 직업 등 필터링
- 밸런스 게임을 통한 성향 매칭
- 매칭 점수 알고리즘

### 5. 채팅 시스템
- 실시간 1:1 채팅 (Socket.IO)
- 타이핑 인디케이터
- 읽음 표시
- 무료 사용자: 30분 시간 제한
- 유료 사용자: 무제한

### 6. 결제 시스템
- 월간 구독
- 대화 횟수 패키지
- 신용카드, 앱 내 결제

## 🔐 환경 변수

백엔드 `.env` 파일에 다음 항목들을 설정해야 합니다:

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/marriage_matching

# JWT
JWT_SECRET=your-secret-key
JWT_REFRESH_SECRET=your-refresh-secret-key

# OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Server
PORT=3000
NODE_ENV=development
```

## 📝 API 문서

### 인증 API
- `POST /api/auth/google` - Google 로그인
- `POST /api/auth/refresh` - 토큰 갱신
- `POST /api/auth/logout` - 로그아웃

### 프로필 API
- `POST /api/profile` - 프로필 생성
- `PUT /api/profile` - 프로필 수정
- `GET /api/profile/me` - 내 프로필 조회
- `GET /api/profile/:userId` - 특정 사용자 프로필 조회
- `DELETE /api/profile` - 프로필 삭제

### Socket.IO 이벤트
- `connection` - 소켓 연결
- `chat:send` - 메시지 전송
- `chat:receive` - 메시지 수신
- `chat:typing` - 타이핑 중
- `chat:read` - 메시지 읽음

## 🧪 테스트

```bash
# 백엔드 테스트
cd backend
npm test

# 프론트엔드 테스트
cd frontend
flutter test
```

## 📱 지원 플랫폼

- iOS 13.0+
- Android 5.0+ (API Level 21+)

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

MIT License

## 👨‍💻 개발자

김준식

## 🙏 감사의 말

이 프로젝트는 위치 기반 매칭 서비스의 가능성을 탐구하기 위해 만들어졌습니다.
