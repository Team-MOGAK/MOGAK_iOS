#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/Sources"
PRES="$SRC/MG_Presentation/Source"
DATA="$SRC/MG_Data/Source"
DOMAIN="$SRC/MG_Domain/Source"
NETWORK="$SRC/MG_Network/Source"

fail_count=0

fail() {
  echo "[FAIL] $1"
  fail_count=$((fail_count+1))
}

pass() {
  echo "[PASS] $1"
}

# 1) MG_Data should not contain Scene folder
if find "$DATA" -type d -name 'Scene' | grep -q .; then
  fail "MG_Data contains forbidden 'Scene' directory"
else
  pass "MG_Data has no 'Scene' directory"
fi

# 2) Presentation Feature should not contain API directory
if find "$PRES/Feature" -type d -name 'API' | grep -q .; then
  fail "MG_Presentation/Feature contains forbidden 'API' directories"
else
  pass "MG_Presentation/Feature has no 'API' directories"
fi

# 3) Presentation should not import Alamofire
if rg -n '^import Alamofire' "$PRES" -g '*.swift' >/tmp/mg2_audit_alamofire.txt 2>/dev/null; then
  fail "MG_Presentation imports Alamofire"
  cat /tmp/mg2_audit_alamofire.txt
else
  pass "MG_Presentation has no Alamofire import"
fi

# 4) Non-presentation layers should not declare UIViewController classes
if rg -n 'class .*UIViewController|: UIViewController' "$DATA" "$DOMAIN" "$NETWORK" -g '*.swift' >/tmp/mg2_audit_uivc.txt 2>/dev/null; then
  fail "Non-presentation layer declares UIViewController"
  cat /tmp/mg2_audit_uivc.txt
else
  pass "No UIViewController in Data/Domain/Network"
fi

# 5) Domain should not import UIKit/SwiftUI/SnapKit/Then
if rg -n '^import (UIKit|SwiftUI|SnapKit|Then)' "$DOMAIN" -g '*.swift' >/tmp/mg2_audit_domain_imports.txt 2>/dev/null; then
  fail "Domain imports UI/framework libraries"
  cat /tmp/mg2_audit_domain_imports.txt
else
  pass "Domain has no UI/framework imports"
fi

# 6) Each feature should have Coordinator and ViewModel directory with >=1 swift file (AppFlow exempt from View)
python3 - << 'PY' "$PRES/Feature" > /tmp/mg2_audit_features.txt
import os,glob,sys
base=sys.argv[1]
features=sorted([d for d in os.listdir(base) if os.path.isdir(os.path.join(base,d))])
ok=True
for f in features:
    fdir=os.path.join(base,f)
    has_coord=bool(glob.glob(os.path.join(fdir,'Coordinator','*.swift')))
    has_vm=bool(glob.glob(os.path.join(fdir,'ViewModel','*.swift')))
    if not has_coord or not has_vm:
        ok=False
        print(f"MISSING {f}: coord={has_coord} vm={has_vm}")
if ok:
    print("OK")
PY

if grep -q '^OK$' /tmp/mg2_audit_features.txt; then
  pass "All features have Coordinator and ViewModel"
else
  fail "Some features miss Coordinator/ViewModel"
  cat /tmp/mg2_audit_features.txt
fi

# 7) Duplicated nested feature directory should not exist (Feature/X/X)
python3 - << 'PY' "$PRES/Feature" > /tmp/mg2_audit_nested.txt
import os,sys
base=sys.argv[1]
viol=[]
for f in os.listdir(base):
    p=os.path.join(base,f)
    if not os.path.isdir(p):
        continue
    nested=os.path.join(p,f)
    if os.path.isdir(nested):
        viol.append(nested)
if not viol:
    print('OK')
else:
    for v in viol:
        print(v)
PY

if grep -q '^OK$' /tmp/mg2_audit_nested.txt; then
  pass "No duplicated nested feature directories"
else
  fail "Duplicated nested feature directories exist"
  cat /tmp/mg2_audit_nested.txt
fi

if [ "$fail_count" -gt 0 ]; then
  echo "\nResult: FAILED ($fail_count violations)"
  exit 1
fi

echo "\nResult: PASSED (0 violations)"
