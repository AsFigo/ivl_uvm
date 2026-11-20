#!/bin/sh
# Copyright (c) 2026 AsFigo (https://www.asfigo.com)
#
# Usage: ivl_uvm_check.sh check|gold [test numbers...]
#   check - run each test (make vwN), normalise its logs, diff against ../goldLogs
#   gold  - run each test and (re)write the golden logs in ../goldLogs
# Logs are normalised so that edits to the sources do not break the comparison:
# file paths and line numbers are removed from report tags, the rest (time stamps,
# ids, messages, severity counts, final PASSED/FAILED line) is compared as is.

mode=$1; shift
tests=${*:-0 1 2 3 4 5 6 7 8 9 10 11}
gold_dir=../goldLogs
res_dir=results
mkdir -p "$res_dir" "$gold_dir"

norm() {
  sed -E \
    -e 's/^(UVM_[A-Z]+) [^ ]*\([0-9]+\) @/\1 @/' \
    -e 's/^[^ ]*:[0-9]+: (\$finish)/\1/' \
    -e 's#(\.\./)+(ivl_uvm_[a-z_]+/)#\2#g' \
    "$1"
}

pass=0; fail=0; failed=""
for t in $tests; do
  make -s "vw$t" > "$res_dir/make_$t.out" 2>&1
  ok=1
  for f in ivl_uvm_comp_$t.log ivl_uvm_run_$t.log ivl_uvm_run_${t}_*.log; do
    [ -f "$f" ] || continue
    norm "$f" > "$res_dir/$f"
    if [ "$mode" = gold ]; then
      cp "$res_dir/$f" "$gold_dir/$f.gold"
    elif [ ! -f "$gold_dir/$f.gold" ]; then
      echo "  no gold for $f"; ok=0
    elif ! diff -q "$res_dir/$f" "$gold_dir/$f.gold" > /dev/null; then
      diff "$gold_dir/$f.gold" "$res_dir/$f" | head -10 | sed 's/^/    /'
      ok=0
    fi
  done
  if [ "$mode" = gold ]; then
    echo "vw$t: gold written"
  elif [ $ok = 1 ]; then
    echo "vw$t: PASS"; pass=$((pass+1))
  else
    echo "vw$t: FAIL"; fail=$((fail+1)); failed="$failed vw$t"
  fi
done
if [ "$mode" = check ]; then
  echo "ivl_uvm regression: $pass passed, $fail failed$failed"
  [ $fail = 0 ]
fi
