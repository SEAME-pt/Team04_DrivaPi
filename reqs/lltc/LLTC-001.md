---
id: LLTC-001
type: premise # Define este Statement como uma premissa de baixo nível
normative: true
publish:
  group: "LLTC"
  order: 4
ASIL: B
verification_method: "Unit Test"
reviewers:
  - name: "Dave QA"
    email: "dave@example.com"
reviewed: "2025-10-21 — Reviewed and approved by Dave QA <dave@example.com>"
active: true
derived: false
level: 4.0
test_type: "Unit Test"
parents: # O Test Case suporta o Requisito de Software
  - SWD-001
---
Test case to verify SWD-001 conversion from raw CAN data to km/h.

**Test Procedure:**
- Setup:
  - Initialize conversion module
- Test Steps:
  1. Provide raw value 200 → Expected: Converts to 20 km/h
  2. Provide raw value 0 → Expected: Converts to 0 km/h
- Postconditions:
  - No errors thrown
