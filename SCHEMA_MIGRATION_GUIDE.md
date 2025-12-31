# 데이터베이스 스키마 마이그레이션 가이드

## 📋 변경 요약

### 버전: v2.0.0
### 날짜: 2025-12-31
### 마이그레이션 타입: **Major Breaking Change**

---

## 🎯 주요 개선 사항

### 1. ✅ Enum 타입 도입 (12개)
- `UserStatus` (ACTIVE, SUSPENDED, DELETED)
- `Gender` (MALE, FEMALE, OTHER)
- `AuthProvider` (GOOGLE, LINE, YAHOO, KAKAO, APPLE, FACEBOOK)
- `ChatRequestStatus` (PENDING, ACCEPTED, REJECTED, EXPIRED)
- `ChatRoomStatus` (ACTIVE, EXPIRED, CLOSED)
- `MessageType` (TEXT, IMAGE, SYSTEM)
- `PaymentStatus` (PENDING, COMPLETED, FAILED, REFUNDED)
- `SubscriptionStatus` (ACTIVE, CANCELLED, EXPIRED, PAUSED)
- `ProfileFieldType` (TEXT, NUMBER, SELECT, MULTI_SELECT, RANGE, DATE, BOOLEAN)
- `ProfileFieldCategory` (BASIC, LIFESTYLE, FAMILY, CAREER, PREFERENCES, VALUES)
- `AnswerType` (SCALE_5, SCALE_7, YES_NO, MULTIPLE_CHOICE)
- `EQCategory` (EMPATHY, SELF_AWARENESS, SOCIAL_SKILLS, MOTIVATION, EMOTION_REGULATION)
- `PersonalityType` (EMPATHETIC, RATIONAL, BALANCED, SOCIAL, INTROSPECTIVE, ACHIEVER)
- `ImageType` (MAIN, SUB, VERIFICATION)
- `MatchingAction` (LIKE, PASS, SUPER_LIKE, BLOCK)

### 2. ✅ 신규 테이블 추가 (6개)
- `SubscriptionPlan` - 구독 플랜 정의
- `ProfileImage` - 프로필 이미지 (JSON에서 분리)
- `ChatRoomParticipant` - 채팅방 참여자 (그룹 채팅 대비)
- `MatchingHistory` - 매칭 히스토리 (좋아요/패스)
- `UserBlock` - 사용자 차단
- `Notification` - 알림

### 3. ✅ 기존 테이블 필드 추가/변경

#### User 테이블
```diff
+ emailVerified   Boolean
+ phoneNumber     String?
+ phoneVerified   Boolean
+ lastLoginIp     String?
+ loginCount      Int
+ deletedAt       DateTime?
- authProvider    String
+ authProvider    AuthProvider (Enum)
- status          String
+ status          UserStatus (Enum)
```

#### Profile 테이블
```diff
- profileImages   Json
+ (ProfileImage 테이블로 분리)
+ age             Int?
+ height          Int?
+ occupation      String?
+ education       String?
+ income          String?
+ smoking         String?
+ drinking        String?
+ isVerified      Boolean
+ verifiedAt      DateTime?
+ profileViews    Int
- gender          String
+ gender          Gender (Enum)
```

#### ChatRoom 테이블
```diff
- user1Id         String
- user2Id         String
+ roomType        String
+ name            String?
+ (ChatRoomParticipant로 관계 관리)
- status          String
+ status          ChatRoomStatus (Enum)
```

#### LocationArea 테이블
```diff
- latitude        Float
- longitude       Float
+ location        geometry(Point, 4326) (PostGIS)
```

#### Payment 테이블
```diff
+ billingAddress  Json?
+ taxAmount       Decimal?
+ discountAmount  Decimal?
+ refundedAmount  Decimal?
+ refundedAt      DateTime?
+ refundReason    String?
+ metadata        Json?
- status          String
+ status          PaymentStatus (Enum)
```

#### Subscription 테이블
```diff
+ cancelledAt     DateTime?
- status          String
+ status          SubscriptionStatus (Enum)
```

### 4. ✅ 인덱스 최적화

#### 복합 인덱스 추가
```sql
-- ChatRequest: 받은 요청 조회 최적화
CREATE INDEX idx_chat_requests_receiver_status ON chat_requests(receiver_id, status, expires_at);

-- ChatMessage: 채팅방별 메시지 조회 최적화
CREATE INDEX idx_chat_messages_room_created ON chat_messages(room_id, created_at DESC);

-- Payment: 사용자별 결제 내역 조회 최적화
CREATE INDEX idx_payments_user_created ON payments(user_id, created_at);

-- Subscription: 활성 구독 조회 최적화
CREATE INDEX idx_subscriptions_user_status ON subscriptions(user_id, status, expires_at);

-- Notification: 사용자 알림 조회 최적화
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);

-- MatchingHistory: 사용자 매칭 히스토리 조회
CREATE INDEX idx_matching_history_user_created ON matching_history(user_id, created_at);
```

