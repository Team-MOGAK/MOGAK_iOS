# AGENTS.md

This file documents how coding agents should understand and work in this repository.

## Project Context

- The workspace root is `/Users/ansehoon/Desktop/MOGAK_iOS`.
- `MOGAK/` is the MOGAK1 legacy codebase.
- `MOGAK2/` is the refactored and modularized codebase.
- Default implementation, refactoring, and architecture work should target `MOGAK2/`.
- Use `MOGAK/` as the behavior reference when checking legacy implementation details or doing 1:1 migration work.

## Working Rules

- Do not edit legacy `MOGAK/` code unless the task explicitly requires it.
- Features migrated into `MOGAK2/` should preserve the behavior and screen flow of the legacy `MOGAK/` implementation.
- Prefer small, migration-aligned changes over broad unrelated refactors.
- Do not revert user changes.
- When moving files, renaming types, or changing module boundaries, verify references and build impact.

## MOGAK1 Legacy

`MOGAK/` contains the original app implementation.

- UIKit-based ViewController-heavy structure.
- View, network, and model logic may be mixed inside feature folders.
- Source of truth for existing app behavior.
- Reference target for MOGAK2 migration.

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
├── MG_App           # AppDelegate, SceneDelegate, app bootstrap, app-level coordinators
├── MG_Core          # DI, shared state, core interfaces
├── MG_Domain        # Entities, UseCases, Repository interfaces
├── MG_Data          # DTOs, Repository implementations, API routers/networking
├── MG_Network       # Network provider and shared API handling
├── MG_Presentation  # ViewControllers, ViewModels, Coordinators, UI components
└── MG_Design        # Design system, shared UI components, styles
```

## Dependency Direction

Preferred dependency flow:

```text
Presentation -> Domain
Data -> Domain
Data -> Network
App -> Core / Presentation / Domain / Data
```

Important constraints:

- Do not add direct Alamofire or URLSession API calls in `MG_Presentation`.
- Do not call Repository or Network objects directly from ViewControllers.
- ViewControllers should communicate with ViewModels for state and actions.
- ViewModels should call Domain UseCases.
- Repository implementations and DTO mapping belong in `MG_Data`.

## Migration Guidelines

- Before migrating a feature into MOGAK2, inspect the MOGAK1 screen flow, API parameters, response handling, and error handling.
- Place migrated code according to the MOGAK2 layer rules.
- Only disable or disconnect legacy files when the full project can still build.
- Do not judge migration status by folder presence alone. Check actual call paths.

## Verification

When possible, verify changes with:

```sh
xcodebuild -project MOGAK.xcodeproj -scheme MOGAK -destination 'generic/platform=iOS Simulator' build
```

Migration structure checks may use:

```sh
MOGAK2/scripts/migration_gap_check.sh
MOGAK2/scripts/architecture_audit.sh
```

## Communication

- The user often communicates in Korean, so answer in Korean by default.
- Keep explanations concise and focused on changed files and reasons.
- If a build or test was not run, say so clearly.
