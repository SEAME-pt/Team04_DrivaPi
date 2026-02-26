#!/usr/bin/env bash
# summarize_test_results.sh
# Usage: summarize_test_results.sh <test_output_log> <lltc_summary_file>

set -e

TEST_LOG="$1"
LLTC_SUMMARY_FILE="$2"

if [[ ! -f "$TEST_LOG" ]]; then
  echo "::error::Test log not found: $TEST_LOG"
  echo "🧪 Unit tests were NOT summarized because the log file is missing."
  echo "Check the workflow steps that generate '$TEST_LOG' (tests likely failed or did not run)."
  exit 1
fi

log_content=$(cat "$TEST_LOG")

dcMotorCount=$(echo "$log_content" | grep -oE '\[TEST_COUNT\] DC Motor:[[:space:]]*[0-9]+' | grep -oE '[0-9]+')
servoMotorCount=$(echo "$log_content" | grep -oE '\[TEST_COUNT\] Servo Motor:[[:space:]]*[0-9]+' | grep -oE '[0-9]+')
speedSensorCount=$(echo "$log_content" | grep -oE '\[TEST_COUNT\] Speed Sensor:[[:space:]]*[0-9]+' | grep -oE '[0-9]+')

dcMotorCount=${dcMotorCount:-0}
servoMotorCount=${servoMotorCount:-0}
speedSensorCount=${speedSensorCount:-0}

testPassed=$((dcMotorCount + servoMotorCount + speedSensorCount))

dcMotorFailed=$(echo "$log_content" | grep -q '\[INFO\] DC Motor:[[:space:]]*FAILED' && echo 1 || echo 0)
servoMotorFailed=$(echo "$log_content" | grep -q '\[INFO\] Servo Motor:[[:space:]]*FAILED' && echo 1 || echo 0)
speedSensorFailed=$(echo "$log_content" | grep -q '\[INFO\] Speed Sensor:[[:space:]]*FAILED' && echo 1 || echo 0)
testFailed=$((dcMotorFailed || servoMotorFailed || speedSensorFailed))

dcMotorStatus=$(echo "$log_content" | grep -oE '\[INFO\] DC Motor:[[:space:]]*(PASSED|FAILED)' | awk '{print $4}' | tail -n1)
servoMotorStatus=$(echo "$log_content" | grep -oE '\[INFO\] Servo Motor:[[:space:]]*(PASSED|FAILED)' | awk '{print $4}' | tail -n1)
speedSensorStatus=$(echo "$log_content" | grep -oE '\[INFO\] Speed Sensor:[[:space:]]*(PASSED|FAILED)' | awk '{print $4}' | tail -n1)

dcMotorStatus=${dcMotorStatus:-$( [[ $testFailed -eq 0 ]] && echo PASSED || echo FAILED )}
servoMotorStatus=${servoMotorStatus:-$( [[ $testFailed -eq 0 ]] && echo PASSED || echo FAILED )}
speedSensorStatus=${speedSensorStatus:-$( [[ $testFailed -eq 0 ]] && echo PASSED || echo FAILED )}

coverageMatch=$(echo "$log_content" | grep -Poz 'lines.*?(\d+\.\d+)%.*?functions.*?(\d+\.\d+)%.*?branches.*?(\d+\.\d+)%' | head -n1)
if [[ -n "$coverageMatch" ]]; then
  lines=$(echo "$coverageMatch" | grep -oP 'lines.*?\K(\d+\.\d+)(?=%)')
  functions=$(echo "$coverageMatch" | grep -oP 'functions.*?\K(\d+\.\d+)(?=%)')
  branches=$(echo "$coverageMatch" | grep -oP 'branches.*?\K(\d+\.\d+)(?=%)')
  coverageInfo="\n#### 📊 Coverage\n- **Lines**: $lines%\n- **Functions**: $functions%\n- **Branches**: $branches%\n"
else
  coverageInfo='\n#### 📊 Coverage\nCoverage report available in artifacts.\n'
fi

lltcSummary=""
if [[ -f "$LLTC_SUMMARY_FILE" ]]; then
  lltcSummary="\n#### 🔍 Coverage Change Validation\n$(cat "$LLTC_SUMMARY_FILE")\n"
fi

overallStatus="$( [[ $testPassed -gt 0 && $testFailed -eq 0 ]] && echo '✅ PASSED' || echo '❌ FAILED' )"

cat <<EOF
### 🧪 Unit Test Results

**Overall Status**: $overallStatus

- **DC Motor Tests**: $dcMotorStatus ($dcMotorCount tests)
- **Servo Motor Tests**: $servoMotorStatus ($servoMotorCount tests)
- **Speed Sensor Tests**: $speedSensorStatus ($speedSensorCount tests)
- **Total**: $testPassed tests
$coverageInfo
$lltcSummary
---
Full coverage reports available in workflow artifacts
EOF