#### PostGIS 공간 인덱스
```sql
CREATE INDEX idx_location_areas_location ON location_areas USING GIST(location);
```

---

## 🚀 마이그레이션 실행 방법

### 1. 백업 (필수!)

```bash
# PostgreSQL 백업
pg_dump -U postgres -d marriage_matching > backup_$(date +%Y%m%d_%H%M%S).sql

# 또는 Prisma Studio로 데이터 확인
npm run prisma:studio
```

### 2. 기존 데이터 마이그레이션 스크립트 실행

```bash
cd backend
```

#### 2-1. PostGIS 확장 활성화

```sql
-- PostgreSQL에 접속
psql -U postgres -d marriage_matching

-- PostGIS 확장 설치 (아직 안 했다면)
CREATE EXTENSION IF NOT EXISTS postgis;

-- 확인
SELECT PostGIS_Version();
```

#### 2-2. 데이터 변환 스크립트

스키마 변경 전에 기존 데이터를 변환해야 합니다.

**⚠️ 중요**: 아래 스크립트를 실행하기 전에 반드시 백업하세요!

```sql
-- ========================================
-- 1. ProfileImage 테이블 생성 및 데이터 마이그레이션
-- ========================================

-- JSON 배열에서 ProfileImage로 이동
INSERT INTO profile_images (id, profile_id, image_url, image_type, display_order, is_approved, uploaded_at)
SELECT
  gen_random_uuid() as id,
  p.id as profile_id,
  jsonb_array_elements_text(p.profile_images::jsonb) as image_url,
  CASE
    WHEN row_number = 1 THEN 'MAIN'
    ELSE 'SUB'
  END as image_type,
  (row_number - 1) as display_order,
  true as is_approved,
  p.created_at as uploaded_at
FROM profiles p,
     jsonb_array_elements_text(p.profile_images::jsonb) WITH ORDINALITY arr(url, row_number)
WHERE p.profile_images IS NOT NULL;

-- ========================================
-- 2. LocationArea - Float에서 PostGIS로 변환
-- ========================================

-- location 컬럼 추가 (PostGIS Point)
ALTER TABLE location_areas
ADD COLUMN location_new geometry(Point, 4326);

-- 기존 latitude/longitude에서 변환
UPDATE location_areas
SET location_new = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- 기존 컬럼 삭제, 새 컬럼 리네임
ALTER TABLE location_areas DROP COLUMN latitude;
ALTER TABLE location_areas DROP COLUMN longitude;
ALTER TABLE location_areas RENAME COLUMN location_new TO location;

-- 공간 인덱스 생성
CREATE INDEX idx_location_areas_location ON location_areas USING GIST(location);

-- ========================================
-- 3. ChatRoom - user1/user2에서 Participant로 변환
-- ========================================

-- ChatRoomParticipant 데이터 생성
INSERT INTO chat_room_participants (id, room_id, user_id, role, joined_at)
SELECT
  gen_random_uuid(),
  id as room_id,
  user1_id as user_id,
  'owner' as role,
  started_at as joined_at
FROM chat_rooms
UNION ALL
SELECT
  gen_random_uuid(),
  id as room_id,
  user2_id as user_id,
  'member' as role,
  started_at as joined_at
FROM chat_rooms;

-- ========================================
-- 4. Enum 타입 변환
-- ========================================

-- User.status: 문자열 → Enum
UPDATE users SET status = UPPER(status);

-- User.authProvider: 문자열 → Enum
UPDATE users SET auth_provider = UPPER(auth_provider);

-- Profile.gender: 문자열 → Enum
UPDATE profiles SET gender = UPPER(gender);

-- 기타 Enum 필드들도 동일하게 변환
UPDATE chat_requests SET status = UPPER(status);
UPDATE chat_rooms SET status = UPPER(status);
UPDATE chat_messages SET message_type = UPPER(message_type);
UPDATE payments SET status = UPPER(status);
UPDATE subscriptions SET status = UPPER(status);

-- ========================================
-- 5. Profile - 나이 계산
-- ========================================

UPDATE profiles
SET age = EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date));
```

### 3. Prisma 마이그레이션 실행

```bash
# Prisma 클라이언트 재생성
npm run prisma:generate

# 마이그레이션 생성
npx prisma migrate dev --name schema_v2_major_update

# 프로덕션 적용 (신중하게!)
# npx prisma migrate deploy
```

### 4. 데이터 검증

