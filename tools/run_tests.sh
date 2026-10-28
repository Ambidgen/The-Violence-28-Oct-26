#!/usr/bin/env bash
# The Violence: one command that runs the headless suites.
#
# Why this exists: the README documents the harnesses one by one, and each one
# has to be retyped with its own arguments. That is fine for a developer
# checking one thing and useless for a release gate. This wraps them in tiers,
# keeps a log per suite, and exits non-zero if any suite fails.
#
#   tools/run_tests.sh --check          compile only (fastest possible signal)
#   tools/run_tests.sh --range          tactical test-range regressions, no campaign playtests
#   tools/run_tests.sh --quick          the gates a commit should pass (default)
#   tools/run_tests.sh --full           quick + the simulation/campaign suites
#   tools/run_tests.sh --soak           full + the asserted balance matrix
#   tools/run_tests.sh --list           print the plan and exit
#
#   GODOT=/path/to/godot tools/run_tests.sh --quick
#   JOBS=1              run suites one after another (default; the sim is not
#                       thread-safe across processes on a small box)
#   TIMEOUT_SCALE=2     multiply every per-suite timeout
#
# Exit codes: 0 all green, 1 at least one suite failed, 2 the runner was misused
# (no Godot binary, unknown flag), 3 a suite timed out.
#
# Two things to know about the harnesses this calls:
#
#   1. Not all of them set an exit code. Roughly half are diagnostics that print
#      their numbers and quit(0) whatever happened (civ, equip, hold, lethality,
#      maps, nav_door, op, ...). For those this runner also scans the
#      log for FAIL/FAILED/failures>0 and reports the suite as failed, so a
#      regression cannot pass unnoticed. The right long-term fix is to give each
#      harness an exit code; this is the safety net until then.
#   2. determinism_test.gd compares against tests/fixtures/determinism.json. Any
#      deliberate simulation change makes it fail until the fixture is
#      regenerated with --write. That is by design; regenerate it in the same
#      commit as the change and say so in the log.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 2
ROOT="$PWD"
LOGS="${TEST_LOG_DIR:-$ROOT/build/test-logs}"
GODOT="${GODOT:-godot}"
TIER="quick"
TIMEOUT_SCALE="${TIMEOUT_SCALE:-1}"
JOBS="${JOBS:-1}"

usage() {
	sed -n '2,32p' "$0" | sed 's/^# \{0,1\}//'
}

# Reject bad scaling/concurrency instead of silently turning a timeout into 0.
if ! [[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || ! [[ "$TIMEOUT_SCALE" =~ ^[1-9][0-9]*$ ]]; then
	echo "run_tests: JOBS and TIMEOUT_SCALE must be positive integers" >&2
	exit 2
fi

case "${1:---quick}" in
	--check) TIER="check" ;;
	--range) TIER="range" ;;
	--quick) TIER="quick" ;;
	--full) TIER="full" ;;
	--soak) TIER="soak" ;;
	--list) TIER="list" ;;
	-h|--help) usage; exit 0 ;;
	*) echo "run_tests: unknown option '${1}' (try --help)" >&2; exit 2 ;;
esac

if [ "$TIER" != "list" ]; then
	if ! command -v "$GODOT" >/dev/null 2>&1; then
		echo "run_tests: no Godot binary named '$GODOT' on PATH." >&2
		echo "           Set GODOT=/absolute/path/to/godot and run again." >&2
		exit 2
	fi
	mkdir -p "$LOGS"
fi

