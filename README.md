### MOGAK - 자기계발 동기부여 솔루션

## Migration Summary (Non-View)
1. 레거시 단일 API 브리지(`MG2LegacyAPIBridge`) -> Feature 브리지 분리
2. 레거시 단일 라우터(`LegacyFeatureRouter`) -> Scene/Feature 라우터 분리
3. 레거시 네트워크 직호출 중심 -> Clean Architecture(Entity/DTO/Repository/UseCase) 경유
4. 레거시 `MOGAK/Scene/**/API/*Network.swift` 실행 코드 -> `MOGAK2` 브리지 호출로 전환
5. 레거시 `MOGAK`의 기존 AF/URLSession 구현 -> 주석 처리(Traceability 유지)
6. 레거시 `MOGAK` 공용 네트워크(`ApiManager`, `NetworkManager`) -> `MG2LegacyCoreBridge` 경유
7. 레거시 Login API 혼합 구현 -> `Auth/User` UseCase + Repository 기반으로 정리
8. 레거시 multipart 업로드(브리지 직접) -> User Repository로 이동
9. 레거시 Apple revoke(URLSession 직접) -> Auth Repository/UseCase 경유
10. 레거시 혼합 폴더 구조 -> `MOGAK2/Sources/MG_Data/Source/{API,DTO,LegacyBridge}` 계층 통일 (`Scene` 제거)
11. 레거시 로그인 API(`UserModel/UserNetwork/UserRouter/LoginModel/LoginRouter/AppleLoginManage`) -> `MOGAK2` DTO/Entity/Service(`MG2UserNetwork`, `MG2AppleLoginManage`)로 전환 후 MOGAK `#if false` 비활성화

## Feature Foldering (MOGAK2)
- `API/Router/{Auth,History,Login,Modalart,Networking,ScheduleStart}`
- `API/Network/{History,Login,Modalart,Networking,ScheduleStart}`
- `DTO/{Auth,Common,History,Modalart,Networking,ScheduleStart,User}`
- `LegacyBridge/{History,Login,Modalart,ScheduleStart}`

## Clean Layers Added
- Entity: `Auth`, `ScheduleStart`, `Modalart`, `History`, `User`
- DTO: `Auth`, `ScheduleStart`, `Modalart`, `History`, `User`
- Repository: `Auth`, `ScheduleStart`, `Modalart`, `History`, `User`
- UseCase: `Auth`, `ScheduleStart`, `Modalart`, `History`, `User`

## Audit Snapshot
- 대상: `MOGAK/Scene/**/API`, `MOGAK/API`, `MOGAK/Service`, Login non-view manager
- 결과: 비주석 직접 네트워크 호출(`AF.request`, `AF.upload`, `URLSession.shared.dataTask`) 0건

## Migration Summary (Foundational View)
1. 레거시 온보딩 컨테이너(`AppGuideViewController`) -> `MG2OnboardingContainerViewController`
2. 레거시 탭바(`TabBarViewController`) -> `MG2MainTabBarController`
3. 레거시 App 진입 분기(SceneDelegate 직접 분기) -> `MG2AppFlowCoordinator + MG2AppLaunchViewModel`
4. 레거시 화면 생성 분산 -> `MG2LegacyViewFactory`로 통일
5. 공통 버튼 스타일 분산 -> `MG2PrimaryActionButton` 공통 컴포넌트화
6. 레거시 기본 View는 유지하되 SceneDelegate 라우팅은 MOGAK2 Presentation 경유로 전환
7. 레거시 마이페이지(`MyPageViewController`, `MyPageEditViewController`, `MypageWebViewController`) -> `MG2MyPage*` 1:1 마이그레이션 및 MOGAK 레거시 `#if false` 비활성화
8. 레거시 로그인/회원설정(`Login/Terms/Nickname/ChooseJob/ChooseRegion/Cell`) -> `MG2Login*` 1:1 마이그레이션 및 MOGAK 레거시 `#if false` 비활성화

## Full Folder Audit (MOGAK)
- Full-scan report: `MOGAK2/MIGRATION_AUDIT_STATUS.md`
- Snapshot:
  - Total Swift files in `MOGAK`: 143
  - Disabled via `#if false`: 143
  - Still active: 0

