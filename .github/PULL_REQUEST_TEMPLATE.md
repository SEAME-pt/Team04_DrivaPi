# Pull Request - Requirements/Tests/Docs
---

## 📋 Summary

- **Type:** [ ] Requirement / [ ] Test / [ ] Traceability / [ ] Docs / [ ] Other
- **Affected Requirement IDs:** (comma-separated list)
- **Short Description:**

---

## 🔍 ASIL & Safety Impact

- **ASIL Level:** [ ] A / [ ] B / [ ] C / [ ] D / [ ] QM (N/A)
- **Safety Impact Summary:** (one sentence)

---

## ✅ Author Checklist

### YAML Structure
- [ ] File follows format `reqs/<category>/<ID>.yml`
- [ ] `ref:` matches ID and filename
- [ ] All mandatory fields filled:
  - [ ] `ref`, `header`, `text`
  - [ ] `ASIL`, `Verification Method`
  - [ ] `reviewers` (name + email)
  - [ ] `links` (if applicable)
- [ ] `reviewed: ''` is empty (will be filled on approval)

### Content Quality
- [ ] Text uses "shall" for mandatory requirements
- [ ] Requirement is testable and unambiguous
- [ ] Clear acceptance criteria (GIVEN/WHEN/THEN if applicable)
- [ ] Correct traceability links (parent requirement exists)
- [ ] Units/values/timing specified where needed

### Official TSF Validation
- [ ] ✅ `trudag manage lint` executed locally WITHOUT errors
- [ ] ✅ `doorstop` executed successfully
- [ ] ✅ CI/CD passes (GitHub Actions)

### Artifacts (if applicable)
- [ ] Verification artifacts in `artifacts/verification/`
- [ ] Artifact links added to YAML

---

## 👁️ Reviewer Checklist

### Technical Validation
- [ ] Requirement is technically correct and feasible
- [ ] Complete traceability (URD→SRD→SWD→LLTC)
- [ ] ASIL level appropriate for context
- [ ] Verification method appropriate

### Quality
- [ ] Text is clear and unambiguous
- [ ] Testable (acceptance criteria are verifiable)
- [ ] Units/values/timing specified
- [ ] No vague words ("approximately", "quickly", etc.)

### TSF Compliance
- [ ] ✅ `trudag manage lint` passes
- [ ] All TSF mandatory fields complete
- [ ] Links verified

### For ASIL C/D (additional)
- [ ] Independent reviewer (non-author)
- [ ] Verification artifacts attached
- [ ] Complete test evidence

---

## 🔧 How to Test Locally

### 1. Official Validation
```bash
# Validate structure and content
trudag manage lint

# Update Doorstop structure
trudag manage migrate

# Verify links
doorstop
```

### 2. Manual Verification
```bash
# View requirement content
cat reqs/<category>/<ID>.yml

# Verify all mandatory fields exist
```

---

## 📝 Approval Process

### To Approve this PR:

1. **Reviewer validates** content and structure
2. **Reviewer executes:**
   ```bash
   trudag manage lint
   ```
3. **If approved, reviewer executes:**
   ```bash
   # Approve requirement (updates 'reviewed')
   trudag manage set-item reqs/<category>/<ID>.yml

   # Commit approval
   git add reqs/<category>/<ID>.yml
   git commit -m "review: Approve <ID>"
   git push
   ```
4. **Merge PR**

---

## 📖 Context / Notes

<!-- Add context, screenshots, relevant discussions -->

---

## ⚠️ Breaking Changes

- [ ] Yes / [x] No
- If yes, describe impact:

---

## 🔗 Related Issues/PRs

<!-- Links to related issues or PRs -->

Closes #

---

## 📚 References

- Training: `docs/training/TSF-training.md`
- Workflow: `docs/guides/requirements/workflow.md`
- Quick Ref: `docs/training/quick-reference.md`

---

**Reviewers:** Assign 2 reviewers (domain expert + technical expert)
**For ASIL ≥ C:** Independent reviewer required
