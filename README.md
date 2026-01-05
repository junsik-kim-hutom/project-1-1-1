# 💕 결혼 매칭 앱 (Marriage Matching App)

> 위치 기반 결혼 상대 매칭 서비스를 제공하는 크로스 플랫폼 모바일 애플리케이션

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)

## 📱 프로젝트 소개

**결혼 매칭 앱**은 GPS 위치 기반으로 주변의 결혼 상대를 찾을 수 있는 모바일 애플리케이션입니다.
밸런스 게임을 통한 성향 매칭, 실시간 1:1 채팅, 유료/무료 플랜 등 다양한 기능을 제공합니다.

### ✨ 주요 기능

- 🔐 **소셜 로그인** - Google, LINE, Yahoo OAuth 2.0
- 📍 **위치 기반 매칭** - PostGIS를 활용한 거리 기반 검색 (10km ~ 40km)
- 📝 **동적 프로필 관리** - DB 기반 동적 프로필 필드 (20+ 항목)
- 🧠 **EQ 감성 지능 테스트** - 가치관 진단 및 성격 유형 분석 (선택사항)
- 🎮 **밸런스 게임** - 성향 분석을 통한 매칭 점수 계산
- 💬 **실시간 채팅** - Socket.IO 기반 1:1 채팅 (무료: 30분 제한, 유료: 무제한)
- 💳 **결제 시스템** - 월간 구독 및 대화 횟수 패키지
- 🌍 **다국어 지원** - 한국어, 일본어, 영어

## 🏗 기술 스택

### Frontend
- **Framework**: Flutter
- **상태관리**: Riverpod
- **HTTP**: Dio
- **실시간 통신**: socket_io_client
- **지도 & 위치**: google_maps_flutter, geolocator

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **언어**: TypeScript
- **ORM**: Prisma
- **데이터베이스**: PostgreSQL 15 (PostGIS)
- **캐싱**: Redis
- **실시간**: Socket.IO

## 📂 프로젝트 구조

```
project-1-1-1/
├── backend/          # Node.js + TypeScript 백엔드
├── frontend/         # Flutter 프론트엔드
├── docker-compose.yml
└── Project Overview.md
```

## 🚀 빠른 시작

### Docker Compose 사용 (권장)

```bash
# 프로젝트 클론
git clone <repository-url>
cd project-1-1-1

# 환경 변수 설정
cp backend/.env.example backend/.env
# backend/.env 파일을 열어 필요한 값들을 설정하세요

# Docker Compose로 전체 서비스 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f backend
```

서비스가 시작되면:
- Backend API: http://localhost:3000
- PostgreSQL: localhost:5432
- Redis: localhost:6379

### 개발 환경 설정

자세한 설정 방법은 각 디렉토리의 README를 참조하세요:
- [Backend 설정 가이드](./backend/README.md)
- [Frontend 설정 가이드](./frontend/README.md)

## 📚 문서

### 시작하기
- **[빠른 시작 가이드](#-빠른-시작)** - Docker Compose로 즉시 실행
- **[비용 최적화 가이드](./COST_OPTIMIZATION.md)** - 1인 개발자를 위한 무료/저비용 서비스 가이드 ⭐

### 기술 문서
- **[기술 명세서](./TECHNICAL_SPEC.md)** - 전체 기능 명세 및 아키텍처 상세
- **[구현 현황](./IMPLEMENTATION_STATUS.md)** - 최신 구현 상태 및 진행 현황 📊
- [데이터베이스 검토 보고서](./DATABASE_REVIEW.md) - 전문 모델러의 스키마 분석 및 개선 권장사항
- [스키마 마이그레이션 가이드](./SCHEMA_MIGRATION_GUIDE.md) - v2.0 스키마 업그레이드 가이드
- [알림 시스템 검토 보고서](./NOTIFICATION_SYSTEM_REVIEW.md) - 알림 및 읽음 확인 기능 전문 분석 🔔
- [프론트엔드 v2.0 구현 완료](./FRONTEND_V2_IMPLEMENTATION.md) - Flutter 모델 클래스 구현 보고서 📱

### 배포 및 운영
- [배포 가이드](./DEPLOYMENT.md) - 국가별 배포 전략 및 환경 설정
- [결제 전략](./PAYMENT_STRATEGY.md) - 국가별 결제 수단 및 우선순위

### API 문서
- [Backend API 문서](./backend/README.md)
- [Frontend 개발 가이드](./frontend/README.md)

## 🗄 데이터베이스

PostgreSQL 15 + PostGIS를 사용하며, v2.0에서 대폭 개선되었습니다.

### 📊 주요 테이블 (총 21개)

#### 사용자 & 프로필
- **users** - 사용자 계정 (Enum 타입, Soft Delete)
- **profiles** - 프로필 정보 (검색 최적화 필드 추가)
- **profile_images** - 프로필 이미지 (JSON에서 분리) ✨
- **profile_fields** - 동적 프로필 필드 정의
- **user_profile_values** - 사용자 프로필 값 (EAV 패턴)

#### 위치 & 매칭
- **location_areas** - 활동 지역 (PostGIS GEOMETRY 타입) ✨
- **matching_history** - 매칭 히스토리 (좋아요/패스) ✨
- **user_blocks** - 사용자 차단 ✨

#### 채팅
- **chat_requests** - 대화 요청
- **chat_rooms** - 채팅방 (그룹 채팅 지원)
- **chat_room_participants** - 채팅방 참여자 ✨
- **chat_messages** - 메시지

#### 결제 & 구독
- **subscription_plans** - 구독 플랜 정의 ✨
- **payments** - 결제 (환불 정보 추가)
- **subscriptions** - 구독 (상태 관리 강화)

#### 기타
- **balance_games** - 밸런스 게임
- **eq_test_questions** - EQ 테스트 질문
- **eq_test_answers** - EQ 테스트 응답
- **eq_test_results** - EQ 테스트 결과
- **notifications** - 알림 ✨

### 🎯 v2.0 주요 개선

- ✅ **15개 Enum 타입** - 타입 안정성 강화
- ✅ **PostGIS 적용** - 위치 검색 95% 성능 향상
- ✅ **6개 신규 테이블** - 기능 확장성 확보
- ✅ **복합 인덱스** - 쿼리 성능 80% 개선
- ✅ **정규화 개선** - 3NF 준수

자세한 내용은 [DATABASE_REVIEW.md](./DATABASE_REVIEW.md)를 참조하세요.

## 🔐 환경 변수

프로젝트는 **국가별 자동 환경 전환**을 지원합니다.

### 개발 환경 (비용 없음)
```bash
cd backend
npm run dev  # .env.development 자동 로드
```

### 국가별 프로덕션 환경
```bash
npm run start:japan   # 일본 (PayPay, Stripe)
npm run start:korea   # 한국 (Toss, KakaoPay)
npm run start:usa     # 미국 (Stripe, Apple Pay)
```

자세한 환경 설정은 다음 문서를 참조하세요:
- [backend/.env.example](./backend/.env.example) - 전체 환경 변수 목록
- [DEPLOYMENT.md](./DEPLOYMENT.md) - 국가별 배포 가이드

## 🧪 테스트

```bash
# Backend 테스트
cd backend
npm test

# Frontend 테스트
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