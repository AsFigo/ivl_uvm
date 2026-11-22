#!/bin/sh
# Copyright (c) 2026 AsFigo (https://www.asfigo.com)
#
# Usage: ivl_uvm_check_selftest.sh
# Tests the regression runner ivl_uvm_check.sh itself, with a throwaway
# directory and a fake Makefile (no simulator needed). Each case states what
# the runner must report; the script exits non-zero if any case is wrong.

here=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/ivl_uvm_selftest.XXXXXX") || exit 1
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/run_dir" "$work/goldLogs"
cp "$here/ivl_uvm_check.sh" "$work/run_dir/"
cd "$work/run_dir" || exit 1

# vw1: good, logs match the gold.   vw2: logs match but make fails.
# vw3: make succeeds, no logs, gold exists.   vw4: make succeeds, no logs, no
# gold.   vw5: run log matches, gold also lists a compile log that is not made.
# vw6: good with a second run log (name suffix).   vw7: logs differ from gold.
cat > Makefile <<'M'
vw1:
	echo one > ivl_uvm_comp_1.log; echo one > ivl_uvm_run_1.log
vw2:
	echo two > ivl_uvm_comp_2.log; echo two > ivl_uvm_run_2.log; exit 1
vw3:
	@true
vw4:
	@true
vw5:
	echo five > ivl_uvm_run_5.log
vw6:
	echo six > ivl_uvm_comp_6.log; echo six > ivl_uvm_run_6.log; echo hi > ivl_uvm_run_6_HIGH.log
vw7:
	echo changed > ivl_uvm_comp_7.log; echo changed > ivl_uvm_run_7.log
vw8:
	echo "timed out here" > ivl_uvm_run_8.log
vw9:
	echo "finished fine" > ivl_uvm_run_9.log
M
for f in ivl_uvm_comp_1 ivl_uvm_run_1; do echo one > "../goldLogs/$f.log.gold"; done
for f in ivl_uvm_comp_2 ivl_uvm_run_2; do echo two > "../goldLogs/$f.log.gold"; done
for f in ivl_uvm_comp_3 ivl_uvm_run_3; do echo three > "../goldLogs/$f.log.gold"; done
for f in ivl_uvm_comp_5 ivl_uvm_run_5; do echo five > "../goldLogs/$f.log.gold"; done
for f in ivl_uvm_comp_6 ivl_uvm_run_6 ivl_uvm_run_6_HIGH; do
  case $f in *HIGH) echo hi > "../goldLogs/$f.log.gold" ;; *) echo six > "../goldLogs/$f.log.gold" ;; esac
done
for f in ivl_uvm_comp_7 ivl_uvm_run_7; do echo original > "../goldLogs/$f.log.gold"; done

# vw8 and vw9 are listed as expected failures: vw8 shows the listed text, vw9
# does not (the test now completes, so the listing is out of date).
echo "finished fine" > ../goldLogs/ivl_uvm_run_9.log.gold
echo "timed out here" > ../goldLogs/ivl_uvm_run_8.log.gold
printf '%s\n' \
  "8|timed out here|test ends by the global timeout" \
  "9|timed out here|test ends by the global timeout" > ../expected_fail.list

n_fail=0
expect() {  # expect <pass|fail> <description> <test numbers>
  want=$1; what=$2; shift 2
  out=$(./ivl_uvm_check.sh check "$@" 2>&1); rc=$?
  if [ "$want" = pass ] && [ $rc -eq 0 ]; then
    echo "ok    $what"
  elif [ "$want" = fail ] && [ $rc -ne 0 ]; then
    echo "ok    $what"
  else
    echo "FAIL  $what (wanted $want, runner exit $rc)"
    echo "$out" | sed 's/^/        /'
    n_fail=$((n_fail + 1))
  fi
}

expect pass "good target passes"                          1
expect pass "good target with a suffixed run log passes"  6
expect fail "unknown target fails"                        99
expect fail "make failure fails"                          2
expect fail "missing logs with a gold fail"               3
expect fail "no logs and no gold fails"                   4
expect fail "gold file with no produced log fails"        5
expect fail "log differing from gold fails"               7
expect fail "one bad target among good ones fails"        1 99

expect pass "listed expected failure with its text passes"   8
expect fail "listed expected failure without its text fails" 9
out=$(./ivl_uvm_check.sh check 8 2>&1)
case "$out" in
  *"expected failure: test ends by the global timeout"*)
    echo "ok    the report names the expected failure and its reason" ;;
  *)
    echo "FAIL  the report does not name the expected failure"
    n_fail=$((n_fail + 1)) ;;
esac

./ivl_uvm_check.sh gold 99 > /dev/null 2>&1; rc=$?
if [ $rc -ne 0 ] && [ ! -f ../goldLogs/ivl_uvm_run_99.log.gold ]; then
  echo "ok    gold mode refuses an unknown target and writes nothing"
else
  echo "FAIL  gold mode accepted an unknown target (exit $rc)"
  n_fail=$((n_fail + 1))
fi

if [ $n_fail -eq 0 ]; then
  echo "ivl_uvm_check_selftest: PASS"
else
  echo "ivl_uvm_check_selftest: FAIL ($n_fail cases)"
  exit 1
fi
