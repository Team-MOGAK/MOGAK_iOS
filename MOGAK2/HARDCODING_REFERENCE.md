# MOGAK1 Hardcoding Reference (for MOGAK2 migration)

The following values are hardcoded in `MOGAK` and should remain behavior-compatible in `MOGAK2` for now.

## Keep hardcoded for now (behavior parity)

- API base URLs
  - `MOGAK/API/ApiManager.swift`: `https://mogak.shop:8080/`
  - `MOGAK/API/ApiConstants.swift`: `http://43.200.36.231:8080`
  - `MOGAK/Service/NetworkManager.swift`: `https://mogak.shop:8081`
  - `MOGAK/Scene/ScheduleStart/API/ApiRouter.swift`: `https://mogak.shop:8080`
- Authentication/UserDefaults keys
  - `accessToken`, `refreshToken`, `userId`, `isFirstTime`, `userName`, `userEmail`
- Temporary JWT literal used in networking feed request
  - `MOGAK/Scene/Networking/NetworkingViewController.swift` (`PacemakerFeedsGET`)
- Static local feed/filter data
  - `MOGAK/Scene/Networking/Data.swift`
  - Region list (서울특별시, 경기도, ...)
  - Category list (전체, 자격증, ...)
  - Sample comments and profile image names
- Static web links in my page
  - `MOGAK/Scene/MyPage/MyPageViewController.swift`

## Can be moved to server later (candidate list)

- Region and category lists currently in `MOGAK/Scene/Networking/Data.swift`
- Feed sample comments/default display text in `MOGAK/Scene/Networking/Data.swift`
- External web link menu targets in `MOGAK/Scene/MyPage/MyPageViewController.swift`
- API domain/path environment split (`8080`, `8081`, old IP) now spread across multiple files
- User-facing fallback messages and fixed status text literals in view controllers

## Migration policy applied in MOGAK2

- Active router path keeps `MOGAK1` endpoint style (e.g. `/api/modarats`).
- `MOGAK2` endpoint alternatives are intentionally left as commented placeholders next to active routes.
