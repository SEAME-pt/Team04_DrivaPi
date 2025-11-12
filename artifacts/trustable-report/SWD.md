

---

### SWD-998 ### {: .item-element .item-section class="tsf-score" style="background-color:hsl(65.99999999999999, 100%, 45%)"}
## Software Design Requirement Statement
{: .expanded-item-element }

**Item Status:**

:material-check: Item Reviewed<br>:material-check: Children linked<br>

**Supported Requests:**

- [SRD-998](SRD.md#srd-998){.item-element class="tsf-score" style="background-color:hsl(65.99999999999999, 100%, 45%)"}

**Supporting Items:**

- [LLTC-996](LLTC.md#lltc-996){.item-element class="tsf-score" style="background-color:hsl(1.2, 100%, 64%)"}

- [LLTC-997](LLTC.md#lltc-997){.item-element class="tsf-score" style="background-color:hsl(114.0, 100%, 31%)"}

- [LLTC-998](LLTC.md#lltc-998){.item-element class="tsf-score" style="background-color:hsl(82.8, 100%, 40%)"}

{% raw %}

**References:**

- `reqs/lltc/LLTC-998.md`

	??? "Click to view reference"

		````md
		---
		id: LLTC-998
		header: Low-Level Test Cases for Motor Speed
		text: '"Test cases shall verify RPM calculation, error handling, and range validation."
		  '
		  # TSF Type: A Premise
		
		verification_method: Unit Testing
		parents:
		- id: SWD-998
		reviewers:
		- name: Hugo Lopes
		  email: hugo.lopes@seame.pt
		reviewed: '2025-11-12 - Approved by Hugo Lopes hugo.lopes@seame.pt' 
		references:
		- type: file
		  path: tests/unit/test_motor_speed.cpp
		  description: Test code
		- type: file
		  path: artifacts/verification/tests/LLTC-998-junit.xml
		  description: Test results
		
		active: true
		derived: false
		normative: true
		level: 4.0
		score:
		  Hugo Lopes: 0.69
		---
		Verifies SWD-998 implementation through unit tests for motor speed functionality.
		
		````


- `reqs/lltc/LLTC-997.md`

	??? "Click to view reference"

		````md
		---
		id: LLTC-997
		header: Static Analysis Verification (Cppcheck)
		text:  |
		  "The software SHALL pass static analysis (Cppcheck) with zero ''error'' severity
		  findings."
		
		# TSF Type: A Premise
		
		verification_method: Static Analysis
		parents:
		- id: SWD-998
		reviewers:
		- name: Hugo Lopes
		  email: hugo.lopes@seame.pt
		reviewed: '2025-11-12 - Approved by Hugo Lopes hugo.lopes@seame.pt'
		references:
		- type: file
		  path: artifacts/verification/static-analysis/cppcheck-SWD-998.xml
		  description: Static analysis report (0 errors)
		
		active: true
		derived: false
		normative: true
		level: 4.0
		score:
		  Hugo Lopes: 0.95
		---
		Verifies SWD-998 implementation against static analysis rules.
		
		````


- `reqs/lltc/LLTC-996.md`

	??? "Click to view reference"

		````md
		---
		id: LLTC-996
		header: Code Coverage Verification
		text: |
		  "Unit test coverage for motor speed driver meets project threshold."
		
		# TSF Type: A Premise
		verification_method: Coverage analysis
		parents:
		- id: SWD-998
		reviewers:
		- name: Hugo Lopes
		  email: hugo.lopes@seame.pt
		reviewed: '2025-11-12 - Approved by Hugo Lopes hugo.lopes@seame.pt'
		references:
		- type: file
		  path: artifacts/verification/coverage/coverage-SWD-998.xml
		  description: Coverage report
		active: true
		derived: false
		normative: true
		level: 4.0
		score:
		  Hugo Lopes: 0.01
		---
		Verifies that unit test coverage for the motor speed driver meets the defined project threshold of 80%.
		
		````


- `docs/standards/iso26262/hara-motor-speed.md`

	??? "Click to view reference"

		````md
		
		
		The Hazard Analysis and Risk Assessment (HARA) for the motor speed sensor requirement **SWD-998** identifies potential hazards, classifies their severity, exposure, and controllability, and determines the Automotive Safety Integrity Level (ASIL) for the requirement.
		
		# HARA: Motor Speed Sensor
		
		**Date:** 2025-11-06| **Authors/Reviewers:** Bernardo/Hugo | **ASIL Target:** QM
		
		## 1. Item Definition & Assumptions
		- **Description/Boundaries/Interfaces:** Motor speed monitoring system for DrivaPi lab testing.
		- **Assumptions:** Trained operators only; controlled lab environment.
		
		## 2. Hazards & Operational Situations
		| ID | Hazard Description | Operational Situation | Exposure (E) / Justification |
		|:---|:---|:---|:---|
		| H-01 | Sensor fails silently | Extended motor test | E2 (~2-5% of tests; historical data) |
		| H-02 | Sensor uncalibrated | Extended motor test | E1 (~0.1-0.5% of tests; historical data) |
		
		## 3. Risk Assessment & ASIL
		- **Severity (S):** S1 - Motor overheats, minor burn risk if touched. Overspeed can happen.
		- **Controllability (C):** C1 - Operator observes smoke/noise, presses emergency stop.
		- **ASIL Calculation:** S1 + E2 + C1 = **QM** (from ISO 26262-3:2018 Table 4)
		
		## 4. Safety Goals
		| Goal ID | ASIL | Description | Safe State |
		|:---|:---|:---|:---|
		| SG-01 | QM | Motor speed sensor shall function reliably | Operator can monitor and stop motor |
		
		## 5. Dependencies & Review Notes
		- **Dependencies:** Emergency stop button, GPIO hardware driver
		- **Review:** 2025-11-12 - Approved by Hugo Lopes hugo.lopes@seame.pt
		
		**References:** ISO 26262-3:2018.
		
		````



{% endraw %}

**Fallacies:**

_None_