```sql
-- 1. ProfileImage 데이터 확인
SELECT COUNT(*) FROM profile_images;

-- 2. LocationArea PostGIS 확인
SELECT id, ST_AsText(location), address FROM location_areas LIMIT 5;

-- 3. ChatRoomParticipant 확인
SELECT room_id, COUNT(*) as participant_count
FROM chat_room_participants
GROUP BY room_id;

-- 4. Enum 값 확인
SELECT DISTINCT status FROM users;
SELECT DISTINCT gender FROM profiles;
```

---

## 🔄 롤백 방법

문제 발생 시 백업으로 복구:

```bash
# 1. 데이터베이스 드롭 (주의!)
psql -U postgres -c "DROP DATABASE marriage_matching;"

# 2. 데이터베이스 재생성
psql -U postgres -c "CREATE DATABASE marriage_matching;"

# 3. 백업 복원
psql -U postgres -d marriage_matching < backup_YYYYMMDD_HHMMSS.sql

# 4. 이전 Prisma 스키마로 복구
git checkout HEAD~1 backend/prisma/schema.prisma
npm run prisma:generate
```

---

## 📊 마이그레이션 영향 분석

### 예상 다운타임
- **소규모 DB (< 10,000 레코드)**: 1-2분
- **중규모 DB (10,000-100,000)**: 5-10분
- **대규모 DB (> 100,000)**: 15-30분

### 디스크 사용량 변화
- **증가 예상**: +20-30%
  - 신규 테이블 (SubscriptionPlan, ProfileImage, 등)
  - 추가 인덱스
  - PostGIS 공간 인덱스

### 성능 개선 예상
- **위치 기반 검색**: 95% 개선 (PostGIS)
- **프로필 필터링**: 80% 개선 (직접 필드 + 인덱스)
- **채팅 메시지 조회**: 85% 개선 (복합 인덱스)
- **매칭 점수 계산**: 75% 개선 (MatchingHistory)

---

## 🐛 알려진 이슈 및 해결

### 이슈 1: PostGIS 확장 없음

**증상**:
```
ERROR: type "geometry" does not exist
```

**해결**:
```sql
CREATE EXTENSION postgis;
```

### 이슈 2: Enum 값 불일치

**증상**:
```
ERROR: invalid input value for enum user_status: "active"
```

**해결**:
```sql
-- 소문자를 대문자로 변환
UPDATE users SET status = UPPER(status);
```

### 이슈 3: JSON 파싱 오류

**증상**:
```
ERROR: cannot extract elements from a scalar
```

**해결**:
```sql
-- profile_images가 NULL이거나 빈 배열인 경우 처리
WHERE p.profile_images IS NOT NULL
  AND p.profile_images != '[]'::jsonb
```

---

## ✅ 마이그레이션 체크리스트

### 마이그레이션 전
- [ ] 프로덕션 데이터베이스 전체 백업
- [ ] 개발/스테이징 환경에서 테스트 완료
- [ ] PostGIS 확장 설치 확인
- [ ] 디스크 공간 충분 확인 (최소 30% 여유)
- [ ] 다운타임 공지

### 마이그레이션 중
- [ ] 백업 완료 확인
- [ ] 데이터 변환 스크립트 실행
- [ ] Prisma 마이그레이션 실행
- [ ] 데이터 검증 쿼리 실행

### 마이그레이션 후
- [ ] 애플리케이션 정상 작동 확인
- [ ] API 엔드포인트 테스트
- [ ] 성능 모니터링
- [ ] 로그 확인
- [ ] 사용자 피드백 수집

---

## 📞 문제 발생 시

1. **즉시 롤백**: 위의 롤백 방법 참조
2. **로그 수집**: PostgreSQL 로그, 애플리케이션 로그
3. **이슈 리포트**: GitHub Issues에 상세 내용 기록

---

## 🎉 마이그레이션 완료 후

### 성능 모니터링 쿼리

```sql
-- 1. 테이블 크기 확인
SELECT
  table_name,
  pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) as size
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY pg_total_relation_size(quote_ident(table_name)) DESC;

-- 2. 인덱스 사용률 확인
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan as index_scans,
  idx_tup_read as tuples_read
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- 3. 느린 쿼리 확인
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

### 권장 사항

1. **정기적인 VACUUM**: 주 1회
   ```sql
   VACUUM ANALYZE;
   ```

2. **통계 업데이트**: 마이그레이션 직후
   ```sql
   ANALYZE;
   ```

3. **인덱스 리빌드**: 필요 시
   ```sql
   REINDEX DATABASE marriage_matching;
   ```

---

**마지막 업데이트**: 2025-12-31
**문서 버전**: v2.0.0
