# TSF Assessment Rubric

Purpose: define pass/fail criteria for the training quiz and lab.

Quiz (10 questions)
- Passing threshold: 70% correct (7/10)
- High confidence threshold: 90% (9/10)

Lab (hands-on)
- Tasks evaluated (each pass/fail):
  - Requirement authored with correct `ref`, `header`, `text` (pass=1)
  - Linter runs clean for the authored files (pass=1)
  - Traceability mapping created and present in matrix (pass=1)
  - `reviewed:` field set to a valid git SHA (pass=1)
  - PR created and CI artifacts generated (pass=1)
- Lab passing threshold: 4/5

Overall readiness
- Team member considered ready when they pass BOTH: quiz (>=70%) AND lab (>=4/5).

Action on fail
- If a member fails, provide targeted remediation and a repeat lab.

Record keeping
- Instructor records quiz scores and lab results in `docs/tsf/training-results.md` (manual entry).

