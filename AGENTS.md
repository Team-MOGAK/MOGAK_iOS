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
