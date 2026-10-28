#!/usr/bin/env bash
# 모각이 포즈 규칙과 광고 노출 규칙을 앱 없이 swiftc로 확인한다.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOMAIN="$ROOT/Sources/MG_Domain/Source"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/mg2-domain-check.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

cat >"$TMP_DIR/main.swift" <<'EOF'
import Foundation

func pose(_ done: Int, _ total: Int, evening: Bool = false, missed: Bool = false) -> MG2MoakPose {
    MG2Mood(done: done, total: total, isEvening: evening, missedYesterday: missed).pose(done: done, total: total)
}

assert(pose(0, 5) == .wave)
assert(pose(1, 5) == .wink)
assert(pose(2, 5) == .peace)
assert(pose(3, 6) == .thumbs)
assert(pose(4, 5) == .fighting)
assert(pose(5, 5) == .proud)
assert(pose(0, 5, missed: true) == .tired)
assert(pose(1, 5, evening: true) == .sweat)
assert(pose(3, 5, evening: true) == .think)
assert(pose(5, 5, evening: true) == .proud)
assert(MG2Mood(done: 0, total: 0).pose(done: 0, total: 0) == .wave)
assert(MG2Mood(done: 0, total: 0, isTimerRunning: true).pose(done: 0, total: 0) == .hurry)
assert(MG2Mood(done: 1, total: 5).line(done: 1, total: 5) == "좋아요, 1개 했어요!")
assert(MG2Mood(done: 2, total: 5, raceAhead: true).pose(done: 2, total: 5) == .thumbs)
assert(MG2Mood(done: 2, total: 5, raceAhead: false).pose(done: 2, total: 5) == .sweat)
assert(MG2Mood(done: 2, total: 5, isTimerRunning: true, raceAhead: true).pose(done: 2, total: 5) == .hurry)

final class Store: AdPolicyStorage {
    var installDate: Date?
    var interstitialDates = [Date]()
    var lastAppOpenAdDate: Date?
    var lastBackgroundDate: Date?
    var unlockedPastDays = [Date]()
}

let day: TimeInterval = 86_400
let start = Calendar.current.startOfDay(for: Date()).addingTimeInterval(12 * 3600)
var clock = start
let store = Store()
let policy = AdPolicyUseCase(storage: store, now: { clock })

assert(policy.registerLaunch())
assert(!policy.registerLaunch())
assert(!policy.canShowNativeAd && !policy.canShowBanner && !policy.canShowInterstitial)
clock = start + day
assert(policy.canShowNativeAd && policy.canShowBanner && !policy.canShowInterstitial)
clock = start + 2 * day
assert(policy.canShowInterstitial)
policy.didShowInterstitial()
assert(!policy.canShowInterstitial)
clock += 5 * 60
assert(policy.canShowInterstitial)
policy.didShowInterstitial()
clock += 10 * 60
assert(!policy.canShowInterstitial)

policy.didEnterBackground()
clock += 3 * 3600
assert(!policy.canShowAppOpenAd)
clock += 3600
assert(policy.canShowAppOpenAd)
policy.didShowAppOpenAd()
assert(!policy.canShowAppOpenAd)

assert(policy.pastDayAccess(for: clock) == .editable)
assert(policy.pastDayAccess(for: clock - day) == .editable)
assert(policy.pastDayAccess(for: clock - 3 * day) == .rewardRequired)
policy.unlockPastDay(clock - 3 * day)
assert(policy.pastDayAccess(for: clock - 3 * day) == .editable)
assert(AdPolicyUseCase(storage: store, now: { clock }).pastDayAccess(for: clock - 3 * day) == .editable)
assert(policy.pastDayAccess(for: clock - 8 * day) == .readOnly)

print("domain rules: OK")
EOF

# AdPolicyStorage만 필요하므로 인터페이스 파일에서 그 프로토콜만 뽑아 쓴다.
sed -n '/^protocol AdPolicyStorage/,/^}/p' "$DOMAIN/Interface/TodayInterfaces.swift" >"$TMP_DIR/stubs.swift"
sed -i '' '1s/^/import Foundation\n/' "$TMP_DIR/stubs.swift"

xcrun swiftc -Onone -o "$TMP_DIR/check" \
  "$DOMAIN/Entity/Today/MG2Mood.swift" \
  "$DOMAIN/Usecase/AdPolicyUseCase.swift" \
  "$TMP_DIR/stubs.swift" \
  "$TMP_DIR/main.swift"
"$TMP_DIR/check"
