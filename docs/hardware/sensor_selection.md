# Sensor Selection Analysis

**Date:** 2025-11-03  
**Project:** DrivaPi  
**Subsystem:** Motor Speed Sensing  
**Document ID:** sensor_selection.md  

---

## Executive Summary

This document evaluates motor speed sensor options for the DrivaPi motor testing platform and justifies the selection of a standard Hall-effect tachometer.

---

## 1. Sensor Selection Criteria

### Primary Requirements

| Criterion | Weight | Requirement |
|-----------|--------|-------------|
| Speed Range | Critical | 0-10000 RPM minimum |
| Accuracy | Critical | ±1% of reading |
| Output Type | Critical | TTL/CMOS logic compatible |
| Interface | High | GPIO/digital input only |
| Cost | High | <$50 per unit |
| Reliability | Critical | ASIL A compliant |
| Availability | High | Standard parts, short lead time |

### Secondary Criteria

- Minimal power consumption
- No calibration required
- Wide temperature range
- Environmental robustness (IP67+)
- Mounting flexibility

---

## 2. Sensor Technology Options

### Option 1: Hall-Effect Tachometer (SELECTED)

**Description:** Magnetic switch that generates pulse on each motor revolution.

**Advantages:**
- ✓ Simple digital output (1 pulse per rev)
- ✓ No external power for electronics (powered by DrivaPi)
- ✓ Robust to temperature and humidity
- ✓ Low cost ($20-40)
- ✓ Widely available
- ✓ No calibration needed
- ✓ Proven reliability in automotive

**Disadvantages:**
- ✗ Requires magnet on motor shaft
- ✗ Manual installation/adjustment
- ✗ Limited to integer revolution counting

**Application:** Motor speed (RPM), revolution counting  
**Output Type:** Digital pulse train (0-3.3V TTL)  
**Typical Range:** 0-10000+ RPM  
**Accuracy:** ±0.5% (with proper installation)  

**Recommended Model:** 
- Industry: Standard automotive tachometer sensor
- Supplier: Various (Phoenix Contact, Siemens, etc.)
- Cost: $25-35

---

### Option 2: Optical Encoder

**Description:** Reflective sensor that detects marks on motor shaft.

**Advantages:**
- ✓ High resolution possible (multiple marks per rev)
- ✓ Non-contact measurement
- ✓ Very accurate (±0.1%)

**Disadvantages:**
- ✗ Expensive ($200+)
- ✗ Requires reflective marks on shaft
- ✗ Sensitive to dirt/contamination
- ✗ More complex setup
- ✗ Power consumption higher
- ✗ Overkill for ASIL A

**Not Selected:** Too expensive, unnecessary complexity for requirement

---

### Option 3: Inductive Proximity Sensor

**Description:** Detects metallic target passing sensor.

**Advantages:**
- ✓ Non-contact measurement
- ✓ Robust to vibration
- ✓ No calibration

**Disadvantages:**
- ✗ Requires metal target on shaft
- ✗ Limited to specific distances
- ✗ Higher power consumption
- ✗ More expensive ($100+)
- ✗ Complex installation

**Not Selected:** Unnecessary complexity, higher cost

---

### Option 4: Capacitive Sensor

**Description:** Detects capacitance changes as target passes.

**Advantages:**
- ✓ Non-contact
- ✓ Works with non-metallic targets

**Disadvantages:**
- ✗ Sensitive to environmental conditions
- ✗ High cost ($150+)
- ✗ Complex setup and calibration
- ✗ Unreliable in testing environment

**Not Selected:** Unreliable, overcomplicated

---

## 3. Comparison Matrix

| Feature | Hall-Effect | Optical | Inductive | Capacitive |
|---------|-------------|---------|-----------|------------|
| **Cost** | $$ | $$$$ | $$$ | $$$$ |
| **Accuracy** | ±1% | ±0.1% | ±0.5% | ±2% |
| **Installation** | Easy | Medium | Medium | Hard |
| **Maintenance** | None | Periodic cleaning | Rare | Frequent |
| **Temperature Range** | -40 to +85°C | -10 to +70°C | -20 to +100°C | -10 to +60°C |
| **Environmental Robustness** | IP67 | IP54 | IP67 | IP54 |
| **Power Consumption** | Low | Medium | High | Medium |
| **Calibration** | None | Optional | None | Required |
| **Complexity** | Simple | Complex | Medium | Complex |
| **Reliability (ASIL A)** | Proven | Overkill | Good | Questionable |

---

## 4. Cost Analysis

### Hall-Effect Option (Selected)

| Item | Cost | Notes |
|------|------|-------|
| Sensor | $30 | Standard automotive tachometer |
| Connector | $5 | 3-pin header housing |
| Wiring | $5 | Shielded twisted pair, 5m |
| Installation labor | $20 | One-time technician time |
| **Total** | **$60** | Per test stand |