# name|tier|timeout seconds|how failures are detected|arguments
#   exit = trust the exit code only
#   scan = exit code, and FAIL/FAILED text in the log, and "failures" above 0
#   note = report only for ordinary exits (probes, profiles, galleries); a timeout still fails
PLAN=$(cat <<'EOF'
_check.gd|check|300|scan|
godot472_test.gd|quick|300|exit|
city_integration_test.gd|quick|300|exit|
character_assets_test.gd|quick|300|exit|
test_range_mechanics_test.gd|quick|300|exit|
test_range_regression_test.gd|quick|300|exit|
test_range_replays_test.gd|quick|600|exit|
test_range_determinism_test.gd|quick|900|exit|
improvements_test.gd|quick|600|exit|
ops_ui_test.gd|quick|600|exit|
dept_test.gd|quick|600|exit|
orders_test.gd|quick|600|exit|
save_test.gd|quick|600|exit|
story_test.gd|quick|300|exit|
politics_test.gd|quick|600|exit|
rogue_test.gd|quick|600|exit|
determinism_test.gd|full|1800|exit|-- --verbose
habits_test.gd|full|1200|exit|-- --strict
brains_test.gd|full|1200|exit|-- --n=8
civ_test.gd|full|1800|scan|-- --n=40
equip_test.gd|full|1800|scan|-- --n=12
lethality_test.gd|full|1200|scan|-- --n=20
maps_test.gd|full|600|scan|
nav_door_test.gd|full|900|scan|
op_test.gd|full|1800|scan|-- --weeks=40 --chief=sensible
hold_test.gd|full|1800|note|
stall_test.gd|full|1800|note|
fuzz_test.gd|full|1800|note|-- --n=60
balance_test.gd|soak|1800|exit|-- --gate --n=20
balance_matrix_test.gd|soak|5400|exit|-- --n=30
scale_playtest.gd|soak|5400|exit|-- --gate --n=30
sim_test.gd|soak|1800|note|
perf.gd|soak|900|note|-- --map=10 --na=20 --nb=20 --t=60
duel_probe.gd|soak|900|note|
trace.gd|soak|900|note|
playtest.gd|soak|1800|note|
EOF
)

want() {
	case "$TIER" in
		check) [ "$1" = "check" ] ;;
		quick) [ "$1" = "check" ] || [ "$1" = "quick" ] ;;
		full) [ "$1" = "check" ] || [ "$1" = "quick" ] || [ "$1" = "full" ] ;;
		soak|list) true ;;
	esac
}

# ---- which suites actually exist (the tree is the source of truth) ----------
selected=()
while IFS='|' read -r name tier budget detect args; do
	[ -z "$name" ] && continue
	[ -f "tests/$name" ] || { echo "run_tests: tests/$name is in the plan but not in the tree" >&2; exit 2; }
	if [ "$TIER" = "range" ]; then
		# Deliberately exclude campaign scenarios and campaign determinism cases.
		case "$name" in
			_check.gd|test_range_mechanics_test.gd|test_range_regression_test.gd|test_range_replays_test.gd|test_range_determinism_test.gd|habits_test.gd|maps_test.gd|nav_door_test.gd)
				selected+=("$name|$tier|$budget|$detect|$args") ;;
		esac
	elif want "$tier"; then
		selected+=("$name|$tier|$budget|$detect|$args")
	fi
done <<< "$PLAN"

if [ "${#selected[@]}" -eq 0 ]; then
	echo "run_tests: nothing selected for tier '$TIER'" >&2
	exit 2
fi

if [ "$TIER" = "list" ]; then
	printf '%-28s %-6s %-7s %-5s\n' SUITE TIER TIMEOUT DETECT
	for row in "${selected[@]}"; do
		IFS='|' read -r name tier budget detect args <<< "$row"
		printf '%-28s %-6s %-7s %-5s\n' "$name" "$tier" "${budget}s" "$detect"
	done
	exit 0
fi

echo "the violence: tier '$TIER', ${#selected[@]} suites, engine: $("$GODOT" --version 2>/dev/null | head -1)"
echo "logs: $LOGS"
echo

if [ -t 1 ]; then
	C_PASS=$'\033[32m'; C_FAIL=$'\033[31m'; C_NOTE=$'\033[36m'; C_OFF=$'\033[0m'
else
	C_PASS=""; C_FAIL=""; C_NOTE=""; C_OFF=""
fi

pass=0; fail=0; timeout_n=0; noted=0
failed_names=()

