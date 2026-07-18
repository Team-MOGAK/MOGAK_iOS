#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/Sources"
APP="$SRC/MG_App/Source"
CORE="$SRC/MG_Core/Source"
DATA="$SRC/MG_Data/Source"
DOMAIN="$SRC/MG_Domain/Source"
NETWORK="$SRC/MG_Network/Source"
PRESENTATION="$SRC/MG_Presentation/Source"
FEATURES="$PRESENTATION/Feature"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/mg2-architecture-audit.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

fail_count=0
check_count=0

pass() {
  printf '[PASS] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1"
  fail_count=$((fail_count + 1))
}

check_no_swift_match() {
  local label="$1"
  local pattern="$2"
  shift 2
  check_count=$((check_count + 1))
  local output="$TMP_DIR/rg-$check_count.txt"
  local status

  set +e
  rg -n --glob '*.swift' -- "$pattern" "$@" >"$output" 2>&1
  status=$?
  set -e

  case "$status" in
    0)
      fail "$label"
      cat "$output"
      ;;
    1)
      pass "$label"
      ;;
    *)
      fail "$label (scan failed)"
      cat "$output"
      ;;
  esac
}

if find "$DATA" -type d -name 'Scene' -print -quit | grep -q .; then
  fail "MG_Data contains a Scene directory"
else
  pass "MG_Data has no Scene directory"
fi

if find "$FEATURES" -type d -name 'API' -print -quit | grep -q .; then
  fail "MG_Presentation features contain API directories"
else
  pass "MG_Presentation features have no API directories"
fi

check_no_swift_match \
  "MG_Presentation has no concrete network dependency" \
  '^import Alamofire|URLSession|\bAF\.|\bNetworkProvider\b|\bRequestTarget\b' \
  "$PRESENTATION"

check_no_swift_match \
  "MG_Presentation does not reference Data-layer types" \
  '\bAPIConfig\b|\b[A-Za-z_][A-Za-z0-9_]*DTO\b|\b[A-Za-z_][A-Za-z0-9_]*Router\b' \
  "$PRESENTATION"

check_no_swift_match \
  "MG_Presentation does not use the service locator" \
  '\bDIContainer\b|\bMG2Deps\b' \
  "$PRESENTATION"

check_no_swift_match \
  "Presentation ViewModels do not depend on UIKit or infrastructure" \
  '^import UIKit$|\bRepository\b|\bRouter\b|\bNetworkProvider\b|\bUserDefaults\b|\bUIApplication\.shared\b' \
  "$FEATURES"/*/ViewModel

check_no_swift_match \
  "Domain does not depend on app state, storage, Data, or Network" \
  '\bAPIConfig\b|\b[A-Za-z_][A-Za-z0-9_]*DTO\b|\b[A-Za-z_][A-Za-z0-9_]*Router\b|\bNetworkProvider\b|\bMG2UserState\b|\bMG2SessionStore\b|\bUserDefaults\b' \
  "$DOMAIN"

check_no_swift_match \
  "MG_Data does not access app state or storage globals" \
  '\bDIContainer\b|\bMG2Deps\b|\bUserDefaults\b|\bMG2TokenStore\b|\bMG2SessionStore\b|\bMG2LaunchStorage\b' \
  "$DATA"

check_no_swift_match \
  "MG_Data repositories and DTOs do not import Alamofire" \
  '^import Alamofire$' \
  "$DATA/Repository" "$DATA/DTO"

check_no_swift_match \
  "MG_Network is independent from Data configuration and targets" \
  '\bAPIConfig\b|Bundle\.main|\bRequestTarget\b|\b[A-Za-z_][A-Za-z0-9_]*DTO\b|\b[A-Za-z_][A-Za-z0-9_]*Router\b' \
  "$NETWORK"

check_no_swift_match \
  "Core, Domain, Data, and Network do not import UI frameworks" \
  '^import (UIKit|SwiftUI|SnapKit|Then)$' \
  "$CORE" "$DOMAIN" "$DATA" "$NETWORK"

check_no_swift_match \
  "Core, Domain, Data, and Network do not declare view controllers" \
  '(^|[^A-Za-z0-9_])UIViewController([^A-Za-z0-9_]|$)' \
  "$CORE" "$DOMAIN" "$DATA" "$NETWORK"

check_no_swift_match \
  "MG_App does not contain feature views or view models" \
  'class[[:space:]]+[A-Za-z_][A-Za-z0-9_]*(ViewController|ViewModel)\b' \
  "$APP"

check_no_swift_match \
  "Presentation coordinators do not access UIApplication globally" \
  'UIApplication\.shared' \
  "$PRESENTATION/Common/Coordinator" "$FEATURES"/*/Coordinator

check_no_swift_match \
  "MG_Presentation does not access UIApplication globally" \
  'UIApplication\.shared' \
  "$PRESENTATION"

check_no_swift_match \
  "MG_Presentation has no forced casts or forced tries" \
  '\bas!\b|\btry!\b' \
  "$PRESENTATION"

check_no_swift_match \
  "API wire-format values do not leak into MG_Presentation" \
  'yyyy-MM-dd|\b(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY|SUNDAY)\b' \
  "$PRESENTATION"

