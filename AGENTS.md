# AGENTS.md

This file documents how coding agents should understand and work in this repository.

## Project Context

- The workspace root is `/Users/ansehoon/Desktop/MOGAK_iOS`.
- `MOGAK2/` is the refactored and modularized codebase.
- All implementation, refactoring, and architecture work should target `MOGAK2/`.
- The former MOGAK1 source tree has been removed after migration verification.

## Working Rules

- Prefer small, migration-aligned changes over broad unrelated refactors.
- Do not revert user changes.
- When moving files, renaming types, or changing module boundaries, verify references and build impact.

## MOGAK2 Refactor

`MOGAK2/` contains the refactored version.

Primary goals:

- Separate Presentation, Domain, Data, Network, Core, and Design layers.
- Remove direct network calls from ViewControllers.
- Route UI behavior through ViewModel, UseCase, and Repository boundaries.
- Separate DTOs from Domain Entities.
- Organize navigation through Coordinators.
- Migrate features incrementally while preserving existing behavior.

## MOGAK2 Layers

```text
MOGAK2/Sources/
├── MG_App           # AppDelegate, SceneDelegate, composition root, social SDK adapters
├── MG_Core          # Local storage implementations (Keychain, UserDefaults)
├── MG_Domain        # Entities, UseCases, Repository/Storage interfaces, current user state
├── MG_Data          # DTOs, Repository implementations, API routers/networking
├── MG_Network       # Network provider and shared API handling
├── MG_Presentation  # ViewControllers, ViewModels, Coordinators, UI components
└── MG_Design        # Design tokens (colors, fonts) and assets
```

Outside `MOGAK2/` (2026-10 design system rollout):

```text
Shared/        # compiled into the app AND MOGAKWidgetExtension: MG2TodaySnapshot, Live Activity attributes, piece AppIntents, Mascot.xcassets, Fonts
MOGAKWidget/   # WidgetKit extension (home widget + Live Activity UI). Reads the App Group snapshot only; no network.
```

- App Group `group.com.team.mogaks` is on both targets (`Configuration/MOGAK.entitlements`, `Configuration/MOGAKWidget.entitlements`).
- Widget/Live Activity buttons are `LiveActivityIntent`s, so they run in the app process; `MG2AppComposition.connectPieceIntents()` fills `MG2PieceIntentBridge` with `TodayUseCase` calls. The widget copy stays empty.
- Design tokens are `DS` (colors/space/radius/size/shadow, `DS.Moak`, `DS.Pose`) and `T` (Pretendard + Dynamic Type) in `MG_Design/Source/Foundation/DS.swift`. Pretendard otf files live in `Shared/Fonts` (app + widget). Server palette hex values (`DesignSystemPalette`) are payloads and stay unchanged; map them with `DS.Moak.from(hex:)` / `displayColor(forServerHex:)`.
- Ads: `MG2AdProviding` (Presentation protocol) is implemented by `MG2AdMobProvider` in MG_App; only coordinators call it. When to show ads is `AdPolicyUseCase` (Domain). Test ad unit IDs only for now. Since 2026-10-30 every ad call site (SDK start with ATT/UMP, app-open, interstitials, rewarded, banner, native) is commented out with `// TODO(ads)` until an app update; search that tag to re-enable. The native ad now lives on the Modalart tab between the board and the tab bar (Home has none). While ads are off, days 2–7 back open without the rewarded ad.
- Mascot pose rules live in `MG2Mood` (Domain); check them with `MOGAK2/scripts/domain_rules_check.sh`.
- Server-blocked features (weekly progress, piece timer, race vs last week) stay `TODO(server)`; never invent endpoints. Wide screens (Duo unfolded portrait) get a 560pt content column via `additionalSafeAreaInsets` in `MG2MainTabViewController`. Custom-size fonts go through `UIFont.scaledCapped` so Dynamic Type stops at accessibility1.
- Loading rules (no full-screen loader): (1) API-driven content → open the screen immediately and cover only API-driven components as whole blocks (`showSkeletonBlocks()` / `hideSkeletonBlocks()`, drawn by SkeletonView; whole cells/cards/title boxes, placeholder cells while lists are empty) until all of the screen's data has arrived, then cross-fade in; static UI (icon buttons, fixed text, controls) never becomes a skeleton; (2) refreshing content already on screen is silent (no skeleton), switching to different content (date, board, chip) skeletons only the part that changes; (3) load-then-navigate (`beginPendingTransition()`) only where inputs must be prefilled (jogak edit form, jogak actions sheet); (4) user actions → `control.setLoading(true/false)` in the tapped button or row. Only the splash shows a standalone spinner. Order with transitions (push/zoom/sheet): the skeleton is part of the destination from the first frame (no fade-in, follows layout instantly), its shimmer starts after the transition ends, and loaded content cross-fades in only after the transition ends (`afterTransition`).
- iOS-native first: the design artifact is web-based, so copy its look but build with native iOS components and behaviour (system `UITabBarController`, `UISegmentedControl`, paging `UICollectionView`, `UISheetPresentationController`, `SFSafariViewController`, UIKit spring/keyframe animations, native zoom transition). No web views; the only third-party UI library is SkeletonView (skeletons).

