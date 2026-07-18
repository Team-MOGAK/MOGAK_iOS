# MOGAK iOS

MOGAK의 iOS 클라이언트입니다. 현재 실행 대상은 `MOGAK2/Sources`이며, 이전 `MOGAK` 소스는 제거되었습니다.

## Requirements

- Xcode 17 이상
- iOS 16 이상
- 로컬 API를 사용할 경우 실행 중인 MOGAK Spring 서버

## Configuration

1. `Configuration/Secrets.example.xcconfig`를 참고해 로컬 전용 `Configuration/Secrets.xcconfig`를 만듭니다.
2. Google과 Kakao 콘솔의 iOS 앱 설정이 Xcode의 Bundle ID 및 URL Scheme과 일치하는지 확인합니다.
3. API URL은 기존 xcconfig와 `Configuration/Info.plist`의 빌드 설정 치환을 통해 주입됩니다. URL을 Swift 코드에 중복 선언하지 않습니다.

`Secrets.xcconfig`는 Git에 포함되지 않습니다.

## Social Login

클라이언트는 아래 토큰을 서버의 `POST /api/auth/{provider}/login`에 JSON `token` 필드로 전달합니다.

- Apple: identity token
- Google: ID token
- Kakao: access token

서버 설정:

- iOS Bundle ID: `com.team.mogaks`
- Google: `GOOGLE_CLIENT_IDS` 또는 `GOOGLE_CLIENT_ID`에 iOS OAuth Client ID `855761715346-qe8iq5a8jsu4g5bhei2fe6mucl67j42h.apps.googleusercontent.com`을 등록해야 합니다. 여러 ID는 쉼표로 구분합니다.
- Google 신규 계정은 ID token에 이메일과 `email_verified=true`가 있어야 합니다.
- Kakao: 현재 서버 구현은 클라이언트 access token으로 Kakao 사용자 API를 호출하므로 REST API 키나 Client Secret을 요구하지 않습니다. 서버에서 `https://kapi.kakao.com`으로 나가는 HTTPS 통신은 가능해야 합니다.
- Kakao Developers의 iOS 플랫폼 Bundle ID는 `com.team.mogaks`로 등록하고, 카카오계정 이메일 동의 항목을 활성화해야 합니다. 현재 서버의 `KakaoOAuthUserProvider`는 이메일이 없으면 `SOCIAL_EMAIL_REQUIRED`로 거절합니다.

클라이언트 콘솔 설정:

- Google Cloud의 iOS OAuth 앱 Bundle ID를 `com.team.mogaks`로 설정합니다.
- Kakao Native App Key는 `Configuration/Secrets.xcconfig`에만 넣고, URL Scheme은 `kakao{NATIVE_APP_KEY}` 형식을 사용합니다. 이 키는 현재 서버 환경변수로 전달하지 않습니다.

로컬 서버 예시:

```sh
export GOOGLE_CLIENT_IDS='855761715346-qe8iq5a8jsu4g5bhei2fe6mucl67j42h.apps.googleusercontent.com'
export APPLE_CLIENT_IDS='com.team.mogaks'
sh gradlew run
```

`application-local.yml`의 기본 Google Client ID와 Apple Client ID는 실제 앱 값이 아니므로, 위 환경변수는 서버 시작 전에 설정해야 합니다. 서버는 Google ID token의 `aud`를 `GOOGLE_CLIENT_IDS`와 비교하고, Kakao는 앱이 전달한 access token으로 `/v2/user/me`를 조회합니다.

## Build

```sh
xcodebuild -project MOGAK.xcodeproj \
  -scheme MOGAK \
  -destination 'generic/platform=iOS Simulator' \
  build
```

## Architecture

```text
MOGAK2/Sources/
├── MG_App          # 앱 시작, DI, 소셜 SDK 통합
├── MG_Core         # 공용 상태와 기반 인터페이스
├── MG_Domain       # Entity, UseCase, Repository 인터페이스
├── MG_Data         # DTO, Router, Repository 구현
├── MG_Network      # 공용 네트워크 제공자
├── MG_Presentation # View, ViewModel, Coordinator
└── MG_Design       # 디자인 시스템과 리소스
```

ViewController는 네트워크나 Repository를 직접 호출하지 않습니다. 화면 입력과 표시는 View가, 상태와 기능 실행은 ViewModel/UseCase가 담당합니다.

## Audit

```sh
sh MOGAK2/scripts/architecture_audit.sh
```