navigation_output="$TMP_DIR/navigation-outside-coordinator.txt"
set +e
rg -n --glob '*.swift' --glob '!**/Coordinator/**' \
  '\.(pushViewController|popViewController|popToRootViewController|setViewControllers|present|dismiss)[[:space:]]*\(' \
  "$PRESENTATION" | rg -v 'picker\.dismiss\(' >"$navigation_output" 2>&1
navigation_status=$?
set -e
case "$navigation_status" in
  0)
    fail "App navigation is performed outside coordinators"
    cat "$navigation_output"
    ;;
  1)
    pass "App navigation is owned by coordinators"
    ;;
  *)
    fail "Navigation ownership scan failed"
    cat "$navigation_output"
    ;;
esac

construction_output="$TMP_DIR/screen-construction-outside-coordinator.txt"
set +e
rg -n --glob '*.swift' --glob '!**/Coordinator/**' \
  '\b[A-Za-z_][A-Za-z0-9_]*ViewController[[:space:]]*\(' \
  "$PRESENTATION" >"$construction_output" 2>&1
construction_status=$?
set -e
case "$construction_status" in
  0)
    fail "Feature screens are constructed outside coordinators"
    cat "$construction_output"
    ;;
  1)
    pass "Feature screen construction is owned by coordinators"
    ;;
  *)
    fail "Screen construction ownership scan failed"
    cat "$construction_output"
    ;;
esac

check_count=$((check_count + 1))
ui_output="$TMP_DIR/ui-responsibility-$check_count.txt"
set +e
rg -n --glob '*.swift' \
  --glob '**/View/**' \
  --glob '**/Cell/**' \
  --glob '**/Modal/**' \
  --glob '**/TimerView/**' \
  --glob '**/LocationFilter/**' \
  -- '\bUseCase\b|\bRepository\b|\bRouter\b|\bNetworkProvider\b|\bUserDefaults\b|\bMG2TokenStore\b|\bMG2SessionStore\b|\bMG2LaunchStorage\b' \
  "$FEATURES" >"$ui_output" 2>&1
ui_status=$?
set -e
case "$ui_status" in
  0)
    fail "Views, cells, and modals contain infrastructure or business dependencies"
    cat "$ui_output"
    ;;
  1)
    pass "Views, cells, and modals contain no infrastructure or business dependencies"
    ;;
  *)
    fail "UI responsibility scan failed"
    cat "$ui_output"
    ;;
esac

disabled_output="$TMP_DIR/disabled-files.txt"
find "$ROOT" -type f -name '*.disabled' -print >"$disabled_output"
if [[ -s "$disabled_output" ]]; then
  fail "Disabled source files remain in MOGAK2"
  cat "$disabled_output"
else
  pass "No disabled source files remain"
fi

check_no_swift_match \
  "Swift preview code has been removed" \
  '#Preview|PreviewProvider' \
  "$SRC"

duplicate_output="$TMP_DIR/duplicate-basenames.txt"
find "$SRC" -type f -name '*.swift' -print | awk -F/ '
  {
    count[$NF] += 1
    paths[$NF] = paths[$NF] "\n" $0
  }
  END {
    for (name in count) {
      if (count[name] > 1) {
        print name paths[name]
      }
    }
  }
' >"$duplicate_output"
if [[ -s "$duplicate_output" ]]; then
  fail "Duplicate Swift filenames exist"
  cat "$duplicate_output"
else
  pass "Swift filenames are unique"
fi

nested_output="$TMP_DIR/nested-features.txt"
find "$FEATURES" -mindepth 1 -maxdepth 1 -type d -print | while IFS= read -r feature; do
  name="$(basename "$feature")"
  if [[ -d "$feature/$name" ]]; then
    printf '%s\n' "$feature/$name"
  fi
done >"$nested_output"
if [[ -s "$nested_output" ]]; then
  fail "Duplicated nested feature directories exist"
  cat "$nested_output"
else
  pass "No duplicated nested feature directories exist"
fi

empty_view_models="$TMP_DIR/empty-view-models.txt"
find "$FEATURES" -type f -path '*/ViewModel/*.swift' -print | while IFS= read -r file; do
  if ! rg -q -- '(^|[[:space:]])(class|struct|actor|protocol)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*ViewModel\b' "$file"; then
    printf '%s\n' "$file"
  fi
done >"$empty_view_models"
if [[ -s "$empty_view_models" ]]; then
  fail "Empty or declaration-free ViewModel files exist"
  cat "$empty_view_models"
else
  pass "ViewModel files contain real declarations"
fi

then_import_output="$TMP_DIR/missing-then-imports.txt"
then_files="$TMP_DIR/then-files.txt"
set +e
rg -l --glob '*.swift' '\.then[[:space:]]*\{' "$SRC" >"$then_files"
then_scan_status=$?
set -e
if [[ "$then_scan_status" -gt 1 ]]; then
  fail "Then usage scan failed"
  cat "$then_files"
fi
while IFS= read -r file; do
  if ! rg -q '^import Then$' "$file"; then
    printf '%s\n' "$file"
  fi
done <"$then_files" >"$then_import_output"
if [[ -s "$then_import_output" ]]; then
  fail "Files using Then omit an explicit import"
  cat "$then_import_output"
else
  pass "Then dependencies are imported explicitly"
fi

if [[ "$fail_count" -gt 0 ]]; then
  printf '\nResult: FAILED (%d violations)\n' "$fail_count"
  exit 1
fi

printf '\nResult: PASSED (0 violations)\n'
