# Frontend - Marriage Matching App

Flutter 기반 크로스 플랫폼 모바일 애플리케이션입니다.

## 🛠 기술 스택

- **Framework**: Flutter 3.0+
- **상태관리**: Riverpod 2.4+
- **HTTP 통신**: Dio 5.0+
- **실시간 통신**: socket_io_client 2.0+
- **지도**: google_maps_flutter
- **위치**: geolocator, geocoding
- **인증**: google_sign_in
- **로컬 저장소**: shared_preferences, flutter_secure_storage
- **이미지**: image_picker, cached_network_image

## 📁 프로젝트 구조

```
frontend/lib/
├── main.dart                # 앱 진입점
├── app.dart                 # MaterialApp 설정
├── core/                    # 코어 기능
│   ├── constants/          # 상수 (API URL 등)
│   ├── theme/              # 앱 테마
│   ├── network/            # HTTP 클라이언트
│   └── utils/              # 유틸리티 함수
├── features/               # 기능별 모듈
│   ├── auth/              # 인증
│   │   ├── data/          # 데이터 레이어
│   │   ├── domain/        # 도메인 레이어
│   │   └── presentation/  # UI 레이어
│   │       ├── pages/     # 화면
│   │       ├── widgets/   # 위젯
│   │       └── providers/ # 상태 관리
│   ├── profile/           # 프로필
│   ├── matching/          # 매칭
│   ├── chat/              # 채팅
│   ├── payment/           # 결제
│   └── settings/          # 설정
├── shared/                # 공유 컴포넌트
│   ├── widgets/          # 공통 위젯
│   ├── models/           # 공통 모델
│   └── services/         # 공통 서비스
└── l10n/                 # 다국어 리소스
```

## 🚀 시작하기

### 사전 요구사항

- Flutter SDK 3.0 이상
- Dart SDK 3.0 이상
- Android Studio / Xcode (플랫폼별)
- Google Maps API Key (선택사항)

### 설치

#### 1. Flutter SDK 설치

```bash
# Flutter 버전 확인
flutter --version

# Flutter doctor로 환경 확인
flutter doctor
```

#### 2. 의존성 설치

```bash
cd frontend
flutter pub get
flutter gen-l10n
```

#### 3. 환경 설정

Google Maps API Key가 필요한 경우:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**iOS** (`ios/Runner/AppDelegate.swift`):
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

#### 4. 앱 실행

```bash
# 연결된 디바이스/에뮬레이터 확인
flutter devices

# 시뮬레이터 실행하기
flutter emulators --launch apple_ios_simulator

flutter gen-l10n

# 앱 실행
flutter run

# 특정 디바이스에서 실행
flutter run -d <device-id>
```

#### 5. 빌드

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 주요 화면

### 1. 인증 (Auth)

#### 로그인 화면
- Google 소셜 로그인
- LINE 로그인 (준비 중)
- Yahoo 로그인 (준비 중)

**파일:** `lib/features/auth/presentation/pages/login_page.dart`

### 2. 프로필 (Profile)

#### 프로필 생성 화면
- 필수 정보 입력 (이름, 성별, 생년월일 등)
- 사진 업로드 (최대 6장)
- 자기소개 및 관심사

#### 프로필 수정 화면
- 프로필 정보 수정
- 사진 변경

**파일:**
- `lib/features/profile/presentation/pages/profile_create_page.dart`
- `lib/features/profile/presentation/pages/profile_edit_page.dart`

### 3. 위치 (Location)

#### 위치 설정 화면
- GPS로 현재 위치 확인
- 지도에서 활동 지역 선택
- 반경 설정 (10km, 20km, 30km, 40km)
- 최대 2개 지역 설정

**파일:** `lib/features/location/presentation/pages/location_setup_page.dart`

### 4. 매칭 (Matching)

#### 매칭 목록 화면
- 거리 기반 사용자 목록
- 필터링 (나이, 키, 직업 등)
- 밸런스 게임 유사도 표시

#### 밸런스 게임 화면
- 10~20개 질문
- A/B 선택
- 결과 저장

**파일:**
- `lib/features/matching/presentation/pages/matching_list_page.dart`
- `lib/features/matching/presentation/pages/balance_game_page.dart`

### 5. 채팅 (Chat)

#### 채팅 목록 화면
- 활성 채팅방 목록
- 마지막 메시지 미리보기
- 읽지 않은 메시지 개수

