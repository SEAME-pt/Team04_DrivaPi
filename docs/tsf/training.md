# TSF Training - Theory

**Goal:** Understand the "why" of TSF and ISO 26262

> **To use TSF immediately:** See [workflow.md](workflow.md)

---

## 🎯 TSF: Core Principle

> **"Trust in software = Evidence, not assumptions"**

TSF (Trustable Software Framework) is for software where **safety, security, performance** are critical.

### How it works?

1. **Statements** - Claims that can be True/False
2. **Links** - Logical connections between statements (child → parent)
3. **DAG** - Directed Acyclic Graph (no cycles)
4. **Evidence** - Artifacts that prove each statement

**Example:**
```
"Software reads temperature at 1Hz" (Statement)
   ↓ proved by
"tests/test_temp.cpp passed" (Evidence)
```

---

## 📐 V-Model and Statement Types

### The V-Model

```
URD (User Requirements)    ← WHAT users need
  ↓
SRD (System Requirements)  ← HOW system provides
  ↓
SWD (Software Design)      ← HOW software implements
  ↓
LLTC (Tests)               ← HOW to verify
```

### Statement Types

| Type | Links | Example |
|------|-------|---------|
| **Expectation** | a request | URD (top) |
| **Assertion** | a request or a claim | SRD, SWD (middle) |
| **Evidence** | a premise supported by artifacts | LLTC (bottom) |

**Golden rule:** Child links TO PARENT (bottom-up)

---

## 🏥 ISO 26262 - ASIL Levels

### What is ASIL?

**ASIL = Automotive Safety Integrity Level**

Classifies failure risk:
```
ASIL = Severity × Exposure × Controllability
```

### The Levels

| ASIL | Risk | Example | Verification |
|------|------|---------|--------------|
| **QM** | None | Radio | Basic review |
| **A** | Low | Rear lights | + Tests |
| **B** | Low-Med | Brake lights | + 2 reviewers |
| **C** | Medium | ABS | + System tests |
| **D** | High | Airbags | + Formal certification |

### Calculate ASIL

**Severity (S):**
- S0 = No injuries
- S1 = Light injuries
- S2 = Severe injuries
- S3 = Life-threatening

**Exposure (E):**
- E1 = < 0.1% driving time
- E2 = 0.1-1%
- E3 = 1-10%
- E4 = > 10%

**Controllability (C):**
- C0 = Easily controllable
- C1 = Controllable by most
- C2 = Controllable by some
- C3 = Difficult to control

**Example: DrivaPi speed display fails**
- S2 (accident possible) × E4 (always used) × C2 (driver may notice) = **ASIL B**

---

## ✍️ Writing Good Requirements

### Base Formula

```
<Subject> SHALL <action> <object> <constraints>
```

### ✅ GOOD Example

```markdown
The software SHALL read temperature sensor via I2C address 0x48
with 12-bit resolution every 100 milliseconds.
```

**Why good?**
- Uses SHALL (it is a mandatory statement)
- Specific interface (I2C 0x48)
- Clear metric (12-bit)
- Defined timing (100ms)
- **Testable!**

### ❌ BAD Example

```markdown
The system should read temperature quickly.
```

**Why bad?**
- "should" is ambiguous (use SHALL, HAS TO, NEEDS, MUST)
- "quickly" is not measurable
- No interface specified
- **Not testable!**

---

## 🔗 Traceability (Why Link?)

### Benefits

1. **Coverage** - Each user need has implementation
2. **Impact** - Change in requirement affects what?
3. **Audit** - Prove compliance for certification
4. **Trust** - Complete evidence chain

### How to Link

```
LLTC-042 (temp sensor test)
   ↓ proves
SWD-042 (TempSensor class)
   ↓ implements
SRD-015 (system reads temp)
   ↓ satisfies
URD-001 (user sees temp)
```

**In trudag:**
```bash
trudag manage create-link SRD-015 SWD-042
trudag manage create-link SWD-042 LLTC-042
```

---

## 📊 6 Evidence Areas (TSF Methodology)

1. **Provenance** - Who made it, when, why?
   - Git logs, authorship, license

2. **Construction** - How to build?
   - Build instructions, makefiles, CI/CD

3. **Testing** - How to verify?
   - Unit tests, integration tests, results

4. **Assurance** - Independent checks?
   - Code review, static analysis, coverage

5. **Compliance** - Follows standards?
   - ISO 26262, AUTOSAR, MISRA

6. **Deployment** - How to install/update?
   - Deploy scripts, configs, updates

**Each requirement should have evidence from multiple areas!**

---

## 🎓 Key Concepts (Summary)

| Concept | Explanation |
|----------|------------|
| **Statement** | Testable claim (True/False) |
| **Link** | Child implies Parent (logic) |
| **DAG** | Acyclic graph (no loops) |
| **ASIL** | Risk level (QM, A, B, C, D) |
| **V-Model** | URD → SRD → SWD → LLTC |
| **Evidence** | Artifacts proving statements |
| **Traceability** | Complete chain of links |
| **Baseline** | Immutable snapshot (git tag) |

---

## 💡 Best Practices

1. **Write requirements before code** - Design first
2. **One requirement = one testable thing** - Split if complex
3. **Link as you create** - Don't leave for later
4. **Review in small batches** - Easier than bulk
5. **Frequent baselines** - Better audit trail
6. **Evidence in git** - Immutable, verifiable

---

## 📚 Learn More

- **TSF Whitepaper:** [trustable.io](https://trustable.io)
- **ISO 26262:** Functional safety standard
- **AUTOSAR:** Automotive software architecture

---

**Ready to practice?**
- Practical workflows → [workflow.md](workflow.md)
- Commands → [reference.md](reference.md)
- Evidence → [evidence.md](evidence.md)
