# 💰 1인 개발자를 위한 비용 최적화 가이드

## 📋 목차

1. [개요](#개요)
2. [서비스별 무료 티어 분석](#서비스별-무료-티어-분석)
3. [추천 서비스 조합](#추천-서비스-조합)
4. [예상 비용 계산](#예상-비용-계산)
5. [비용 절감 팁](#비용-절감-팁)

---

## 개요

1인 개발자가 **최소 비용으로 프로덕션 서비스를 운영**할 수 있도록 무료 티어와 종량제 서비스를 중심으로 구성합니다.

### 핵심 원칙

- ✅ **무료 티어 최대 활용** - 서비스 초기 단계에서는 무료로 시작
- ✅ **종량제 우선** - 고정 비용 없이 사용한 만큼만 지불
- ✅ **일정량 무료** - 매월 일정량까지 무료, 초과분만 과금
- ✅ **오픈소스 활용** - 가능한 경우 셀프 호스팅

---

## 서비스별 무료 티어 분석

### 1. 데이터베이스 (Database)

#### 🆓 **Neon (PostgreSQL)** - 추천 ⭐⭐⭐

- **무료 티어**:
  - 0.5 GB 스토리지
  - 10 GB 데이터 전송/월
  - Auto-pause (비활성 시 자동 중지)
  - 무제한 데이터베이스 개수
- **장점**: PostGIS 지원, Serverless, 자동 스케일링
- **과금**: 초과 시 $0.16/GB (스토리지), $0.09/GB (전송량)
- **URL**: https://neon.tech
- **추정 비용**: 0원/월 (사용자 1000명 이하)

#### 🆓 **Supabase (PostgreSQL)** - 대안

- **무료 티어**:
  - 500 MB 데이터베이스
  - 1 GB 파일 스토리지
  - 50,000 MAU (월간 활성 사용자)
  - 2 GB 대역폭
- **장점**: PostGIS 지원, 실시간 구독, 인증 내장
- **과금**: Pro Plan $25/월부터
- **URL**: https://supabase.com
- **추정 비용**: 0원/월 → 25달러/월 (사용자 급증 시)

#### 💰 **AWS RDS Free Tier**

- **무료 티어**: 12개월 한정
  - db.t2.micro (1 vCPU, 1 GB RAM)
  - 20 GB 스토리지
  - 매월 750시간 무료
- **단점**: 1년 후 과금 시작
- **추정 비용**: 0원/월 (12개월) → $15-30/월 (이후)

### 2. 파일 저장소 (File Storage)

#### 🆓 **Cloudflare R2** - 추천 ⭐⭐⭐

- **무료 티어**:
  - 10 GB 스토리지/월
  - Class A: 1백만 요청/월
  - Class B: 10백만 요청/월
  - **무료 송출(Egress)** - S3와 가장 큰 차이점!
- **장점**: S3 호환 API, egress 비용 0원
- **과금**: $0.015/GB (스토리지만 과금)
- **URL**: https://developers.cloudflare.com/r2/
- **추정 비용**: 0원/월 (10GB 이하)

#### 🆓 **Backblaze B2**

- **무료 티어**:
  - 10 GB 스토리지
  - 1 GB 다운로드/일 (30GB/월)
  - 무제한 API 호출
- **장점**: 매우 저렴한 가격
- **과금**: $0.005/GB (스토리지), $0.01/GB (다운로드)
- **URL**: https://www.backblaze.com/b2/cloud-storage.html
- **추정 비용**: 0원/월 (30GB/월 다운로드 이하)

#### 💰 **AWS S3** - 비교용

- **무료 티어**: 12개월 한정
  - 5 GB 스토리지
  - 20,000 GET 요청
  - 2,000 PUT 요청
- **단점**: Egress 비용 높음 ($0.09/GB)
- **추정 비용**: 0원/월 (12개월) → $5-20/월 (이후)

### 3. 캐싱 (Redis)

#### 🆓 **Upstash Redis** - 추천 ⭐⭐⭐

- **무료 티어**:
  - 10,000 명령/일 (300K/월)
  - 256 MB 스토리지
  - 전 세계 여러 리전
- **장점**: Serverless, 사용한 만큼만 과금
- **과금**: $0.2 per 100K 명령 (초과분)
- **URL**: https://upstash.com
- **추정 비용**: 0원/월 (소규모) → $1-5/월 (중규모)

#### 🆓 **Redis Cloud** - 대안

- **무료 티어**:
  - 30 MB 스토리지
  - 30 동시 연결
  - 1개 데이터베이스
- **단점**: 용량이 매우 작음
- **과금**: $5/월부터
- **URL**: https://redis.io/cloud/
- **추정 비용**: 0원/월 → $5/월

### 4. 이메일 서비스

#### 🆓 **Resend** - 추천 ⭐⭐⭐

- **무료 티어**:
  - 3,000 이메일/월
  - 100 이메일/일
  - 커스텀 도메인 지원
  - 높은 전달률
- **장점**: 개발자 친화적 API, 최신 서비스
- **과금**: $20/월 (50,000 이메일)
- **URL**: https://resend.com
- **추정 비용**: 0원/월 (3,000통 이하)

#### 🆓 **SendGrid**

- **무료 티어**:
  - 100 이메일/일 (3,000/월)
  - 2,000 contacts 저장
- **단점**: 무료 플랜에 "via SendGrid" 표시
- **과금**: $19.95/월 (40,000 이메일)
- **URL**: https://sendgrid.com
- **추정 비용**: 0원/월

### 5. SMS 서비스

#### 💰 **Twilio** - 종량제

- **무료 크레딧**: $15.50 (신규 가입 시)
- **과금**:
  - 한국 SMS: $0.0545/건
  - 일본 SMS: $0.0792/건
  - 미국 SMS: $0.0079/건
- **URL**: https://www.twilio.com
- **추정 비용**: $5-20/월 (100-300건 기준)

#### 💰 **한국 전용: Aligo**

- **과금**: 건당 15-20원 (선불 충전)
- **장점**: 한국 특화, 저렴한 가격
- **URL**: https://smartsms.aligo.in
- **추정 비용**: 15,000원/1000건

### 6. 푸시 알림

#### 🆓 **Firebase Cloud Messaging (FCM)** - 추천 ⭐⭐⭐

- **무료 티어**: 완전 무료, 무제한
- **장점**: Google 운영, 안정적, iOS/Android 모두 지원
- **과금**: 없음
- **URL**: https://firebase.google.com/products/cloud-messaging
- **추정 비용**: 0원/월

### 7. 인증 (Authentication)

#### 🆓 **Supabase Auth** - 추천 ⭐⭐⭐

- **무료 티어**:
  - 50,000 MAU
  - 소셜 로그인 (Google, GitHub, 등)
  - JWT 토큰
- **장점**: 데이터베이스와 통합
- **과금**: Pro Plan $25/월
- **URL**: https://supabase.com/auth
- **추정 비용**: 0원/월

#### 🆓 **Firebase Authentication**

- **무료 티어**:
  - 10,000 SMS 인증/월 (무료)
  - 무제한 이메일/소셜 로그인
- **과금**: $0.06/SMS (초과분)
- **URL**: https://firebase.google.com/products/auth
- **추정 비용**: 0원/월 (SMS 미사용 시)

### 8. 호스팅 (Backend)

#### 🆓 **Fly.io** - 추천 ⭐⭐⭐

- **무료 티어**:
  - 3개 shared-cpu-1x VM (256MB RAM)
  - 160 GB 아웃바운드 데이터 전송
  - 3 GB 영구 스토리지
- **장점**: Docker 기반, 글로벌 엣지, 빠른 배포
- **과금**: $0.0000008/초 (추가 VM)
- **URL**: https://fly.io
- **추정 비용**: 0원/월 (소규모)

#### 🆓 **Railway** - 대안

- **무료 티어**: $5 크레딧/월 (신용카드 등록 필요)
  - 약 500시간/월 무료
- **장점**: 간편한 배포, PostgreSQL 포함
- **과금**: $5/월 (Hobby Plan)
- **URL**: https://railway.app
- **추정 비용**: 0원/월 → $5/월

#### 🆓 **Render**

- **무료 티어**:
  - 750시간/월 (1개 인스턴스)
  - 512 MB RAM
  - 비활성 시 자동 종료
- **단점**: Cold start (15초 정도 소요)
- **과금**: $7/월 (Starter Plan)
- **URL**: https://render.com
- **추정 비용**: 0원/월

### 9. 모니터링 & 로깅

#### 🆓 **Sentry** - 추천 ⭐⭐⭐

- **무료 티어**:
  - 5,000 에러 이벤트/월
  - 10,000 퍼포먼스 유닛/월
  - 1 GB 리플레이 스토리지
  - 1명 팀원
- **장점**: 에러 추적, 퍼포먼스 모니터링
- **과금**: $26/월 (50,000 이벤트)
- **URL**: https://sentry.io
- **추정 비용**: 0원/월

#### 🆓 **Better Stack (Logtail)**

- **무료 티어**:
  - 1 GB 로그/월
  - 3일 보관
  - 1개 소스
- **과금**: $8/월 (5 GB)
- **URL**: https://betterstack.com/logtail
- **추정 비용**: 0원/월

### 10. 지도 서비스

#### 🆓 **Google Maps Platform**

- **무료 크레딧**: $200/월
- **커버 범위**:
  - Maps: 28,000회 지도 로드/월
  - Geocoding: 40,000회/월
  - Directions: 40,000회/월
- **과금**: 초과분만 종량제
- **URL**: https://cloud.google.com/maps-platform
- **추정 비용**: 0원/월 (대부분의 경우)

#### 🆓 **Naver Maps (한국 전용)**

- **무료 티어**:
  - Web: 300,000회/일
  - Mobile: 무제한
- **장점**: 한국 지도 데이터 우수
- **과금**: 초과 시 협의
- **URL**: https://www.ncloud.com/product/applicationService/maps
- **추정 비용**: 0원/월

### 11. CDN

#### 🆓 **Cloudflare** - 추천 ⭐⭐⭐

- **무료 티어**:
  - 무제한 트래픽
  - DDoS 방어
  - SSL/TLS 인증서
  - 100개 페이지 규칙
- **장점**: 완전 무료, 글로벌 네트워크
- **과금**: Pro $20/월 (고급 기능)
- **URL**: https://www.cloudflare.com
- **추정 비용**: 0원/월

### 12. Analytics

#### 🆓 **Plausible Analytics** - 추천 ⭐⭐⭐

- **셀프 호스팅**: 완전 무료 (오픈소스)
- **클라우드 버전**: $9/월 (10,000 pageviews)
- **장점**: GDPR 준수, 가벼움, 프라이버시
- **URL**: https://plausible.io
- **추정 비용**: 0원/월 (셀프 호스팅)

#### 🆓 **Umami**

- **셀프 호스팅**: 완전 무료 (오픈소스)
- **클라우드 버전**: $9/월 (100,000 이벤트)
- **URL**: https://umami.is
- **추정 비용**: 0원/월 (셀프 호스팅)

---

## 추천 서비스 조합

### 🥇 완전 무료 스택 (시작 단계)

```
Database: Neon PostgreSQL (무료 티어)
Storage: Cloudflare R2 (10GB 무료)
Cache: Upstash Redis (300K 명령/월 무료)
Email: Resend (3,000통/월 무료)
Push: Firebase FCM (무료 무제한)
Hosting: Fly.io (3 VM 무료)
Monitoring: Sentry (5,000 이벤트/월 무료)
CDN: Cloudflare (무제한 무료)
Analytics: Umami (셀프 호스팅)
Maps: Google Maps ($200 크레딧/월)

💰 총 비용: 0원/월
```

### 🥈 저비용 스택 (성장 단계, 사용자 1,000-5,000명)

```
Database: Neon PostgreSQL (0-10달러/월)
Storage: Cloudflare R2 ($0.5-2/월)
Cache: Upstash Redis ($1-5/월)
Email: Resend ($0-20/월)
SMS: Twilio ($10-30/월, 필요 시만)
Push: Firebase FCM (무료)
Hosting: Fly.io ($5-15/월)
Monitoring: Sentry (무료 티어)
CDN: Cloudflare (무료)
Maps: Google Maps (무료 크레딧 내)

💰 총 비용: $16-82/월 (평균 $30-40/월)
```

### 🥉 프로덕션 스택 (10,000+ 사용자)

```
Database: Supabase Pro ($25/월) 또는 AWS RDS ($30-50/월)
Storage: Cloudflare R2 ($5-10/월)
Cache: Upstash Redis ($5-20/월)
Email: Resend ($20-40/월)
SMS: Twilio ($30-100/월)
Push: Firebase FCM (무료)
Hosting: Fly.io ($20-50/월)
Monitoring: Sentry ($26/월)
CDN: Cloudflare (무료)

💰 총 비용: $130-320/월
```

---

## 예상 비용 계산

### 사용자 규모별 예상 비용

| 항목 | 100명 | 1,000명 | 5,000명 | 10,000명 |
|------|-------|---------|---------|----------|
| **데이터베이스** | $0 | $0-10 | $10-20 | $25-50 |
| **스토리지** | $0 | $0-2 | $2-5 | $5-10 |
| **캐싱** | $0 | $0-2 | $2-10 | $10-20 |
| **이메일** | $0 | $0 | $0-20 | $20-40 |
| **SMS** | $0-5 | $5-10 | $10-30 | $30-100 |
| **호스팅** | $0 | $0-10 | $10-30 | $30-50 |
| **모니터링** | $0 | $0 | $0-26 | $26 |
| **합계** | **$0-5** | **$5-34** | **$34-141** | **$146-296** |

### 결제 수수료 (별도)

- **Stripe**: 3.6% + ¥30 (일본), 3.6% (한국)
- **PayPay**: 1.6-3.24%
- **Toss**: 2.0-2.8%

예: 월 ¥100,000 매출 → 수수료 ¥1,600-3,600

---

## 비용 절감 팁

### 1. 무료 티어 최대 활용

✅ **여러 서비스 분산**
- 이메일: Resend (3,000통) + SendGrid (3,000통) = 6,000통/월 무료

✅ **리전별 계정 분리**
- 일본 계정, 한국 계정, 미국 계정 각각 무료 티어 활용

### 2. Serverless 아키텍처

✅ **사용하지 않을 때는 비용 0원**
- Neon: Auto-pause 기능
- Fly.io: Scale to zero
- Cloudflare Workers

### 3. 캐싱 전략

✅ **Redis로 DB 부하 감소**
- 자주 읽는 데이터 캐싱 (프로필, 매칭 결과)
- API 응답 캐싱 (1분-1시간)
- 세션 스토어

### 4. 이미지 최적화

✅ **Cloudflare Image Resizing** ($5/월)
- 원본 1개만 저장
- 온디맨드 리사이징
- WebP 자동 변환

### 5. 모니터링으로 비용 추적

✅ **사용량 알림 설정**
- Upstash: 일일 명령 수 모니터링
- Cloudflare R2: 스토리지 사용량 추적
- Sentry: 이벤트 수 확인

### 6. 사용자 증가 시 대응 전략

#### 단계 1: 0-1,000명 (무료)
```
- 모든 무료 티어 활용
- 비용: $0-5/월
```

#### 단계 2: 1,000-5,000명 (저비용)
```
- 핵심 서비스만 유료 전환 (DB, 호스팅)
- 비용: $20-50/월
```

#### 단계 3: 5,000-10,000명 (성장)
```
- 캐싱 강화 (Redis Pro)
- 이메일/SMS 예산 확보
- 비용: $100-200/월
```

#### 단계 4: 10,000명+ (스케일)
```
- 전용 서버 고려 (AWS, GCP)
- 또는 계속 Serverless 유지
- 비용: $200-500/월
```

---

## 권장 시작 설정

### Phase 1: MVP 단계 (완전 무료)

```env
# Database: Neon PostgreSQL
DATABASE_URL="postgresql://user:password@xxx.neon.tech/marriage_matching"

# Storage: Cloudflare R2
STORAGE_TYPE="r2"
R2_ACCOUNT_ID="your-account-id"
R2_ACCESS_KEY_ID="your-access-key"
R2_SECRET_ACCESS_KEY="your-secret-key"
R2_BUCKET_NAME="marriage-matching-images"
R2_PUBLIC_URL="https://pub-xxx.r2.dev"

# Cache: Upstash Redis
REDIS_URL="redis://default:xxx@xxx.upstash.io:6379"

# Email: Resend
RESEND_API_KEY="re_xxx"

# Push: Firebase FCM
FCM_SERVER_KEY="your-fcm-server-key"
FCM_PROJECT_ID="your-firebase-project-id"

# Monitoring: Sentry
SENTRY_DSN="https://xxx@xxx.ingest.sentry.io/xxx"

# Maps: Google Maps
GOOGLE_MAPS_API_KEY="your-google-maps-api-key"
```

### Phase 2: 성장 단계 (저비용)

위 설정 + 추가:

```env
# SMS: Twilio (필요 시)
TWILIO_ACCOUNT_SID="your-account-sid"
TWILIO_AUTH_TOKEN="your-auth-token"

# Analytics: Umami (셀프 호스팅)
UMAMI_TRACKING_ID="your-tracking-id"
```

---

## 체크리스트

### 서비스 가입 전 확인사항

- [ ] 무료 티어 제한 확인
- [ ] 과금 시작 조건 확인
- [ ] 신용카드 등록 여부 확인
- [ ] 사용량 알림 설정 가능 여부
- [ ] 데이터 Export 가능 여부 (서비스 이전 시)

### 비용 발생 모니터링

- [ ] 주간 사용량 리포트 확인
- [ ] 월말 전 사용량 검토
- [ ] 무료 티어 초과 전 알림 받기
- [ ] 대안 서비스 미리 조사

---

**마지막 업데이트**: 2025-12-31

**참고**: 무료 티어 정책은 변경될 수 있으니 공식 웹사이트에서 최신 정보를 확인하세요.
