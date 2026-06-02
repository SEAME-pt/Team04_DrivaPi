# Emergency Vehicle Priority (EVP) System Requirements

## Functional Requirements (FR)
* **REQ-FR-01 (Vehicle Detection):** The Roadside Unit (RSU) shall detect a priority vehicle's approach within a 50-meter radius using radio signal triggers.
  * *Traceability:* System Architecture -> RSU Radio Node -> SDR Hardware Capture.
* **REQ-FR-02 (Preemption Execution):** Upon valid priority detection, the RSU shall immediately force the target lane traffic light to GREEN within 500ms.
  * *Traceability:* Intersection Controller State Machine -> GPIO Output.
* **REQ-FR-03 (V2X Hazard Broadcast):** The RSU shall broadcast an emergency evacuation message (DENM equivalent) via MQTT to all nearby connected vehicles when preemption is active.
  * *Traceability:* MQTT Broker -> `/v2x/intersection1/alerts` topic.
* **REQ-FR-04 (Vehicle Clear Maneuver):** The connected consumer vehicle (PiRacer) shall parse incoming V2X alert payloads and automatically actuate steering/braking to pull onto the shoulder if it blocks the emergency path.
  * *Traceability:* STM32 Control Loop -> Actuator Drivers.

## Security Requirements (SR) - ISO 21434 Aligned
* **REQ-SR-01 (Signal Authentication):** The RSU shall validate the cryptographic signature of any incoming Signal Request Message (SRM) to prevent replay or spoofing attacks.
  * *Traceability:* Cryptographic Library -> Message Verification Block.
