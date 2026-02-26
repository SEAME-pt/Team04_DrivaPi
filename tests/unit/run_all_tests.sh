#!/bin/bash
################################################################################
# Master Unit Test Automation Script with Aggregated Coverage
#
# Purpose: Execute all unit tests and generate unified coverage report
# ASIL Level: A/QM (project policy)
# Version: 2.3.1 - Fixed coverage file finding
################################################################################

set -e
set -u
set -o pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common_test_lib.sh"
readonly PROJECT_ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

readonly DC_MOTOR_DIR="${SCRIPT_DIR}/dc-motor"
readonly SERVO_MOTOR_DIR="${SCRIPT_DIR}/servo-motor"
readonly SPEED_SENSOR_DIR="${SCRIPT_DIR}/speed-sensor"

if [[ -n "${COVERAGE_DIR:-}" ]]; then
    if [[ "$COVERAGE_DIR" == /* ]]; then
        MASTER_COVERAGE_DIR="$COVERAGE_DIR"
    else
        MASTER_COVERAGE_DIR="${PROJECT_ROOT_DIR}/${COVERAGE_DIR}"
    fi
else
    MASTER_COVERAGE_DIR="${SCRIPT_DIR}/coverage"
fi

readonly ARTIFACTS_DIR="${PROJECT_ROOT_DIR}/artifacts/verification"

mkdir -p "${MASTER_COVERAGE_DIR}"
mkdir -p "${ARTIFACTS_DIR}/tests"
mkdir -p "${ARTIFACTS_DIR}/coverage"

main() {
    echo ""
    log_section "ISO 26262 Master Test Runner - DrivaPi (v2.3.1)"
    echo ""

    local dc_pass=0 servo_pass=0 speed_pass=0
    DC_MOTOR_OUTPUT=$(mktemp)
    SERVO_MOTOR_OUTPUT=$(mktemp)
    SPEED_SENSOR_OUTPUT=$(mktemp)

    (cd "${DC_MOTOR_DIR}" && ./scripts/run_tests.sh > >(tee "$DC_MOTOR_OUTPUT") 2>&1) || dc_pass=$?
    [[ ${dc_pass:-0} -eq 0 ]] && log_pass "DC Motor: PASSED" || log_fail "DC Motor: FAILED"
    echo ""

    (cd "${SERVO_MOTOR_DIR}" && ./scripts/run_tests.sh > >(tee "$SERVO_MOTOR_OUTPUT") 2>&1) || servo_pass=$?
    [[ ${servo_pass:-0} -eq 0 ]] && log_pass "Servo Motor: PASSED" || log_fail "Servo Motor: FAILED"
    echo ""

    (cd "${SPEED_SENSOR_DIR}" && CALLED_FROM_MASTER=1 ./scripts/run_speedtest.sh > >(tee "$SPEED_SENSOR_OUTPUT") 2>&1) || speed_pass=$?
    [[ ${speed_pass:-0} -eq 0 ]] && log_pass "Speed Sensor: PASSED" || log_fail "Speed Sensor: FAILED"
    echo ""

    for f in "$DC_MOTOR_OUTPUT" "$SERVO_MOTOR_OUTPUT" "$SPEED_SENSOR_OUTPUT"; do
      [[ -s "$f" ]] || { log_fail "Test output missing, aborting."; exit 2; }
    done

    generate_junit_xml "$DC_MOTOR_OUTPUT" "${ARTIFACTS_DIR}/tests/dc-motor.xml"
    generate_junit_xml "$SERVO_MOTOR_OUTPUT" "${ARTIFACTS_DIR}/tests/servo-motor.xml"
    generate_junit_xml "$SPEED_SENSOR_OUTPUT" "${ARTIFACTS_DIR}/tests/speed-sensor.xml"

    merge_junit_xml "${ARTIFACTS_DIR}/tests/junit_results.xml" \
        "${ARTIFACTS_DIR}/tests/dc-motor.xml" \
        "${ARTIFACTS_DIR}/tests/servo-motor.xml" \
        "${ARTIFACTS_DIR}/tests/speed-sensor.xml"

    local dc_tests
    local servo_tests
    local speed_tests
    dc_tests=$(count_tests "$DC_MOTOR_OUTPUT")
    servo_tests=$(count_tests "$SERVO_MOTOR_OUTPUT")
    speed_tests=$(count_tests "$SPEED_SENSOR_OUTPUT")

    cat > "${ARTIFACTS_DIR}/tests/summary.json" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tests": {
    "dc_motor": {"status": "$([ $dc_pass -eq 0 ] && echo 'PASSED' || echo 'FAILED')"},
    "servo_motor": {"status": "$([ $servo_pass -eq 0 ] && echo 'PASSED' || echo 'FAILED')"},
    "speed_sensor": {"status": "$([ $speed_pass -eq 0 ] && echo 'PASSED' || echo 'FAILED')"}
  },
  "overall_status": "$([ $dc_pass -eq 0 ] && [ $servo_pass -eq 0 ] && [ $speed_pass -eq 0 ] && echo 'PASSED' || echo 'FAILED')"
}
EOF

    echo ""
    echo "[TEST_COUNT] DC Motor: ${dc_tests} tests"
    echo "[TEST_COUNT] Servo Motor: ${servo_tests} tests"
    echo "[TEST_COUNT] Speed Sensor: ${speed_tests} tests"
    log_info "Summary: DC Motor=$([ $dc_pass -eq 0 ] && echo 'PASSED' || echo 'FAILED'), Servo Motor=$([ $servo_pass -eq 0 ] && echo 'PASSED' || echo 'FAILED'), Speed Sensor=$([ $speed_pass -eq 0 ] && echo 'PASSED' || echo 'FAILED')"

    log_success "Test reports generated: ${ARTIFACTS_DIR}/tests/"

    local dc_cov="${DC_MOTOR_DIR}/build/artifacts/gcov/coverage_filtered.info"
    local servo_cov="${SERVO_MOTOR_DIR}/build/artifacts/gcov/coverage_filtered.info"
    local speed_cov="${SPEED_SENSOR_DIR}/coverage_filtered.info"

    [[ ! -f "$dc_cov" ]] && dc_cov="${PROJECT_ROOT_DIR}/build/coverage/dc-motor/coverage_filtered.info"
    [[ ! -f "$servo_cov" ]] && servo_cov="${PROJECT_ROOT_DIR}/build/coverage/servo-motor/coverage_filtered.info"
    [[ ! -f "$speed_cov" ]] && speed_cov="${PROJECT_ROOT_DIR}/build/coverage/speed-sensor/coverage_filtered.info"

    mkdir -p "${ARTIFACTS_DIR}/coverage"
    for suite in dc-motor servo-motor speed-sensor; do
      cov_file=""
      case "$suite" in
        dc-motor)    cov_file="$dc_cov" ;;
        servo-motor) cov_file="$servo_cov" ;;
        speed-sensor) cov_file="$speed_cov" ;;
      esac
      if [[ -f "$cov_file" ]]; then
        if generate_coverage_xml "$cov_file" "${ARTIFACTS_DIR}/coverage/${suite}.xml"; then
          echo "✓ ${suite}.xml created"
        else
          echo "✗ ${suite}.xml - generation failed"
          exit 2
        fi
      else
        echo "✗ ${suite}.xml - coverage file not found at: $cov_file"
        exit 2
      fi
    done

    echo ""
    log_section "Coverage XML Files Status"
    for suite in dc-motor servo-motor speed-sensor; do
        if [[ -f "${ARTIFACTS_DIR}/coverage/${suite}.xml" ]]; then
            echo "  ✓ ${suite}.xml"
        else
            echo "  ✗ ${suite}.xml - MISSING"
        fi
    done

    if [[ -f "$dc_cov" && -f "$servo_cov" && -f "$speed_cov" ]]; then
        aggregate_coverage "${MASTER_COVERAGE_DIR}" "$dc_cov" "$servo_cov" "$speed_cov"
        cp "${MASTER_COVERAGE_DIR}/coverage_filtered.info" "${ARTIFACTS_DIR}/coverage/coverage.info"
        [[ -f "${MASTER_COVERAGE_DIR}/coverage.xml" ]] && cp "${MASTER_COVERAGE_DIR}/coverage.xml" "${ARTIFACTS_DIR}/coverage/coverage.xml"
        log_success "Coverage reports saved: ${ARTIFACTS_DIR}/coverage/"
    else
        log_warn "Some coverage files not available for aggregation"
        log_info "DC Motor: $( [[ -f "$dc_cov" ]] && echo "FOUND" || echo "MISSING" )"
        log_info "Servo Motor: $( [[ -f "$servo_cov" ]] && echo "FOUND" || echo "MISSING" )"
        log_info "Speed Sensor: $( [[ -f "$speed_cov" ]] && echo "FOUND" || echo "MISSING" )"
    fi

    echo ""
    if [[ $dc_pass -eq 0 && $servo_pass -eq 0 && $speed_pass -eq 0 ]]; then
        log_section "✓ ALL TESTS PASSED - CI QUALITY GATES APPLY"
        log_info "Reports: ${ARTIFACTS_DIR}/"
        exit 0
    else
        log_section "✗ SOME TESTS FAILED"
        log_info "Reports: ${ARTIFACTS_DIR}/"
        exit 1
    fi
}

main "$@"
