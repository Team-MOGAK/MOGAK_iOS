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
- API contract (2026-09 handoff): modalart/mogak/jogak edits use `PATCH` with `application/merge-patch+json`; mogak edit sends `category` as a `SYSTEM`/`CUSTOM` tagged union while create keeps the flat fields; jogak edit schedules omit `effectiveFrom` and send `weekdays: []` for `ONCE`; withdraw returns `204` with no body; `401` and `403 / T006` both trigger one token refresh and one retry.

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
