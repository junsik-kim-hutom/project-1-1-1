# 데이터베이스 스키마 전문 검토 보고서

## 📋 목차

1. [전체 평가 요약](#전체-평가-요약)
2. [정규화 분석](#정규화-분석)
3. [확장성 분석](#확장성-분석)
4. [성능 분석](#성능-분석)
5. [보안 및 무결성](#보안-및-무결성)
6. [개선 권장사항](#개선-권장사항)
7. [테이블별 상세 분석](#테이블별-상세-분석)

---

## 전체 평가 요약

### ✅ 장점

1. **EAV 패턴 적용** - 동적 프로필 필드 관리 (ProfileField, UserProfileValue)
2. **다국어 지원 설계** - JSON 타입으로 ko/ja/en 지원
3. **인덱스 전략 양호** - 주요 외래키 및 검색 필드에 인덱스 설정
4. **Soft Delete 미사용** - 실제 삭제 + Cascade 설정으로 데이터 정합성 유지
5. **PostGIS 확장** - 위치 기반 기능을 위한 올바른 선택

### ⚠️ 개선 필요 사항

1. **정규화 위반** - User.authProviderId와 Profile 중복 가능성
2. **확장성 제약** - LocationArea의 PostGIS 미사용
3. **누락된 테이블** - SubscriptionPlan, ChatRoomParticipant, MatchingHistory
4. **JSON 남용** - 검색/필터링이 필요한 데이터를 JSON으로 저장
5. **타임스탬프 누락** - 일부 테이블에 deletedAt, archivedAt 부재
6. **제약조건 부족** - CHECK 제약, Enum 타입 미사용

---

## 정규화 분석

### 1NF (제1정규형) - ✅ 준수

모든 컬럼이 원자값을 가짐. 다만 일부 우려사항:

**⚠️ Profile.profileImages (JSON 배열)**
```prisma
profileImages Json? @map("profile_images") // ["url1", "url2", ...]
```

**문제점**:
- 배열 내 특정 이미지 검색 불가
- 이미지 순서, 타입(메인/서브), 승인 상태 관리 어려움

**권장**:
```prisma
model ProfileImage {
  id         String   @id @default(uuid())
  profileId  String
  imageUrl   String
  imageType  String   // 'main', 'sub'
  displayOrder Int
  isApproved Boolean  @default(false)
  uploadedAt DateTime @default(now())

  profile Profile @relation(fields: [profileId], references: [id])

  @@index([profileId])
}
```

### 2NF (제2정규형) - ✅ 준수

모든 비키 속성이 기본키에 완전 함수 종속.

### 3NF (제3정규형) - ⚠️ 부분 위반

**문제 1: Payment.planId (문자열)**
```prisma
model Payment {
  planId String @map("plan_id")
  amount Decimal
  currency String
}
```

**문제점**:
- planId가 문자열이지만 Plan 테이블 없음
- 플랜 정보(이름, 가격, 기간)가 어디에도 저장 안 됨
- 가격 변경 시 히스토리 추적 불가

**권장**:
```prisma
model SubscriptionPlan {
  id          String  @id @default(uuid())
  planKey     String  @unique // 'basic_monthly', 'premium_monthly'
  name        Json    // {"ko": "베이직", "ja": "ベーシック"}
  price       Decimal
  currency    String
  duration    Int     // 일 단위
  features    Json    // 플랜별 기능
  isActive    Boolean @default(true)
  createdAt   DateTime @default(now())

  payments      Payment[]
  subscriptions Subscription[]
}
```

**문제 2: User.lastLoginAt vs. 별도 LoginHistory**

현재는 마지막 로그인만 저장. 보안/분석 관점에서 부족.

**권장**:
```prisma
model LoginHistory {
  id         String   @id @default(uuid())
  userId     String
  ipAddress  String
  userAgent  String
  loginAt    DateTime @default(now())
  logoutAt   DateTime?

  user User @relation(fields: [userId], references: [id])

  @@index([userId])
  @@index([loginAt])
}
```

### BCNF (보이스-코드 정규형) - ✅ 준수

---

## 확장성 분석

### ⭐ 우수한 확장성

#### 1. EAV 패턴 (ProfileField + UserProfileValue)
```prisma
model ProfileField {
  fieldKey String @unique
  fieldType String
  options Json?
}

model UserProfileValue {
  userId  String
  fieldId String
  value   Json
}
```

**장점**:
- 프로필 필드 동적 추가 가능
- 코드 변경 없이 새 항목 추가
- 국가별 다른 필드 세트 구성 가능

**단점**:
- 조인 성능 저하 (필드 10개 = 10번 조인)
- JSON value 검색 비효율
- 타입 안정성 부족

**개선안**: 자주 검색되는 필드는 Profile 테이블에 직접 추가
```prisma
model Profile {
  // 자주 검색/필터링되는 필드
  age           Int?
  height        Int?
  occupation    String?
  income        String?

  // 나머지는 EAV로
  profileValues UserProfileValue[]
}
```

#### 2. 다국어 지원 (JSON)
```prisma
question Json // {"ko": "질문", "ja": "質問", "en": "Question"}
```

**장점**:
- 새 언어 추가 용이
- 번역 관리 간편

**단점**:
- 특정 언어로 검색 불가
- 번역 누락 검증 어려움
- 인덱싱 불가

**개선안**: 검색이 필요한 경우 별도 Translation 테이블
```prisma
model Translation {
  id          String @id @default(uuid())
  entityType  String // 'profile_field', 'balance_game'
  entityId    String
  locale      String // 'ko', 'ja', 'en'
  field       String // 'label', 'question'
  value       String @db.Text

  @@unique([entityType, entityId, locale, field])
  @@index([entityType, locale])
}
```

### ⚠️ 확장성 제약

#### 1. LocationArea - PostGIS 미활용
```prisma
model LocationArea {
  latitude  Float
  longitude Float
  radius    Int
}
```

**문제점**:
- PostGIS 확장 선언만 하고 실제 사용 안 함
- GEOMETRY 타입 미사용
- 공간 인덱스 없음
- 거리 계산 비효율

**권장**:
```prisma
model LocationArea {
  id        String @id @default(uuid())
  userId    String
  location  Unsupported("geometry(Point, 4326)") // PostGIS Point
  address   String
  radius    Int
  isPrimary Boolean @default(false)

  @@index([location], type: Gist) // 공간 인덱스
}
```

SQL 예시:
```sql
-- 거리 계산
SELECT * FROM location_areas
WHERE ST_DWithin(
  location,
  ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
  radius
);
```

#### 2. ChatRoom - 참여자 확장 불가
```prisma
model ChatRoom {
  user1Id String
  user2Id String

  @@unique([user1Id, user2Id])
}
```

**문제점**:
- 1:1 채팅만 가능
- 그룹 채팅 확장 불가
- 관리자/중재자 추가 불가

**권장**:
```prisma
model ChatRoom {
  id        String @id @default(uuid())
  roomType  String @default("direct") // 'direct', 'group'
  name      String?

  participants ChatRoomParticipant[]
  messages     ChatMessage[]
}

model ChatRoomParticipant {
  id        String   @id @default(uuid())
  roomId    String
  userId    String
  role      String   @default("member") // 'owner', 'admin', 'member'
  joinedAt  DateTime @default(now())
  leftAt    DateTime?

  room ChatRoom @relation(fields: [roomId], references: [id])
  user User     @relation(fields: [userId], references: [id])

  @@unique([roomId, userId])
  @@index([userId])
}
```

#### 3. Subscription - 플랜 정보 누락
```prisma
model Subscription {
  planId String // 어디서 정의?
}
```

**문제점**:
- SubscriptionPlan 테이블 없음
- 플랜 변경 히스토리 없음
- 가격 변동 추적 불가

---

## 성능 분석

### ✅ 잘된 인덱싱

```prisma
// User
@@index([email])
@@index([status])

// Profile
@@index([gender])
@@index([birthDate])

// ChatMessage
@@index([createdAt(sort: Desc)]) // 최신순 정렬
```

### ⚠️ 누락된 인덱스

#### 1. 복합 인덱스 필요
```prisma
model ChatRequest {
  receiverId String
  status     String
  expiresAt  DateTime

  // 현재: 각각 단일 인덱스
  @@index([receiverId])
  @@index([status])
  @@index([expiresAt])

  // 권장: 복합 인덱스 추가
  @@index([receiverId, status, expiresAt])
}
```

**이유**: "내가 받은 pending 요청" 쿼리가 빈번함

#### 2. JSON 필드 인덱싱
```prisma
model UserProfileValue {
  value Json // 검색 불가!
}
```

**문제**: 나이 20-30세, 연봉 5000만원 이상 필터링 불가

**해결책**:
```sql
-- PostgreSQL GIN 인덱스
CREATE INDEX idx_user_profile_value_gin ON user_profile_values USING GIN (value);

-- 또는 Generated Column
ALTER TABLE user_profile_values
ADD COLUMN value_text TEXT GENERATED ALWAYS AS (value->>'text') STORED;
CREATE INDEX idx_value_text ON user_profile_values(value_text);
```

#### 3. 파티셔닝 고려 (확장 시)
```sql
-- ChatMessage 테이블 월별 파티셔닝
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY,
  created_at TIMESTAMP NOT NULL,
  ...
) PARTITION BY RANGE (created_at);

CREATE TABLE chat_messages_2025_01 PARTITION OF chat_messages
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

### 🚀 쿼리 최적화 권장

#### N+1 문제 예방
```typescript
// ❌ N+1 발생
const users = await prisma.user.findMany();
for (const user of users) {
  const profile = await prisma.profile.findUnique({
    where: { userId: user.id }
  });
}

// ✅ 해결
const users = await prisma.user.findMany({
  include: { profile: true }
});
```

#### 매칭 쿼리 최적화
```sql
-- 현재: 매칭 점수 계산이 비효율적
-- 권장: Materialized View

CREATE MATERIALIZED VIEW user_matching_scores AS
SELECT
  u1.id as user_id,
  u2.id as target_user_id,
  calculate_match_score(u1.id, u2.id) as score
FROM users u1
CROSS JOIN users u2
WHERE u1.id != u2.id;

CREATE INDEX idx_matching_scores ON user_matching_scores(user_id, score DESC);

-- 주기적 갱신
REFRESH MATERIALIZED VIEW user_matching_scores;
```

---

## 보안 및 무결성

### ✅ 잘된 점

1. **Cascade 삭제**
```prisma
user User @relation(fields: [userId], references: [id], onDelete: Cascade)
```

2. **Unique 제약**
```prisma
@@unique([authProvider, authProviderId])
@@unique([userId, fieldId])
```

### ⚠️ 개선 필요

#### 1. Enum 타입 미사용
```prisma
// 현재: 문자열 (오타 가능)
status String @default("active") // 'active', 'suspended', 'deleted'

// 권장: Enum
enum UserStatus {
  ACTIVE
  SUSPENDED
  DELETED
}

model User {
  status UserStatus @default(ACTIVE)
}
```

#### 2. CHECK 제약 누락
```prisma
model LocationArea {
  latitude  Float // -90 ~ 90 검증 없음
  longitude Float // -180 ~ 180 검증 없음
  radius    Int   // 음수 가능?
}
```

**권장**:
```sql
ALTER TABLE location_areas
ADD CONSTRAINT check_latitude CHECK (latitude BETWEEN -90 AND 90),
ADD CONSTRAINT check_longitude CHECK (longitude BETWEEN -180 AND 180),
ADD CONSTRAINT check_radius CHECK (radius > 0 AND radius <= 50000);
```

#### 3. 민감 정보 암호화
```prisma
model User {
  email String @unique // 평문 저장
}

model Profile {
  birthDate DateTime @db.Date // 평문 저장
}
```

**권장**:
- Email: 해시 인덱스 + 암호화
- BirthDate: 나이만 계산하여 노출
- 개인정보 접근 로그 테이블 추가

```prisma
model DataAccessLog {
  id          String   @id @default(uuid())
  accessorId  String   // 누가
  targetId    String   // 누구의
  dataType    String   // 어떤 데이터를
  action      String   // 조회/수정/삭제
  ipAddress   String
  accessedAt  DateTime @default(now())

  @@index([targetId, accessedAt])
}
```

---

## 개선 권장사항

### 🔴 높은 우선순위 (즉시)

#### 1. SubscriptionPlan 테이블 추가
```prisma
model SubscriptionPlan {
  id          String   @id @default(uuid())
  planKey     String   @unique
  name        Json
  description Json
  price       Decimal  @db.Decimal(10, 2)
  currency    String
  durationDays Int
  features    Json
  maxChatRooms Int?
  unlimitedChat Boolean @default(false)
  isActive    Boolean  @default(true)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  payments      Payment[]
  subscriptions Subscription[]

  @@index([isActive])
  @@map("subscription_plans")
}
```

#### 2. LocationArea PostGIS 적용
```prisma
model LocationArea {
  id        String                              @id @default(uuid())
  userId    String
  location  Unsupported("geometry(Point, 4326)")
  address   String
  radius    Int
  isPrimary Boolean                              @default(false)
  verifiedAt DateTime
  createdAt DateTime                             @default(now())
  updatedAt DateTime                             @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@index([location], type: Gist)
  @@map("location_areas")
}
```

#### 3. Enum 타입 도입
```prisma
enum UserStatus {
  ACTIVE
  SUSPENDED
  DELETED
}

enum Gender {
  MALE
  FEMALE
  OTHER
}

enum ChatRequestStatus {
  PENDING
  ACCEPTED
  REJECTED
  EXPIRED
}

enum PaymentStatus {
  PENDING
  COMPLETED
  FAILED
  REFUNDED
}

enum MessageType {
  TEXT
  IMAGE
  SYSTEM
}
```

### 🟡 중간 우선순위 (1-2주 내)

#### 4. MatchingHistory 테이블 추가
```prisma
model MatchingHistory {
  id            String   @id @default(uuid())
  userId        String
  targetUserId  String
  matchScore    Int      // 0-100
  action        String   // 'like', 'pass', 'super_like'
  viewedProfile Boolean  @default(false)
  viewDuration  Int?     // 초 단위
  createdAt     DateTime @default(now())

  user   User @relation("MatchingUser", fields: [userId], references: [id])
  target User @relation("MatchingTarget", fields: [targetUserId], references: [id])

  @@unique([userId, targetUserId])
  @@index([userId, createdAt])
  @@index([targetUserId])
  @@index([action])
  @@map("matching_history")
}
```

#### 5. ProfileImage 테이블 분리
```prisma
model ProfileImage {
  id           String   @id @default(uuid())
  profileId    String
  imageUrl     String
  thumbnailUrl String?
  imageType    String   // 'main', 'sub'
  displayOrder Int      @default(0)
  isApproved   Boolean  @default(false)
  approvedBy   String?
  approvedAt   DateTime?
  uploadedAt   DateTime @default(now())

  profile Profile @relation(fields: [profileId], references: [id], onDelete: Cascade)

  @@index([profileId])
  @@index([isApproved])
  @@map("profile_images")
}
```

#### 6. UserBlock 테이블 추가
```prisma
model UserBlock {
  id         String   @id @default(uuid())
  userId     String   // 차단한 사람
  blockedUserId String // 차단된 사람
  reason     String?
  createdAt  DateTime @default(now())

  user    User @relation("BlockingUser", fields: [userId], references: [id])
  blocked User @relation("BlockedUser", fields: [blockedUserId], references: [id])

  @@unique([userId, blockedUserId])
  @@index([userId])
  @@index([blockedUserId])
  @@map("user_blocks")
}
```

### 🟢 낮은 우선순위 (필요 시)

#### 7. Notification 테이블
```prisma
model Notification {
  id        String   @id @default(uuid())
  userId    String
  type      String   // 'match', 'message', 'like', 'system'
  title     String
  message   String   @db.Text
  data      Json?    // 추가 데이터
  isRead    Boolean  @default(false)
  readAt    DateTime?
  createdAt DateTime @default(now())

  user User @relation(fields: [userId], references: [id])

  @@index([userId, isRead])
  @@index([createdAt])
  @@map("notifications")
}
```

#### 8. AdminUser 테이블
```prisma
model AdminUser {
  id           String   @id @default(uuid())
  username     String   @unique
  passwordHash String
  role         String   // 'super_admin', 'moderator', 'support'
  permissions  Json
  isActive     Boolean  @default(true)
  lastLoginAt  DateTime?
  createdAt    DateTime @default(now())

  @@index([username])
  @@index([role])
  @@map("admin_users")
}
```

---

## 테이블별 상세 분석

### User 테이블 ⭐⭐⭐⭐☆

**장점**:
- UUID 기본키
- 복합 unique 제약 (authProvider + authProviderId)
- 적절한 인덱싱

**개선**:
```prisma
model User {
  id              String    @id @default(uuid())
  email           String    @unique
  emailVerified   Boolean   @default(false) // ✨ 추가
  phoneNumber     String?   @unique // ✨ 추가
  phoneVerified   Boolean   @default(false) // ✨ 추가
  authProvider    String
  authProviderId  String
  status          UserStatus @default(ACTIVE) // ✨ Enum
  lastLoginAt     DateTime?
  lastLoginIp     String? // ✨ 추가
  loginCount      Int       @default(0) // ✨ 추가
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  deletedAt       DateTime? // ✨ Soft delete

  @@index([phoneNumber])
  @@index([deletedAt])
}
```

### Profile 테이블 ⭐⭐⭐☆☆

**문제점**:
- profileImages JSON 배열
- 검색 필드 부족

**개선**:
```prisma
model Profile {
  id            String   @id @default(uuid())
  userId        String   @unique
  displayName   String
  gender        Gender // ✨ Enum
  birthDate     DateTime @db.Date
  age           Int? // ✨ Generated column
  bio           String?  @db.Text

  // 검색 최적화를 위한 필드 추가
  height        Int?
  occupation    String?
  education     String?
  income        String?
  smoking       String?
  drinking      String?

  isComplete    Boolean  @default(false)
  isVerified    Boolean  @default(false) // ✨ 추가
  verifiedAt    DateTime? // ✨ 추가
  profileViews  Int      @default(0) // ✨ 추가

  images        ProfileImage[] // ✨ 관계 추가
  profileValues UserProfileValue[]

  @@index([age])
  @@index([height])
  @@index([isVerified])
}
```

### ChatRoom 테이블 ⭐⭐⭐☆☆

**문제점**:
- 1:1만 가능
- 참여자 확장 불가

**개선**: ChatRoomParticipant 테이블 추가 (위 참조)

### Payment 테이블 ⭐⭐☆☆☆

**심각한 문제**:
- planId가 외래키 아님
- 환불 내역 추적 불가
- 결제 수단별 상세 정보 없음

**개선**:
```prisma
model Payment {
  id              String        @id @default(uuid())
  userId          String
  planId          String
  amount          Decimal       @db.Decimal(10, 2)
  currency        String
  paymentMethod   PaymentMethod // ✨ Enum
  paymentProvider String        // 'stripe', 'paypay', 'toss'
  transactionId   String?       @unique
  status          PaymentStatus // ✨ Enum

  // 추가 정보
  billingAddress  Json?
  taxAmount       Decimal?      @db.Decimal(10, 2)
  discountAmount  Decimal?      @db.Decimal(10, 2)

  // 환불 정보
  refundedAmount  Decimal?      @db.Decimal(10, 2)
  refundedAt      DateTime?
  refundReason    String?

  // 메타데이터
  metadata        Json?

  createdAt       DateTime      @default(now())
  completedAt     DateTime?

  user User               @relation(fields: [userId], references: [id])
  plan SubscriptionPlan  @relation(fields: [planId], references: [id])

  @@index([userId, createdAt])
  @@index([status])
  @@index([paymentMethod])
}
```

---

## 마이그레이션 전략

### Phase 1: 긴급 (1주)
1. SubscriptionPlan 테이블 추가
2. Enum 타입 도입
3. LocationArea PostGIS 적용

### Phase 2: 중요 (2-3주)
4. ProfileImage 분리
5. ChatRoomParticipant 추가
6. MatchingHistory 추가
7. 복합 인덱스 최적화

### Phase 3: 개선 (1-2개월)
8. Notification 시스템
9. UserBlock 기능
10. DataAccessLog (개인정보 보호)
11. Materialized View (성능)

---

## 결론

### 종합 평가: ⭐⭐⭐⭐☆ (4/5)

**강점**:
- EAV 패턴으로 유연한 프로필 관리
- 다국어 지원 설계
- 기본적인 정규화 준수
- 적절한 인덱싱

**약점**:
- PostGIS 미활용
- 일부 테이블 누락 (Plan, MatchingHistory)
- JSON 남용
- Enum 타입 미사용
- 확장성 제약 (ChatRoom, LocationArea)

**권장 조치**:
1. **즉시**: SubscriptionPlan, Enum, PostGIS
2. **2주 내**: ProfileImage 분리, MatchingHistory
3. **1개월 내**: ChatRoomParticipant, 복합 인덱스

**예상 효과**:
- 쿼리 성능 30-50% 개선
- 데이터 무결성 강화
- 향후 확장 용이

---

**검토자**: AI Database Architect
**검토일**: 2025-12-31
**다음 검토 예정**: 분기별