### Optical Encoder Option (Alternative)

| Item | Cost | Notes |
|------|------|-------|
| Sensor | $200 | High-precision optical |
| Encoder wheel | $50 | Reflective marks |
| Cable/connector | $20 | Proprietary interface |
| Installation | $50 | Complex setup |
| **Total** | **$320** | 5× more expensive |

---

## 5. Risk Analysis

### Hall-Effect Sensor Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Magnet detaches | Low | High | Use strong epoxy adhesive + retaining ring |
| Poor sensor mounting | Medium | Medium | Template + installation guide |
| EMI interference | Low | Medium | Shielded cable + filtering |
| Mechanical wear | Low | Low | Expected lifetime >5 years |

### Optical Sensor Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Contamination/dirt | High | High | Regular cleaning required |
| Connector issues | Medium | High | Proprietary difficult to replace |
| Performance drift | Medium | Medium | Frequent calibration required |
| Cost overrun | Low | High | Budget impact |

---

## 6. Application Scenarios

### Scenario 1: Standard Motor Speed Monitoring

**Requirement:** Monitor motor speed 0-5000 RPM during typical tests  
**Solution:** Hall-Effect sensor (sufficient)  
**Performance:** ±1% accuracy = ±50 RPM at 5000 RPM ✓

### Scenario 2: High-Speed Performance Testing

**Requirement:** Monitor speed at 8000-10000 RPM during extreme tests  
**Solution:** Hall-Effect sensor (adequate)  
**Performance:** ±1% accuracy = ±100 RPM at 10000 RPM ✓

### Scenario 3: Advanced Analysis (Future)

**Requirement:** Require <0.1% accuracy for detailed analysis  
**Solution:** Upgrade to optical encoder when needed  
**Note:** Hall-Effect sufficient for current ASIL A requirement

---

## 7. Selection Justification

### Why Hall-Effect Tachometer?

1. **Cost Efficiency:** $60 total vs $320+ for alternatives (80% savings)
2. **Simplicity:** Minimal installation complexity, no calibration
3. **Reliability:** Proven automotive-grade component
4. **ASIL A Compliance:** Exceeds ASIL A requirements
5. **Availability:** Standard parts, short delivery times
6. **Maintainability:** Simple troubleshooting and replacement
7. **Performance:** Adequate accuracy (±1%) for motor monitoring
8. **Future-Proof:** Easy to upgrade if ASIL B required later

### ASIL A Justification

| ASIL Level | Sensor Accuracy Needed | Hall-Effect Capability | Status |
|-----------|------------------------|----------------------|--------|
| **QM** | Low (±5%) | ±1% | Exceeds |
| **A** | Medium (±2%) | ±1% | **Meets** ✓ |
| **B** | Good (±1%) | ±1% | Exceeds |
| **C** | Excellent (±0.5%) | ±1% | Exceeds |
| **D** | Precision (±0.1%) | ±1% | Close (consider upgrade) |

---

## 8. Implementation Plan

### Phase 1: Procurement
- Order Hall-Effect sensor ($30)
- Source connector and wiring ($10)
- Estimated lead time: 1 week

### Phase 2: Installation
- Mount sensor on motor test stand
- Calibrate magnet position
- Test pulse frequency (manual verification)
- Estimated time: 30 minutes

### Phase 3: Integration
- Connect to Raspberry Pi GPIO 17
- Load MotorSpeedSensor driver (SWD-010)
- Verify RPM reading accuracy
- Estimated time: 1 hour

### Phase 4: Validation
- Run full test suite (LLTC-010)
- Verify speed range 0-10000 RPM
- Check accuracy ±1%
- Document results
- Estimated time: 2 hours

---

## 9. Alternative Sensor Profiles (For Reference)

### If Optical Encoder Were Selected

**Setup Would Require:**
- Reflective encoder wheel (add $50)
- Precise mounting bracket (add $40)
- Regular cleaning procedure
- Higher installation time (2+ hours)
- Periodic calibration

**Not justified for ASIL A but could be considered if:**
- ASIL B required in future
- High-precision trend analysis needed
- Cost is not a constraint

---

## 10. Conclusion

**Selected Sensor:** Standard Hall-Effect Tachometer  
**Rationale:** Optimal balance of cost, reliability, simplicity, and performance for ASIL A motor speed monitoring

**Key Decision Factors:**
1. ✓ Meets accuracy requirement (±1%)
2. ✓ Lowest total cost ($60)
3. ✓ Simplest installation
4. ✓ Proven reliability
5. ✓ ASIL A compliant
6. ✓ Industry standard

**Recommendation:** Proceed with Hall-Effect tachometer implementation.

---

**Document Status:** Approved  
**Review Date:** 2025-11-03  
**Approved By:** Design Team  
**Traceability:** SRD-010