run_one() {
	local row="$1"
	local name tier budget detect args
	IFS='|' read -r name tier budget detect args <<< "$row"
	local log="$LOGS/${name%.gd}.log"
	local status_file="$LOGS/${name%.gd}.status"
	local seconds=$(( budget * TIMEOUT_SCALE ))
	# shellcheck disable=SC2086
	local -a extra=()
	if [ -n "${args// /}" ]; then extra=(${args}); fi

	local start end rc
	start=$(date +%s)
	timeout --signal=TERM --kill-after=30 "$seconds" \
		"$GODOT" --headless --path . -s "res://tests/$name" "${extra[@]}" >"$log" 2>&1
	rc=$?
	end=$(date +%s)
	local took=$(( end - start ))

	local status="PASS"
	case "$detect" in
		exit)
			[ "$rc" -ne 0 ] && status="FAIL"
			;;
		scan)
			if [ "$rc" -ne 0 ]; then status="FAIL";
			elif grep -qE '\bFAILED\b|\bFAIL\b|failures?: *[1-9]|problems?: *[1-9]' "$log"; then status="FAIL";
			fi
			;;
		note)
			status="NOTE"
			;;
	esac
	if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then status="TIMEOUT"; fi
	# A harness may quit(0) after a script or engine/resource error.
	if [ "$detect" != "note" ] && [ "$status" = "PASS" ] && grep -qE 'SCRIPT ERROR|Parse Error|^ERROR:' "$log"; then status="FAIL"; fi
	printf '%s\n' "$status" > "$status_file"

	case "$status" in
		PASS) pass=$((pass+1)); printf '  %sPASS%s    %-28s %4ss\n' "$C_PASS" "$C_OFF" "${name%.gd}" "$took" ;;
		NOTE) noted=$((noted+1)); printf '  %sNOTE%s    %-28s %4ss\n' "$C_NOTE" "$C_OFF" "${name%.gd}" "$took" ;;
		FAIL) fail=$((fail+1)); failed_names+=("$name"); printf '  %sFAIL%s    %-28s %4ss  %s\n' "$C_FAIL" "$C_OFF" "${name%.gd}" "$took" "$log" ;;
		TIMEOUT) timeout_n=$((timeout_n+1)); failed_names+=("$name (timeout)"); printf '  %sTIMEOUT%s %-28s %4ss  %s\n' "$C_FAIL" "$C_OFF" "${name%.gd}" "$took" "$log" ;;
	esac
	# keep the interesting part of a failure in front of the reader
	if [ "$status" = "FAIL" ]; then
		grep -nE '\bFAILED\b|\bFAIL\b|failures?: *[1-9]|problems?: *[1-9]|SCRIPT ERROR|Parse Error|^ERROR:' "$log" | head -5 | sed 's/^/          /'
	fi
}

export -f run_one 2>/dev/null || true
export GODOT LOGS TIMEOUT_SCALE C_PASS C_FAIL C_NOTE C_OFF

if [ "$JOBS" -gt 1 ]; then
	# Clear only selected status files: stale logs from an earlier tier must not
	# turn a crashed child into a pass. Each child records its own final status.
	for row in "${selected[@]}"; do
		IFS='|' read -r name tier budget detect args <<< "$row"
		rm -f "$LOGS/${name%.gd}.status"
	done
	printf '%s\n' "${selected[@]}" | xargs -P "$JOBS" -I{} bash -c 'run_one "$@"' _ {}
	pass=0; fail=0; timeout_n=0; noted=0; failed_names=()
	for row in "${selected[@]}"; do
		IFS='|' read -r name tier budget detect args <<< "$row"
		status_file="$LOGS/${name%.gd}.status"
		status=$(cat "$status_file" 2>/dev/null || printf 'FAIL')
		case "$status" in
			PASS) pass=$((pass+1)) ;;
			NOTE) noted=$((noted+1)) ;;
			TIMEOUT) timeout_n=$((timeout_n+1)); failed_names+=("$name (timeout)") ;;
			*) fail=$((fail+1)); failed_names+=("$name") ;;
		esac
	done
else
	for row in "${selected[@]}"; do
		run_one "$row"
	done
fi

echo
echo "----------------------------------------------------------------"
printf 'suites: %d   pass: %d   fail: %d   timeout: %d   note: %d\n' \
	"${#selected[@]}" "$pass" "$fail" "$timeout_n" "$noted"
if [ "$fail" -ne 0 ] || [ "$timeout_n" -ne 0 ]; then
	echo "failed: ${failed_names[*]}"
	echo "logs are in $LOGS"
	if [ "$timeout_n" -ne 0 ]; then exit 3; fi
	exit 1
fi
echo "all selected suites passed"
exit 0
