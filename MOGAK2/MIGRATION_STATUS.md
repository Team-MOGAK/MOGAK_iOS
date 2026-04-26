# MOGAK1 -> MOGAK2 Migration Status

Policy
- Migrate non-view layers first (network/domain/data/util).
- Keep MOGAK1 behavior stable during migration.
- Once a feature runs through MOGAK2, keep legacy MOGAK1 implementation commented for traceability.
- View layer migration is intentionally deferred to the final phase.

## Completed (non-view)

1. MOGAK2 module structure normalized
- `MG_App`, `MG_Core`, `MG_Data`, `MG_Domain`, `MG_Network`, `MG_Design` reorganized around `Source` and required `Resource` only.

2. Scene-based API foldering in MOGAK2
- `MG_Data/Source/Scene/<Feature>/API` structure applied:
  - `Scene/Modalart/API`: `MG2ModalartRouter`, `MG2LegacyModalartBridge`, `MG2LegacyMogakDetailBridge`
  - `Scene/InitEditMogakJogak/API`: `MG2HistoryRouter`, `MG2LegacyHistoryBridge`
  - `Scene/ScheduleStart/API`: `ScheduleStartLegacyBridge`, `MG2ScheduleStartRouter`, `MG2LegacyScheduleStartBridge`
  - `Scene/Login/API`: `MG2LegacyAuthBridge*`, `MG2UserRouter`, `MG2LegacyUserBridge*`
- Removed monolithic legacy API adapter/router:
  - `MG2LegacyAPIBridge` removed
  - `LegacyFeatureRouter` removed

3. Clean Architecture layers added per feature (View 제외)
- Added Entity/DTO/Repository/UseCase for:
  - `Modalart`
  - `History (InitEditMogakJogak)`
  - `User profile (nickname/job/profile)`
- Existing `ScheduleStart`, `Auth` clean layers remain active.

4. MOGAK1 non-view runtime routes migrated to MOGAK2 bridges
- `MOGAK/Scene/*/API/*Network.swift` network execution paths now route through MOGAK2 bridges.
- `MOGAK/API/ApiManager.swift`, `MOGAK/Service/NetworkManager.swift` route through `MG2LegacyCoreBridge`.
- Login token flow also bridged:
  - `MOGAK/Scene/Login/SnsLoginManage/CommonLoginManage.swift`
  - `MOGAK/Scene/Login/SnsLoginManage/AppleLoginManage.swift`

5. Legacy implementation commenting policy applied in MOGAK1
- For migrated non-view execution paths, previous MOGAK1 implementation remains as commented legacy blocks.

## Verification snapshot
- Active direct network call scan in MOGAK non-view paths:
  - non-comment `AF.request(...)`: 0
  - non-comment `AF.upload(...)`: 0
  - non-comment `URLSession.shared.dataTask(...)`: 0

## In Progress (non-view)

1. Shared constants/util hardcoding cleanup (behavior-preserving)
- Keep runtime behavior hardcoded where required.
- Maintain server-migration candidate list in `HARDCODING_REFERENCE.md`.

## Final Phase (deferred)

- View layer migration (`Scene/**/ViewController`, custom cells, modal views)
- UI unification by design tokens/components after non-view migration is complete
