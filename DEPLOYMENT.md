# 🚀 배포 가이드 (Deployment Guide)

## 📋 목차

1. [개요](#개요)
2. [국가별 환경 설정](#국가별-환경-설정)
3. [로컬 개발 환경](#로컬-개발-환경)
4. [프로덕션 배포](#프로덕션-배포)
5. [환경 변수 관리](#환경-변수-관리)
6. [CI/CD 설정](#cicd-설정)

---

## 개요

이 프로젝트는 **국가별로 다른 환경 설정**을 자동으로 적용하는 시스템을 사용합니다.

### 지원 국가

1. **🇯🇵 일본** (Japan) - 1순위 출시
2. **🇰🇷 한국** (Korea) - 2순위 출시
3. **🇺🇸 미국** (USA) - 3순위 출시

### 환경 파일 구조

```
backend/
├── .env.development   # 개발 환경 (기본)
├── .env.japan        # 일본 프로덕션
├── .env.korea        # 한국 프로덕션
├── .env.usa          # 미국 프로덕션
└── .env.example      # 템플릿 (Git 추적)
```

**중요**: `.env`, `.env.local` 파일은 Git에 커밋되지 않습니다. 각 환경별 설정 파일만 개발자가 직접 관리합니다.

---

## 국가별 환경 설정

### 자동 환경 로딩 시스템

`DEPLOY_COUNTRY` 환경 변수에 따라 자동으로 적절한 `.env` 파일을 로드합니다.

```typescript
// src/config/env-loader.ts
// 1. .env (기본값 로드)
// 2. .env.{DEPLOY_COUNTRY} (국가별 설정으로 덮어쓰기)
```

### 국가별 주요 차이점

| 구분 | 일본 | 한국 | 미국 |
|------|------|------|------|
| **리전** | ap-northeast-1 (도쿄) | ap-northeast-2 (서울) | us-east-1 (버지니아) |
| **결제 1순위** | PayPay | Toss Payments | Stripe |
| **결제 2순위** | Stripe | KakaoPay | Apple Pay |
| **OAuth 주력** | LINE Login | Kakao Login | Google OAuth |
| **지도** | Google Maps | Naver Maps | Google Maps |
| **언어** | 일본어 (ja) | 한국어 (ko) | 영어 (en) |
| **통화** | JPY (¥) | KRW (₩) | USD ($) |
| **타임존** | Asia/Tokyo | Asia/Seoul | America/New_York |

---

## 로컬 개발 환경

### 1. 개발 환경 실행 (기본)

```bash
cd backend

# 방법 1: 기본 개발 환경 (.env.development)
npm run dev

# 방법 2: .env 파일 사용
cp .env.development .env
npm run dev
```

**개발 환경 특징**:
- ✅ `PAYMENT_MODE="mock"` - 비용 발생 없음
- ✅ `STORAGE_TYPE="local"` - AWS S3 사용 안 함
- ✅ 로컬 PostgreSQL, Redis 사용

### 2. 국가별 환경으로 개발 테스트

특정 국가 환경을 로컬에서 테스트하고 싶을 때:

```bash
# 일본 환경으로 실행
npm run dev:japan

# 한국 환경으로 실행
npm run dev:korea

# 미국 환경으로 실행
npm run dev:usa
```

**주의**: 프로덕션 환경 변수가 설정되어 있어야 합니다.

---

## 프로덕션 배포

### 1. 환경 파일 준비

각 국가별 `.env` 파일에 실제 프로덕션 값을 설정합니다.

```bash
# 예: 일본 환경 설정
cd backend
cp .env.japan .env

# 또는 환경 변수로 직접 지정
export DEPLOY_COUNTRY=japan
```

### 2. 빌드

```bash
npm run build
```

### 3. 실행

```bash
# 방법 1: 국가별 스크립트 사용
npm run start:japan   # 일본
npm run start:korea   # 한국
npm run start:usa     # 미국

# 방법 2: 환경 변수로 지정
DEPLOY_COUNTRY=japan npm start
```

### 4. Docker로 배포

```bash
# Dockerfile에서 빌드 시 ARG로 국가 지정
docker build --build-arg DEPLOY_COUNTRY=japan -t marriage-app-japan .

# 실행
docker run -e DEPLOY_COUNTRY=japan -p 3000:3000 marriage-app-japan
```

---

## 환경 변수 관리

### 필수 환경 변수

모든 환경에서 **반드시 설정**해야 하는 변수:

```env
# 1. Database
DATABASE_URL="postgresql://..."

# 2. JWT Secrets (강력한 키로 변경!)
JWT_SECRET="your-strong-secret"
JWT_REFRESH_SECRET="your-strong-refresh-secret"

# 3. 배포 국가
DEPLOY_COUNTRY="japan"  # japan | korea | usa

# 4. Node 환경
NODE_ENV="production"
```

### 국가별 결제 게이트웨이 설정

각 결제 수단은 `{PAYMENT_METHOD}_ENABLED` 플래그로 활성화합니다.

#### 일본

```env
PAYMENT_MODE="production"

# PayPay (필수)
PAYPAY_API_KEY="..."
PAYPAY_ENABLED="true"

# Stripe (필수)
STRIPE_SECRET_KEY="sk_live_..."
STRIPE_ENABLED="true"

# Rakuten Pay (선택)
RAKUTEN_SERVICE_SECRET="..."
RAKUTEN_ENABLED="true"
```

#### 한국

```env
PAYMENT_MODE="production"

# Toss Payments (필수)
TOSS_CLIENT_KEY="..."
TOSS_SECRET_KEY="..."
TOSS_ENABLED="true"

# KakaoPay (필수)
KAKAOPAY_ADMIN_KEY="..."
KAKAOPAY_ENABLED="true"
```

#### 미국

```env
PAYMENT_MODE="production"

# Stripe (필수)
STRIPE_SECRET_KEY="sk_live_..."
STRIPE_ENABLED="true"

# Apple Pay (권장)
APPLE_PAY_MERCHANT_ID="..."
APPLE_PAY_ENABLED="true"
```

### 환경별 파일 우선순위

```
1. .env.{DEPLOY_COUNTRY}  (최우선)
2. .env                   (fallback)
```

---

## CI/CD 설정

### GitHub Actions 예시

#### 일본 배포 워크플로우

```yaml
# .github/workflows/deploy-japan.yml
name: Deploy to Japan

on:
  push:
    branches:
      - main
    paths:
      - 'backend/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: |
          cd backend
          npm install

      - name: Build
        run: |
          cd backend
          npm run build

      - name: Deploy to Japan (AWS Tokyo)
        env:
          DEPLOY_COUNTRY: japan
          AWS_REGION: ap-northeast-1
        run: |
          # AWS CodeDeploy 또는 ECS 배포 스크립트
          echo "Deploying to Japan..."
```

#### 한국 배포 워크플로우

```yaml
# .github/workflows/deploy-korea.yml
name: Deploy to Korea

on:
  push:
    branches:
      - release/korea

jobs:
  deploy:
    runs-on: ubuntu-latest
    env:
      DEPLOY_COUNTRY: korea
      AWS_REGION: ap-northeast-2
    steps:
      # ... (일본과 동일)
```

### 환경 시크릿 관리

GitHub Secrets에 다음과 같이 저장:

```
# 일본 환경
JAPAN_DATABASE_URL
JAPAN_PAYPAY_API_KEY
JAPAN_STRIPE_SECRET_KEY

# 한국 환경
KOREA_DATABASE_URL
KOREA_TOSS_SECRET_KEY
KOREA_KAKAOPAY_ADMIN_KEY

# 미국 환경
USA_DATABASE_URL
USA_STRIPE_SECRET_KEY
```

---

## AWS 배포 예시

### 1. AWS ECS (Elastic Container Service)

```bash
# ECR에 이미지 푸시
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin {aws-account}.dkr.ecr.ap-northeast-1.amazonaws.com

# 일본 이미지 빌드 및 푸시
docker build --build-arg DEPLOY_COUNTRY=japan -t marriage-app-japan .
docker tag marriage-app-japan:latest {aws-account}.dkr.ecr.ap-northeast-1.amazonaws.com/marriage-app:japan
docker push {aws-account}.dkr.ecr.ap-northeast-1.amazonaws.com/marriage-app:japan

# ECS 서비스 업데이트
aws ecs update-service --cluster marriage-cluster-japan --service marriage-service --force-new-deployment
```

### 2. Task Definition (ECS)

```json
{
  "family": "marriage-app-japan",
  "containerDefinitions": [
    {
      "name": "app",
      "image": "{aws-account}.dkr.ecr.ap-northeast-1.amazonaws.com/marriage-app:japan",
      "environment": [
        {
          "name": "DEPLOY_COUNTRY",
          "value": "japan"
        },
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:ap-northeast-1:xxx:secret:japan-db-url"
        },
        {
          "name": "PAYPAY_API_KEY",
          "valueFrom": "arn:aws:secretsmanager:ap-northeast-1:xxx:secret:paypay-key"
        }
      ]
    }
  ]
}
```

---

## 배포 체크리스트

### 일본 출시 전

- [ ] `.env.japan` 파일 완성
- [ ] PayPay 계정 및 API 키 발급
- [ ] Stripe 일본 설정 완료
- [ ] AWS RDS (Tokyo 리전) 생성
- [ ] AWS S3 버킷 생성 (`ap-northeast-1`)
- [ ] LINE Login OAuth 설정
- [ ] 일본어 번역 검수 완료
- [ ] 일본 법규 준수 확인 (특정상거래법)

### 한국 출시 전

- [ ] `.env.korea` 파일 완성
- [ ] Toss Payments 가맹점 등록
- [ ] KakaoPay 개발자 등록
- [ ] AWS RDS (Seoul 리전) 생성
- [ ] Kakao Login OAuth 설정
- [ ] Naver Maps API 키 발급
- [ ] 한국 법규 준수 확인 (전자상거래법)

### 미국 출시 전

- [ ] `.env.usa` 파일 완성
- [ ] Stripe 미국 계정 설정
- [ ] Apple Pay 인증서 발급
- [ ] AWS RDS (US East 리전) 생성
- [ ] Google OAuth 설정
- [ ] CCPA, COPPA 준수 확인

---

## 문제 해결

### 1. 환경이 제대로 로드되지 않을 때

```bash
# 환경 확인
curl http://localhost:3000/

# 응답 예시
{
  "country": "japan",
  "environment": "production",
  "paymentMode": "production",
  "enabledPayments": ["PAYPAY", "STRIPE", "RAKUTEN"]
}
```

### 2. 국가별 환경 파일이 없을 때

```bash
# 로그에서 경고 확인
⚠️  Country-specific env file not found: .env.japan
⚠️  Using default .env file
```

→ 해당 국가의 `.env.{country}` 파일을 생성하세요.

### 3. 결제 게이트웨이가 활성화되지 않을 때

```typescript
// 코드에서 확인
import { isPaymentEnabled } from './config/env-loader';

if (isPaymentEnabled('PAYPAY')) {
  // PayPay 결제 처리
}
```

→ `.env` 파일에 `PAYPAY_ENABLED="true"` 설정 확인

---

## 보안 주의사항

1. **절대 커밋하지 말 것**:
   - `.env` (로컬 개발 환경)
   - `.env.local` (로컬 오버라이드)
   - 실제 API 키, 시크릿

2. **Git에 포함**:
   - `.env.example` (템플릿만)
   - `.env.development` (개발용 Mock 설정)
   - `.env.japan`, `.env.korea`, `.env.usa` (키 값은 placeholder)

3. **프로덕션 시크릿 관리**:
   - AWS Secrets Manager
   - GitHub Secrets
   - Vault (HashiCorp)

---

**마지막 업데이트**: 2025-12-31
