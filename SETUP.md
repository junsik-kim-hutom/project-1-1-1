# 🚀 프로젝트 설정 가이드

## 필수 준비사항

### Backend
- Node.js 18 이상
- PostgreSQL 15 이상 (PostGIS extension)
- Redis (선택사항)

### Frontend
- Flutter 3.0 이상
- Android Studio / Xcode (모바일 개발용)

## 1️⃣ Backend 설정

```bash
# 1. Backend 디렉토리로 이동
cd backend

# 2. 의존성 설치
npm install

# 3. 환경 변수 설정
# 개발 환경은 이미 준비되어 있습니다 (비용 발생 없음)
# .env.development 파일이 자동으로 사용됩니다

# 4. PostgreSQL에 PostGIS extension 활성화
psql -U postgres
CREATE DATABASE marriage_matching;
\c marriage_matching
CREATE EXTENSION IF NOT EXISTS postgis;
\q

# 5. Prisma 설정
npm run prisma:generate
npm run prisma:migrate

# 6. 개발 서버 실행
npm run dev

# 특정 국가 환경으로 테스트하고 싶다면:
# npm run dev:japan   # 일본 환경
# npm run dev:korea   # 한국 환경
# npm run dev:usa     # 미국 환경
```

Backend는 http://localhost:3000 에서 실행됩니다.

### 국가별 환경 설정

프로젝트는 국가별로 자동으로 환경을 전환합니다:

- **개발 환경** (`.env.development`): Mock 결제, 로컬 저장소 - 비용 없음
- **일본 환경** (`.env.japan`): PayPay, Stripe, AWS Tokyo
- **한국 환경** (`.env.korea`): Toss, KakaoPay, AWS Seoul
- **미국 환경** (`.env.usa`): Stripe, Apple Pay, AWS US East

자세한 배포 가이드는 [DEPLOYMENT.md](./DEPLOYMENT.md)를 참조하세요.

## 2️⃣ Frontend 설정

```bash
# 1. Frontend 디렉토리로 이동
cd frontend

# 2. 의존성 설치
flutter pub get

# 3. 코드 생성 (localization 등)
flutter gen-l10n

# 4. 앱 실행 (iOS 시뮬레이터 / Android 에뮬레이터)
flutter run
```

## 3️⃣ Docker Compose 사용 (권장)

전체 서비스를 한 번에 실행:

```bash
# 프로젝트 루트에서
docker-compose up -d

# 로그 확인
docker-compose logs -f backend
```

## 📝 현재 구현 상태

### ✅ 완료된 기능
- 모던한 UI/UX 디자인 시스템
- 로그인 화면 (Google OAuth 준비)
- 메인 네비게이션
- 홈 화면
- 매칭 화면 (Tinder 스타일 카드)
- 채팅 리스트
- 프로필 화면
- EQ 테스트 백엔드 API
- 동적 프로필 필드 시스템

### 🚧 TODO (구현 필요)
1. Backend API 연동
2. 실제 데이터 로딩
3. 실시간 채팅 Socket.IO 연결
4. 위치 기반 검색 구현
5. 이미지 업로드
6. 결제 시스템 연동

## 🔧 문제 해결

### Backend 의존성 오류
```bash
cd backend
rm -rf node_modules package-lock.json
npm install
```

### Flutter 빌드 오류
```bash
cd frontend
flutter clean
flutter pub get
flutter pub cache repair
```

### Prisma 관련 오류
```bash
cd backend
npm run prisma:generate
npx prisma migrate reset
```

## 📚 추가 문서

- [Backend API 문서](./backend/README.md)
- [Frontend 개발 가이드](./frontend/README.md)
- [프로젝트 상세 명세](./Project%20Overview.md)

## 🆘 지원

문제가 발생하면 각 폴더의 README.md를 참조하거나 Issues를 생성해주세요.