## Foldering Normalization (MOGAK2)
1. 네트워크 코드 재배치:
   - `MG_Presentation/Feature/**/API/*` -> `MG_Data/Source/API/{Router,Network}/*`
   - `MG_Presentation/Common/Service/MG2UserNetwork.swift` -> `MG_Data/Source/API/Network/Login/MG2UserNetwork.swift`
   - `MG_Presentation/Common/Service/MG2AppleLoginManage.swift` -> `MG_Data/Source/API/Network/Login/MG2AppleLoginManage.swift`
2. 공통/기반 코드 재배치:
   - `APIError`, `ApiConstants` -> `MG_Network/Source/Common`
   - `DesignSystem`, `UIFont/UIColor 확장` -> `MG_Design/Source`
   - 공용 컴포넌트/확장 -> `MG_Presentation/Source/Common/{Component,Extensions}`
   - `RegisterUserInfo` -> `MG_Core/Source/State`
   - `MogakModels` -> `MG_Data/Source/DTO/Common`
   - `WebLink` -> `MG_Domain/Source/Entity/Common`

## Clean Architecture Harden (Additional)
1. `MG_Presentation`의 `Alamofire` import 제거 (Presentation -> Network 직접 의존 제거)
2. `Networking` 피처의 API/Router/Response/Model를 `MG_Data/Source/API` + `MG_Data/Source/DTO/Networking`로 이동
3. `NetworkingViewController`의 직접 통신 제거, `MG2NetworkingViewModel` 경유로 변경
4. 로그인/프로필 수정 화면 네트워크 호출을 ViewController -> ViewModel로 이동
   - `MG2ProfileSetupViewModel` 추가
   - `MG2LoginViewModel`에서 Apple Login 시작 책임 수용
   - `MG2MyPageViewModel`에서 유저조회/로그아웃/탈퇴 책임 수용
5. `MG_Presentation` 기능 폴더 정규화
   - 중복 계층 제거: `Feature/<Feature>/<Feature>/...` -> `Feature/<Feature>/...`
   - 공통 구조 통일: `View`, `ViewModel`, `Coordinator`, `Component` 중심 재배치
6. Coordinator 적용 확장
   - `Login`, `MyPage`, `AppFlow`, `TabBar` 실사용 라우팅 연결
   - 나머지 피처(`ScheduleStart`, `Modalart`, `MyHistory`, `Networking`, `ScheduleList`, `ScheduleReport`, `InitEditMogakJogak`, `Onboarding`) Coordinator 골격 추가
7. `MG_Presentation` 폴더 세분화
   - `Feature/<Feature>/<Feature>/...` 제거 및 `Feature/<Feature>/...`로 평탄화
   - `*ViewController.swift`를 기능별 `View` 하위로 이동
   - 셀/보조 뷰 일부를 `Component` 폴더로 분리

## Migration Summary (ViewModel + UseCase Wiring, 2026-04-26)
1. `MG_Presentation`에서 View/Cell의 직접 API 호출 제거
   - `ModalartMainViewController`, `MogakMainViewController`, `MyHistoryViewController`
   - `MogakInitViewController`, `MogakEditViewController`, `JogakInitViewController`, `JogakEditViewController`
   - `ScheduleStartViewController`, `SelectJogakModal`, `ScheduleTableViewCell`
2. ViewModel 중심 호출 구조로 전환
   - `MG2ModalartViewModel`: `ModalartUseCase` 기반 조회/생성/수정/삭제 + 모각/조각 삭제
   - `MG2InitEditMogakJogakViewModel`: `HistoryUseCase` 기반 모각/조각 생성·수정
   - `MG2ScheduleStartViewModel`: `ScheduleStartUseCase` 기반 모다라트 계열 + 일일 조각 API 래핑
   - `MG2MyHistoryViewModel`: `MG2ModalartViewModel` 경유
3. Login/MyPage ViewModel UseCase 전환
   - `MG2ProfileSetupViewModel`: `UserUseCase` 기반 닉네임/직무/이미지/회원가입
   - `MG2MyPageViewModel`: `UserUseCase` + `AuthUseCase` 기반 유저조회/로그아웃/탈퇴
4. 검증 스크립트 추가
   - `MOGAK2/scripts/migration_gap_check.sh`
   - 점검 항목: Scene->Feature 폴더 대응, 핵심 폴더 규칙, View 직접 API 호출 금지, Presentation의 LegacyBridge 참조 금지, API 레이어 인벤토리
5. 구조/규칙 검증 결과
   - `MOGAK2/scripts/migration_gap_check.sh`: PASS
   - `MOGAK2/scripts/architecture_audit.sh`: PASSED (0 violations)