#### 채팅 화면
- 실시간 메시지 송수신
- 타이핑 인디케이터
- 읽음 표시
- 무료 사용자: 30분 타이머

**파일:**
- `lib/features/chat/presentation/pages/chat_list_page.dart`
- `lib/features/chat/presentation/pages/chat_room_page.dart`

### 6. 결제 (Payment)

#### 결제 플랜 화면
- 월간 구독
- 대화 횟수 패키지
- 플랜 비교

#### 결제 화면
- 신용카드 결제
- 앱 내 결제 (Google Play / App Store)

**파일:**
- `lib/features/payment/presentation/pages/payment_plans_page.dart`
- `lib/features/payment/presentation/pages/checkout_page.dart`

## 🎨 테마

앱은 라이트 모드와 다크 모드를 지원합니다.

테마 설정: `lib/core/theme/app_theme.dart`

```dart
// 시스템 설정 따라가기
themeMode: ThemeMode.system

// 라이트 모드 고정
themeMode: ThemeMode.light

// 다크 모드 고정
themeMode: ThemeMode.dark
```

## 🌍 다국어 지원

지원 언어:
- 한국어 (ko)
- 일본어 (ja)
- 영어 (en)

다국어 리소스: `lib/l10n/`

```dart
// 다국어 텍스트 사용
Text(AppLocalizations.of(context)!.login)
```

## 🔌 API 통신

### HTTP 클라이언트

Dio 기반 API 클라이언트를 사용합니다.

**파일:** `lib/core/network/api_client.dart`

**기능:**
- 자동 Bearer Token 추가
- Refresh Token 자동 갱신
- 에러 처리

**사용 예시:**
```dart
final apiClient = ApiClient();

// GET 요청
final response = await apiClient.dio.get('/api/profile/me');

// POST 요청
final response = await apiClient.dio.post(
  '/api/profile',
  data: profileData,
);
```

### Socket.IO

실시간 채팅을 위한 Socket.IO 연결:

```dart
import 'package:socket_io_client/socket_io_client.dart';

final socket = io('http://localhost:3000', <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
  'auth': {
    'token': accessToken,
  },
});

socket.connect();

// 메시지 전송
socket.emit('chat:send', {
  'roomId': roomId,
  'content': message,
});

// 메시지 수신
socket.on('chat:receive', (data) {
  print('New message: $data');
});
```

## 🔒 보안 저장소

민감한 데이터는 `flutter_secure_storage`를 사용:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// 저장
await storage.write(key: 'access_token', value: token);

// 읽기
final token = await storage.read(key: 'access_token');

// 삭제
await storage.delete(key: 'access_token');
```

## 📍 위치 서비스

### 권한 요청

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>매칭을 위해 위치 정보가 필요합니다.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>위치 기반 매칭 서비스를 제공하기 위해 위치 정보가 필요합니다.</string>
```

### 현재 위치 가져오기

```dart
import 'package:geolocator/geolocator.dart';

Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);

print('위도: ${position.latitude}, 경도: ${position.longitude}');
```

## 🧪 테스트

### 단위 테스트

```bash
flutter test
```

### 위젯 테스트

```bash
flutter test test/widget_test.dart
```

### 통합 테스트

```bash
flutter drive --target=test_driver/app.dart
```

## 📦 빌드 및 배포

### Android

1. 서명 키 생성:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. `android/key.properties` 생성:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. 빌드:
```bash
flutter build appbundle --release
```

### iOS

1. Xcode에서 서명 설정
2. 빌드:
```bash
flutter build ios --release
```

## 🐛 디버깅

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### 로그 확인

```bash
# 실시간 로그
flutter logs

# 특정 디바이스
flutter logs -d <device-id>
```

## 📝 스크립트

- `flutter run` - 앱 실행
- `flutter test` - 테스트 실행
- `flutter build apk` - Android APK 빌드
- `flutter build appbundle` - Android App Bundle 빌드
- `flutter build ios` - iOS 빌드
- `flutter clean` - 빌드 캐시 삭제
- `flutter pub get` - 의존성 설치
- `flutter pub upgrade` - 의존성 업그레이드

## 🤝 기여하기

버그 리포트 및 기능 제안은 Issue를 통해 부탁드립니다.

## 📄 라이선스

MIT License
