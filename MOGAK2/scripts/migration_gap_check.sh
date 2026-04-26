#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LEGACY_SCENE="$ROOT/MOGAK/Scene"
PRESENTATION_FEATURE="$ROOT/MOGAK2/Sources/MG_Presentation/Source/Feature"
DATA_API="$ROOT/MOGAK2/Sources/MG_Data/Source/API"

status=0

echo "[1/5] Feature Folder Parity (MOGAK Scene -> MOGAK2 Feature)"
for legacy_dir in "$LEGACY_SCENE"/*; do
  [ -d "$legacy_dir" ] || continue
  feature="$(basename "$legacy_dir")"
  target="$PRESENTATION_FEATURE/$feature"

  legacy_count=$(find "$legacy_dir" -type f -name '*.swift' ! -name '* 2.swift' | wc -l | tr -d ' ')
  if [ -d "$target" ]; then
    new_count=$(find "$target" -type f -name '*.swift' | wc -l | tr -d ' ')
    printf -- "- %-20s legacy=%-3s mg2=%-3s\n" "$feature" "$legacy_count" "$new_count"
  else
    printf -- "- %-20s legacy=%-3s mg2=%-3s  [MISSING]\n" "$feature" "$legacy_count" "0"
    status=1
  fi
done

if [ -f "$ROOT/MOGAK/Scene/TabBarViewController.swift" ]; then
  tab_target="$PRESENTATION_FEATURE/TabBar"
  if [ ! -d "$tab_target" ]; then
    echo "- TabBar                legacy=1   mg2=0    [MISSING]"
    status=1
  fi
fi

echo
echo "[2/5] Feature Core Folder Rule"
missing_core=$(python3 - <<'PY'
from pathlib import Path
base = Path('MOGAK2/Sources/MG_Presentation/Source/Feature')
miss = []
for f in sorted([p for p in base.iterdir() if p.is_dir()]):
    for req in ('View','ViewModel','Coordinator'):
        if not (f/req).is_dir():
            miss.append(f"{f.name}/{req}")
print('\n'.join(miss))
PY
)
if [ -n "$missing_core" ]; then
  echo "$missing_core"
  status=1
else
  echo "- OK (all features include View/ViewModel/Coordinator)"
fi

echo
echo "[3/5] View Direct API Call Check"
direct_calls=$(rg -n "\\b(Apinetwork|modalartNetwork|mogakNetwork|userNetwork|network)\\.[A-Za-z_]+\\(" \
  "$ROOT/MOGAK2/Sources/MG_Presentation/Source/Feature" -g "*.swift" | rg -v "/ViewModel/" | rg -v ":[0-9]+:\\s*//" || true)
if [ -n "$direct_calls" ]; then
  echo "$direct_calls"
  status=1
else
  echo "- OK (direct API calls removed from View/Cell/Coordinator)"
fi

echo
echo "[4/5] LegacyBridge Usage Scope"
bridge_in_presentation=$(rg -n "MG2Legacy[A-Za-z]+Bridge\\.shared" "$ROOT/MOGAK2/Sources/MG_Presentation" -g "*.swift" || true)
if [ -n "$bridge_in_presentation" ]; then
  echo "$bridge_in_presentation"
  status=1
else
  echo "- OK (LegacyBridge not referenced in Presentation)"
fi

echo
echo "[5/5] API Layer Inventory"
legacy_api=$(find "$ROOT/MOGAK/Scene" -type f -path '*/API/*.swift' | wc -l | tr -d ' ')
mg2_api=$(find "$DATA_API" -type f -name '*.swift' | wc -l | tr -d ' ')
mg2_bridge=$(find "$ROOT/MOGAK2/Sources/MG_Data/Source/LegacyBridge" -type f -name '*.swift' | wc -l | tr -d ' ')
printf -- "- legacy_scene_api_files=%s\n- mg2_data_api_files=%s\n- mg2_legacy_bridge_files=%s\n" "$legacy_api" "$mg2_api" "$mg2_bridge"

if [ "$status" -ne 0 ]; then
  echo
  echo "RESULT: GAP FOUND"
  exit 2
fi

echo
echo "RESULT: PASS"
