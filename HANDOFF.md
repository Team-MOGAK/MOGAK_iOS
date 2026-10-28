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

## 서버 API가 있어야 하는 것 (2026-10-28 메모)

앱에서는 못 끝내는 것. 코드에는 `TODO(server)`로 표시. 엔드포인트를 지어내지 말 것.

1. 이번 주 진척률 (판·모각별): 판 칸 채움·%, 가운데 목표 칸 % 캡슐, 축하 카드 "이번 주 %", 소형 위젯 미니 판 채움·가운데 %, 중형 위젯 "이번 주 n%", 판 바꾸기 목록 ProgressRing(40pt)
2. 조각 타이머: 모각이 hurry 포즈, 라이브 액티비티 timer 종류
3. 레이스(지난주 비교): 앞서면 thumbs · 뒤지면 sweat, "지난주보다 앞서고 있어요", 라이브 액티비티 race 종류 (규칙은 `MG2Mood`에 있고 입력만 없음)
4. 확인: 지난 날 기록은 `getJogakOccurrences(date:)`로 충분한지

## 2026-10-28 2차 (스펙 대조 후 앱에서 고친 것)

- 광고: 마이페이지 배너는 설치 2일째부터(`AdPolicyUseCase.canShowBanner`), 배너 위 간격 28. 앱 열기 광고는 홈 · 마이페이지 첫 화면에서만(`MG2MainTabViewController.allowsFullScreenAd`, 시트 · 판 · 모각 · 하위 화면 위 금지)
- 81칸 전체 보기(`MG2FullBoardViewController`): 판 헤더의 격자 버튼, 두 손가락 확대, 닫을 때 전면 광고 규칙. 아티팩트에 이 화면 스펙이 없어 토큰으로 구성
- PathBar(`MG2PathBarView`): 모각 · 조각 만들기/수정 화면 위 "판 › 모각 › 조각 n/8"
- 조각 행 둘째 줄 "루틴 · 월·수·금" (조각 상세로 요일을 불러옴, 실패하면 "루틴")
- 모각이 레이스 규칙(`MG2Mood.race`) 추가 — 입력은 TODO(server)
- 버그: 체크 때 폴짝 두 번 → 한 번, 보상형 광고로 연 날 저장(재실행해도 유지), 동작 줄이기 설정 바뀌면 숨쉬기 바로 반영
- 위젯: 앱이 내일 조각 요약을 미리 저장(`nextDaySnapshotKey`) → 자정에 새 날 조각으로 넘어감
- Duo 펼침 세로: 모든 탭 내용 560pt 가운데 열(`additionalSafeAreaInsets`)
- 글자: 직접 만든 폰트도 accessibility1까지만(`UIFont.scaledCapped`), 위젯 · 라이브 액티비티도 같은 상한, "오늘의 조각 n / m" 고정폭 숫자
- 문구: 해요체 · 하는 일을 말하는 버튼으로 정리 (탈퇴 확인, 로그인 안내, 가입 단계 버튼, 오류 문구 띄어쓰기, 로딩 문구에서 "서버" 뺌, "+ 조각 더 가져오기")
- 마이페이지 › 푸시 알림 화면(`MG2PushSettingViewController`): 매일 조각 알림 켜기/끄기 · 시각
- 안 쓰던 `DesignSystemFont` 삭제, 경고(deprecated API) 정리

## 남은 것

- 서버 API 필요: 위 "서버 API가 있어야 하는 것" 참고
- 정해야 할 것: 프로필 공유 · 위치 서비스 이용 동의는 아직 "준비 중이에요" 안내만 (기능 정의 필요)
- 확인 필요: 위젯 번들 ID를 `com.team.mogaks.MOGAKWidget`로 정했음 → 포털 ID와 같은지
- 실제 동작 미확인: 위젯·라이브 액티비티 버튼, 광고·ATT·UMP, 확대 전환, Duo 2단, 81칸 보기, 푸시 알림 설정, 전체 화면 모습
- 출시 전: AdMob 실제 ID로 교체 (`MG2AdMobProvider.swift`의 `TODO(ads)`, Info.plist `GADApplicationIdentifier`)
- 커밋 (새 브랜치 권장)

## 확인 명령

```sh
xcodebuild -project MOGAK.xcodeproj -scheme MOGAK -destination 'generic/platform=iOS Simulator' build
MOGAK2/scripts/architecture_audit.sh
MOGAK2/scripts/domain_rules_check.sh
```

마지막 실행 결과: 빌드 성공 · 감사 0건 · 규칙 체크 OK.
