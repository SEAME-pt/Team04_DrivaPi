# Sprint 1 Review - Team04 DrivaPi

**Date:** October 24, 2025
**Project:** DrivaPi - Autonomous Vehicle Platform

---

## Overall Feedback from Leadership and Facilitators

Sprint 1 was **highly praised** by the SEA:ME program leadership and facilitators. The feedback highlighted:

✅ **Exceptional quality of technical documentation** produced
✅ **Excellent teamwork** and organization
✅ **Surprising results** for a first sprint
✅ **Innovative approach** to team retrospective

The team exceeded expectations by delivering a solid foundation of hardware, software, and processes, demonstrating technical and organizational maturity from the project's inception.

---

## Recognized Strengths

### 1. Technical Documentation
- Clear, structured, and good-level documentation
- Comprehensive coverage of hardware, software, and system architecture
- Detailed Bill of Materials (BOM) and complete connection diagrams

### 2. Technical Implementation
- **Transition from Raspberry Pi OS to Automotive Grade Linux (AGL)** successfully donce - mounted in microSD card
- **Rust control system** implemented and functional for PiRacer
- In-depth study of microcontrollers for future integration
- Qt application developed and tested on Raspberry Pi OS

### 3. Agile Processes
- Effective adoption of Scrum and Agile methodologies
- Daily logs consistently maintained
- Good utilization of Git & GitHub for version control

### 4. TSF Framework (Trustable Software Framework)
- Study and understanding of automotive framework
- Preparation for future project integration with practical labs

---

## Specific Technical Feedback

### 🔴 Clarification: Real-Time vs. Low-Latency

**Director's Observation:**
During the presentation, the team stated that Rust enables "real-time control." The director drew attention to the difference between:

- **Real-Time**: Systems with deterministic guarantees and hard/soft deadlines (requires RTOS, PREEMPT_RT patches, WCET analysis)
- **Low-Latency**: Fast systems but without strict temporal guarantees

**Recommendation:**
Use correct terminology: the current system implements **low-latency control** (sub-millisecond), not real-time stricto sensu. To be truly real-time, the following would be necessary:
- PREEMPT_RT patches in the Linux kernel
- Worst-Case Execution Time (WCET) analysis
- Deterministic deadline guarantees

**Action for next sprints:** Adjust technical language in presentations and documentation.

---

### 🟡 Recommendation: Cross-Compilation for Qt

**Context:**
The team compiled the Qt application directly on the Raspberry Pi.

**Facilitators' Feedback:**
Strongly recommended adopting **cross-compilation** to:
- **Drastically reduce build times** (compiling on an x86_64 PC is significantly faster)
- **Preserve Raspberry Pi resources** during development
- **Align with industrial practices** in embedded development
- **Facilitate future CI/CD integration**

**Action for Sprint 2:**
Configure cross-compilation toolchain (aarch64-linux-gnu) in the development environment.
---

### 🔴 Alert: Rust on STM32 Microcontroller

**Critical Observation:**
Facilitators expressed **significant concern** regarding the application of Rust on the STM32 microcontroller:

**Reasons:**
1. **C/C++ is the absolute standard** for microcontroller programming in the automotive industry
2. **High complexity** of implementing Rust in bare-metal or RTOS environments
3. **Limited ecosystem** compared to official ST HAL/LL libraries in C
4. **Doubts about feasibility** in systems with limited resources (memory, processing)
5. **Debugging and tooling support** much more mature in C/C++

**Facilitators' Recommendation:**
Seriously consider using **C or C++** for the microcontroller, reserving Rust for high-level code on the Raspberry Pi.

**Necessary Discussion:**
The team must evaluate:
- Trade-offs between innovation (Rust) vs. pragmatism (C/C++)
- Availability of libraries and HAL in Rust for STM32U585
- Debugging and maintenance complexity
- Alignment with project requirements and deadlines

---

### 📚 Global Recommendation: Mono-repo vs. Multi-repo

