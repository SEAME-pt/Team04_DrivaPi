---
id: LLTC-template
header: "Short requirement title here"
text: |
  "Detailed requirement statement here"

# TSF Type: Evidence/Premise (A Claim, but not a Request)

verification_method: "Verification method here"

# Links: Connects to the SWD it provides evidence for
parents:
  - id: SWD-<PARENT_REF>

reviewers:
  - name: "<REVIEWER_NAME>"
    email: "<REVIEWER_EMAIL>"
reviewed: ''  # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# Evidence Linking (use 'references:', NOT deprecated 'artifact:')
references:
  - type: "file"
    path: <relative/path/to/artifact>  # Path from repo root
  # Common examples:
  # - type: "file"
  #   path: tests/unit/test_temperature.cpp  # Test implementation
  # - type: "file"
  #   path: artifacts/verification/tests/LLTC-042-junit.xml  # Test results

# Optional: Automated Validation (RECOMMENDED for LLTC - objective scoring)
evidence:
  type: <validator_name>  # e.g., junit_pass_fail_checker, coverage_threshold_checker
  references:
    - type: "file"
      path: <path/to/test/results>  # Test result artifact (.xml, .json, etc.)
  configuration:
    expected_tests: <NUMBER>
    # fail_on_severity: ["error"]
    # min_coverage: 0.80

# Manual SME Score
score:
  <SME_ID>: <0.0-1.0>  # SME confidence score
  # Example:
  # TestLead: 1.0

active: true
derived: false
normative: true
level: 4.0  # 1.0=URD, 2.0=SRD, 3.0=SWD, 4.0=LLTC
---
<STATEMENT>
