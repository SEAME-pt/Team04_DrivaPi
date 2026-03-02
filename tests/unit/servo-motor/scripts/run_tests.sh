#!/bin/bash
################################################################################
# Servo Motor Unit Test Automation
#
# Purpose: Execute servo motor unit tests with coverage reporting
# ASIL Level: A/QM (project policy)
# Version: 1.3.1
################################################################################

set -e -u -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common_test_lib.sh"

PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
COVERAGE_DIR="${BUILD_DIR}/artifacts/gcov"
REPORTS_DIR="${PROJECT_ROOT}/test_reports"
VENDOR_DIR="${PROJECT_ROOT}/vendor"
mkdir -p "${REPORTS_DIR}"

main() {
  log_section "ISO 26262 Servo Motor Tests - DrivaPi"
  echo -e "${BOLD}ASIL Level:${NC} A/QM"
  echo -e "${BOLD}Coverage Gate (CI):${NC} >= 90% line coverage per suite"

  check_prerequisites || exit 1
  cleanup_build "${BUILD_DIR}"
  ensure_vendor "${VENDOR_DIR}" || exit 1

  cd "${PROJECT_ROOT}"
  local test_rc=0
  run_ceedling_tests "${REPORTS_DIR}/test_output.log" || test_rc=$?

  generate_lcov_coverage "${BUILD_DIR}" "${COVERAGE_DIR}"

  ABS_ROOT="$(cd "${PROJECT_ROOT}/../../.." && pwd)"
  PERSIST_DIR="${ABS_ROOT}/build/coverage/servo-motor"
  mkdir -p "${PERSIST_DIR}"
  local artifacts_rc=0
  if [[ -f "${COVERAGE_DIR}/coverage_filtered.info" ]]; then
    cp -f "${COVERAGE_DIR}/coverage_filtered.info" "${PERSIST_DIR}/coverage_filtered.info"
  else
    log_warn "Coverage file not found: ${COVERAGE_DIR}/coverage_filtered.info"
    artifacts_rc=1
  fi

  if [[ -f "${COVERAGE_DIR}/coverage.xml" ]]; then
    cp -f "${COVERAGE_DIR}/coverage.xml" "${PERSIST_DIR}/servo-motor.xml"
  else
    log_warn "Coverage XML not found: ${COVERAGE_DIR}/coverage.xml"
    artifacts_rc=1
  fi

  if [[ "${CALLED_FROM_MASTER:-0}" = "1" ]]; then
    ART_DIR="${ABS_ROOT}/artifacts/verification/coverage"
    mkdir -p "${ART_DIR}"
    if [[ -f "${COVERAGE_DIR}/coverage.xml" ]]; then
      cp -f "${COVERAGE_DIR}/coverage.xml" "${ART_DIR}/servo-motor.xml"
    fi
  fi

  if [[ $test_rc -eq 0 && $artifacts_rc -eq 0 ]]; then
    log_section "✓ SERVO MOTOR TESTS PASSED"
    return 0
  fi

  log_section "✗ SERVO MOTOR TESTS FAILED"
  return 1
}

main "$@"
