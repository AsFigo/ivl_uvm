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
tests=${*:-0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37}
gold_dir=../goldLogs
# Targets that are expected to end in a UVM failure: one line per target,
# "number|text that must be in the run log|reason".
expected_file=../expected_fail.list
res_dir=results
mkdir -p "$res_dir" "$gold_dir"

norm() {
  sed -E \
    -e 's/^(UVM_[A-Z]+) [^ ]*\([0-9]+\) @/\1 @/' \
    -e 's/^[^ ]*:[0-9]+: (\$finish)/\1/' \
    -e 's#(\.\./)+(ivl_uvm_[a-z_]+/)#\2#g' \
    "$1"
}

case "$mode" in
  check|gold) ;;
  *) echo "Usage: $0 check|gold [test numbers...]" >&2; exit 2 ;;
esac

# A target passes only if make succeeds, a run log is produced, every log the
# gold directory expects for the test is produced, and every produced log
# matches its gold. An unknown target, a make failure or a missing log is a
# failure, never a pass. Gold mode writes nothing for a target that fails
# these checks.
pass=0; fail=0; failed=""
for t in $tests; do
  make -s "vw$t" > "$res_dir/make_$t.out" 2>&1
  rc=$?
  ok=1
  if [ $rc != 0 ]; then
    echo "  make vw$t failed (exit $rc), see $res_dir/make_$t.out"; ok=0
  fi

  have_run=0
  for f in ivl_uvm_run_$t.log ivl_uvm_run_${t}_*.log; do
    [ -f "$f" ] && have_run=1
  done
  if [ $have_run = 0 ]; then
    echo "  no run log produced (ivl_uvm_run_$t.log)"; ok=0
  fi

  if [ "$mode" = check ]; then
    for g in "$gold_dir"/ivl_uvm_comp_$t.log.gold "$gold_dir"/ivl_uvm_run_$t.log.gold \
             "$gold_dir"/ivl_uvm_run_${t}_*.log.gold; do
      [ -f "$g" ] || continue
      f=$(basename "$g" .gold)
      if [ ! -f "$f" ]; then
        echo "  expected log not produced: $f"; ok=0
      fi
    done
  fi

  exp_line=""
  if [ -f "$expected_file" ]; then
    exp_line=$(grep "^$t|" "$expected_file" | head -1)
  fi
  exp_text=$(printf '%s\n' "$exp_line" | cut -d'|' -f2)
  exp_why=$(printf '%s\n' "$exp_line" | cut -d'|' -f3-)
  if [ -n "$exp_line" ] && [ "$mode" = check ]; then
    if [ ! -f "ivl_uvm_run_$t.log" ] || ! grep -F -q -- "$exp_text" "ivl_uvm_run_$t.log"; then
      echo "  expected failure not seen in ivl_uvm_run_$t.log: $exp_text"; ok=0
    fi
  fi

  for f in ivl_uvm_comp_$t.log ivl_uvm_run_$t.log ivl_uvm_run_${t}_*.log; do
    [ -f "$f" ] || continue
    norm "$f" > "$res_dir/$f"
    if [ "$mode" = gold ]; then
      if [ $ok = 1 ]; then
        cp "$res_dir/$f" "$gold_dir/$f.gold"
      fi
    elif [ ! -f "$gold_dir/$f.gold" ]; then
      echo "  no gold for $f"; ok=0
    elif ! diff -q "$res_dir/$f" "$gold_dir/$f.gold" > /dev/null; then
      diff "$gold_dir/$f.gold" "$res_dir/$f" | head -10 | sed 's/^/    /'
      ok=0
    fi
  done

  if [ $ok = 1 ]; then
    if [ "$mode" = gold ]; then
      echo "vw$t: gold written"
    elif [ -n "$exp_line" ]; then
      echo "vw$t: PASS (expected failure: $exp_why)"
    else
      echo "vw$t: PASS"
    fi
    pass=$((pass+1))
  else
    if [ "$mode" = gold ]; then
      echo "vw$t: FAIL (gold not written)"
    else
      echo "vw$t: FAIL"
    fi
    fail=$((fail+1)); failed="$failed vw$t"
  fi
done
echo "ivl_uvm regression ($mode): $pass passed, $fail failed$failed"
[ $fail = 0 ]