## Dependency Direction

Preferred dependency flow:

```text
Presentation -> Domain
Data -> Domain
Data -> Network
Core -> Domain   (implements Domain storage interfaces such as SessionStorage)
App -> Core / Presentation / Domain / Data
```

Important constraints:

- Do not add direct Alamofire or URLSession API calls in `MG_Presentation`.
- Do not call Repository or Network objects directly from ViewControllers.
- ViewControllers should communicate with ViewModels for state and actions.
- ViewModels should call Domain UseCases.
- ViewModels never touch storage or change `MG2UserState`; login, logout, signup and profile changes go through `AuthUseCase` / `UserUseCase`.
- Business rules (e.g. default modalart titles, multi-request loading) live in UseCases, not ViewModels.
- UseCases are concrete classes. Only interfaces implemented outside Domain are protocols (Repository, `SessionStorage`, `SocialTokenProvider`).
- `MG2AppComposition` (MG_App) is the single composition root: it creates the stores, network provider, repositories, use cases, and coordinators. There is no DI container, so add new dependencies there and pass them down through initializers.
- Repository implementations and DTO mapping belong in `MG_Data`.
- Server formats (raw codes, `yyyy-MM-dd` strings, `#RRGGBB` colors, typos like `modaratId`) are converted in DTOs/Routers and never reach Domain or Presentation.
- API contract (2026-09 handoff): modalart/mogak/jogak edits use `PATCH` with `application/merge-patch+json`; mogak edit sends `category` as a `SYSTEM`/`CUSTOM` tagged union while create keeps the flat fields; jogak edit schedules omit `effectiveFrom` and send `weekdays: []` for `ONCE`; withdraw returns `204` with no body; `401` and `403 / T006` both trigger one token refresh and one retry. A refresh the server rejects (400/401/403/404 → `MG2AuthError.sessionExpired`) clears the session only at launch (`restoreSession`) or on logout; during use screens just show the error copy (no automatic sign-out). Offline, timeout and 5xx never clear tokens. Tokens, userId and registration live in the keychain so a reinstall auto-logs in. API dates (`yyyy-MM-dd`) use the device time zone, the same as the app's "today". Sign-out, withdraw and guest clear the widget snapshot and end Live Activities (`TodayUseCase.clearSurfaces`).
- Server bootstrap: the launch screen waits for `GET /health/ready` (`ServerReadinessUseCase`: 15s per request, 30s total, at most 3 attempts with full-jitter backoff, shared in-flight ping) before `restoreSession` or any other business API. The splash is the only loading on app start: it then restores the session and, for the main route, preloads the home tab (`MG2TabBarCoordinator.prepare()`) before cross-fading to main; the home screen refreshes silently on later visits. Mutation APIs are never retried automatically.
- User-facing errors: `DefaultNetworkProvider` only throws `MG2NetworkError`, whose `errorDescription` is Korean copy chosen by status/kind; server `message` text and SDK errors are never shown. Login failures show only "로그인 실패", and a user-cancelled social login (`MG2SocialLoginError.cancelled`) shows nothing.

## Migration Guidelines

- Place migrated code according to the MOGAK2 layer rules.
- Preserve established MOGAK2 screen behavior when refactoring.

## Verification

When possible, verify changes with:

```sh
xcodebuild -project MOGAK.xcodeproj -scheme MOGAK -destination 'generic/platform=iOS Simulator' build
```

Architecture checks may use:

```sh
MOGAK2/scripts/architecture_audit.sh
```

## Communication

- The user often communicates in Korean, so answer in Korean by default.
- Keep explanations concise and focused on changed files and reasons.
- If a build or test was not run, say so clearly.
