# 인수인계 메모 — 모다라트 디자인 시스템 반영 (2026-10-28)

> 이 파일은 작업 인수인계용 로컬 메모예요. 커밋하지 마세요(필요하면 지워도 돼요).

## 무엇을 했나

디자인 시스템 아티팩트(https://claude.ai/artifact/F1Q2GCAsgpaUnZfLmFGVdZ, 사용자가 직접 받은 디자인 소스)를 MOGAK2 앱 전체에 반영했다.
**아직 하나도 커밋하지 않았다** (브랜치 `REF_main`, 변경 파일 약 170개).

- 배포 타깃 iOS 16 → 17
- 디자인 토큰: `MOGAK2/Sources/MG_Design/Source/Foundation/DS.swift` (`DS` 색·간격·모서리·크기·그림자, `DS.Moak` 모각 8색, `DS.Pose`, `T` 글자 스타일)
  - 기존 `DesignSystemColor`는 값만 새 토큰으로 연결. 서버로 보내는 색(`DesignSystemPalette` hex)은 바꾸지 않음 → 화면에서는 `DS.Moak.from(hex:)` / `displayColor(forServerHex:)`로 변환
- 에셋: 프로필 `profile1~12` = 아바타 av01~av12, 모각이 12포즈는 `Shared/Mascot.xcassets` (`moak.<포즈>`)
- 폰트: Pretendard 400·500·600·700·800 → `Shared/Fonts` (앱 + 위젯). ExtraBold는 npm `pretendard@1.3.7`(v1.307, OFL)에서 받음
- 공통 컴포넌트(`MG_Presentation/Source/Common/Component`): 버튼 5종, TextField·FieldLabel·HintLabel, Segmented, SheetHeader, CheckCircle, Tag, ProgressBar, Toast, Mascot(숨쉬기·폴짝·반응), AdBadge
- 화면: 떠 있는 탭 바 + Duo 2단(`MG2MainTabViewController`), 홈(진척 카드·조각 행·축하 카드·알림 권유·지난 날 보상형), 판(칸 높이 공식·560 가운데 열·판→모각 확대 전환), 모각 상세, 로그인·온보딩·약관·닉네임·직무·지역, 모각/조각 폼, 모든 시트, 마이페이지
  - 아티팩트에는 로그인·온보딩·폼 화면 레이아웃이 따로 없음(컴포넌트 + bundle.css 수치 + README 규칙뿐). 그 화면들은 컴포넌트로 구성함
- Domain: `MG2Mood`(모각이 포즈 규칙), `TodayUseCase`(오늘 요약·위젯·라이브 액티비티·알림), `AdPolicyUseCase`(광고 노출 규칙·지난 날 접근)
- Core: `MG2TodaySnapshotStore`(App Group), `MG2AdPolicyStore`, `MG2ReminderScheduler`
- App: `MG2TodaySurfaceRefresher`(WidgetKit·ActivityKit), `MG2AdMobProvider`(AdMob 11.13 + UMP, 테스트 ID만), `connectPieceIntents()`
- 위젯 확장 타깃 `MOGAKWidgetExtension` (`MOGAKWidget/`): 소형 미니 판, 중형 조각 체크, 라이브 액티비티
  - `Shared/`는 앱·위젯 두 타깃에 같이 들어감 (스냅샷 모델, ActivityAttributes, LiveActivityIntent, 에셋, 폰트)
  - 위젯·라이브 액티비티 버튼은 LiveActivityIntent라 앱 프로세스에서 실행됨
- 문구: 해요체 · 모다라트/모각/조각/최종 목표 용어 · 버튼은 하는 일을 적기
- AGENTS.md에 새 구조 설명 추가

## 사용자가 정한 것

- iOS 17로 올림
- AdMob은 테스트 ID만
- App Group: `group.com.team.mogaks` (앱·위젯 entitlements 둘 다 들어가 있음, 새 확장에도 꼭 넣기)
- 서버에 없는 API는 지어내지 말고 `TODO(server)`로만
- Duo(폴더블 아이폰) 레이아웃 포함
- 클린 아키텍처 · MVVM+C 위반 금지 (네비게이션은 Coordinator, VC는 VM만, VM은 UseCase만, 저장소는 Core가 Domain 프로토콜 구현)
- 시뮬레이터는 띄우지 않음 — 빌드 + 감사 스크립트로만 확인

## 남은 것

- 서버 API 필요 (`TODO(server)`): 이번 주 진척률(판 칸 채움·가운데 %·축하 카드 "이번 주"), 조각 타이머(hurry 포즈), 레이스 상태(지난주 비교), 조각 행 루틴 요일("루틴 · 월·수·금")
- 확인 필요: 위젯 번들 ID를 `com.team.mogaks.MOGAKWidget`로 정했음 → 포털 ID와 같은지
- 실제 동작 미확인: 위젯·라이브 액티비티 버튼으로 기록 바뀌는지, 광고·ATT·UMP, 확대 전환, Duo 2단, 전체 화면 모습
- 출시 전: AdMob 실제 ID로 교체 (`MG2AdMobProvider.swift`의 `TODO(ads)`, Info.plist `GADApplicationIdentifier`)
- 커밋 (새 브랜치 권장)

## 확인 명령

```sh
xcodebuild -project MOGAK.xcodeproj -scheme MOGAK -destination 'generic/platform=iOS Simulator' build
MOGAK2/scripts/architecture_audit.sh
MOGAK2/scripts/domain_rules_check.sh
```

마지막 실행 결과: 빌드 성공 · 감사 0건 · 규칙 체크 OK.