**Guidance for all teams:**
Study and understand repository management approaches used in the industry:

**Mono-repo:**
- Advantages: Atomic cross-component commits, simplified refactoring, unified tooling
- Disadvantages: Scales poorly for giant projects, complex granular access
- Examples: Google, Meta

**Multi-repo:**
- Advantages: Clear separation of responsibilities, independent CI/CD per component
- Disadvantages: Complex dependency management, synchronization between repos
- Examples: Most of the automotive industry

**Action:**
Consciously choose the approach that best suits the DrivaPi project, technically justifying the decision.

---

## Team Sprint Review Methodology

The team implemented an **innovative and humanized approach** to the sprint review, focusing on **peer recognition**:

### Implemented Format
Instead of each member talking about themselves, **each member spoke about another colleague**, highlighting:

1. ✅ **Importance of individual contribution** in the sprint
2. ✅ **How that member adds value to the team**
3. ✅ **Suggested areas for improvement** in a constructive manner

### Results
- **All members were highly praised** by colleagues
- Recognition that **each member was essential** for the sprint's success
- Creation of an environment of **positive and constructive feedback**
- Strengthening of **team cohesion and morale**

---

## Sprint 1 Achievements

### Hardware
✅ Complete assembly of PiRacer platform
✅ Integration of all main components (motors, servo, sensors)
✅ LM393 speed sensor operational and read via GPIO
✅ Pi Camera functional via CSI interface
✅ Touchscreen display configured

### Software
✅ Complete build of Automotive Grade Linux (Trout) for Raspberry Pi 5
✅ Rust control application functional (gamepad → PWM → actuators)
✅ I2C communication with PCA9685 chips established
✅ Qt/QML application developed and tested on Raspberry Pi OS

### Processes
✅ Complete adoption of Agile/Scrum methodologies
✅ Daily logs implemented and maintained
✅ Git workflow established
✅ Quality technical documentation produced

---

## Identified Areas for Improvement

### For Sprint 2

1. **Technical Terminology**
   - Clearly distinguish "real-time" from "low-latency" in communications
   - Review documentation for technical accuracy

2. **Build Process**
   - Implement cross-compilation for Qt application
   - Document toolchain and process

3. **Architectural Decisions**
   - Define language for microcontroller (Rust vs. C/C++)
   - Technically justify the choice
   - Evaluate risks and mitigations

4. **Repository Management**
   - Study mono-repo vs. multi-repo
   - Choose approach and document rationale

5. **STM32 Integration**
   - Plan and execute microcontroller integration
   - Establish UART/USB communication with Raspberry Pi
   - Implement first version of CAN Bus communication

6. **Qt on AGL**
   - Test Qt application natively on AGL
   - Resolve potential compatibility issues
   - Integrate with AGL's Wayland compositor

---

## Team Recognition

Sprint 1 demonstrated that **Team04 DrivaPi** possesses:

🎯 **Solid technical competencies** in hardware and software
🎯 **Accelerated learning capability** of complex technologies
🎯 **Excellent team dynamics** and communication
🎯 **Commitment to quality** in all deliverables
🎯 **Methodological innovation** in team processes

---

## Next Steps

### Sprint 2 - Priorities

1. **Implement received technical feedback**
2. **STM32 microcontroller integration**
3. **Establish CAN Bus communication**
4. **Qt running natively on AGL**
5. **Cross-compilation configured and documented**
6. **First iteration of basic autonomous control**

---

## Conclusion

Sprint 1 was an **undeniable success**, establishing solid technical and organizational foundations for the DrivaPi project. The feedback from leadership and facilitators, while globally positive, provided valuable technical guidance that the team will integrate in upcoming iterations.

The differentiated approach in the team sprint review reinforced group cohesion and created a positive and constructive work environment, essential for the technical challenges ahead.

**The team is prepared and motivated for Sprint 2! 🚗💨**

---

**Document prepared on:** October 27, 2025
**Next review:** Sprint 2 Review (November 10, 2025)
