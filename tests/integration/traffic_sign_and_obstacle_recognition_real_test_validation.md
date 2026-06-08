# Real Test Video Validation — Study Note

This note explains the purpose of the real test video validation, what was tested, and how this evidence supports the verification of the traffic sign and obstacle recognition pipeline in DrivaPi.

---

## Real Test Validation

A real test validation is used to verify that the system behaves correctly when executed in a realistic scenario, with the model running on the vehicle or test platform and receiving input from the actual camera/test environment.

Unlike an offline test, where the model is evaluated only on pre-recorded data, this validation focuses on observing the perception pipeline during a real controlled test run.

The goal is to confirm that the model can detect relevant ADAS objects while the robotic vehicle is moving through the test track.

---

## Purpose of This Test

The purpose of this test is to validate the traffic sign and obstacle recognition model during a real execution scenario.

This includes checking whether the model can identify relevant objects such as:

* Stop signs
* Speed limit signs
* Pedestrian crossing signs
* Warning or priority signs
* Obstacles placed on or near the driving path
* Other relevant road elements visible in the test environment

The video is used as evidence that the model was executed in a controlled driving-like environment and that its outputs can be reviewed for ADAS perception validation.

---

## Test Scope

This test focuses on the perception layer of DrivaPi.

The scope includes:

* Camera input from the real test environment
* Model inference running during the test
* Detection of traffic signs and obstacles
* Visual review of the model output
* Stability of detections across consecutive frames
* Relevance of the detections for ADAS decision-making

This test does not validate the complete autonomous driving decision chain unless the detections are also connected to control logic, such as braking, stopping, or speed adaptation.

---

## Why This Is Important

For an ADAS system, it is not enough to prove that a model works on isolated images or offline datasets.

The perception system must also be validated in a realistic execution context, where several factors can affect detection quality:

* Vehicle movement
* Camera vibration
* Perspective changes
* Distance variation
* Partial occlusions
* Object scale changes
* Lighting conditions
* Processing latency

The real test video helps verify whether the model remains useful under these practical conditions.

---

## Functional vs Integration Perspective

This test can be seen from two perspectives.

### Functional Test Perspective

From a functional point of view, the test verifies whether the traffic sign and obstacle recognition feature behaves according to its expected purpose.

Examples:

* When a Stop sign is visible, the model should detect it.
* When an obstacle appears in the driving path, the model should identify it.
* When a speed sign is visible, the model should classify it correctly.
* When objects remain visible across frames, detections should remain stable.

### Integration Test Perspective

From an integration point of view, the test verifies whether multiple parts of the perception pipeline work together during a real execution.

Examples:

* The camera provides usable input to the system.
* The inference pipeline processes the video stream.
* The model produces detections while the vehicle is moving.
* The output can be recorded and reviewed.
* The perception output can support future ADAS decision logic.

Therefore, this validation is stronger than a simple offline model test because it demonstrates the model running in the real system context.

---

## Expected Results

The test is considered successful if:

* The model runs during the full test execution without crashing.
* The video output shows detections for relevant traffic signs and obstacles.
* Bounding boxes are visually aligned with the detected objects.
* Class labels are consistent with the visible objects.
* Safety-critical objects are detected when they appear clearly in the camera view.
* Detection results remain stable across consecutive frames.
* The recorded video can be used as evidence for perception validation.

---

## Evidence Collected

The main evidence artifact is the recorded test video:

```text
traffic_sign_and_obstacle_recognition.mp4
```

This video documents the real test execution with the model running on the test scenario.

The video should be stored as validation evidence and referenced in the related GitHub issue or pull request.

Recommended evidence information:

```text
Evidence artifact: traffic_sign_and_obstacle_recognition.mp4
Test type: Real test validation
System: DrivaPi perception pipeline
Main feature: Traffic sign and obstacle recognition
Environment: Controlled indoor test track
Status: Completed
```

---

## Limitations

This test provides visual validation of the model behavior, but it does not replace quantitative evaluation.

The following limitations should be considered:

* The test is based on one recorded scenario.
* Detection accuracy is visually reviewed, not statistically measured.
* False positives and false negatives may require frame-by-frame analysis.
* Real-world outdoor conditions may differ from the controlled test-track environment.
* The video validates perception behavior, but not necessarily the full vehicle response.

For a stronger validation process, this test should be complemented with:

* Dataset-based evaluation
* Confusion matrix analysis
* Precision and recall metrics
* Latency measurements
* Multiple real test scenarios
* Integration with decision/control logic

---

## Minimal Test Case Summary

* **ID/Title:** Real test validation of traffic sign and obstacle recognition
* **Objective:** Validate that the model runs during a real vehicle test and detects ADAS-relevant objects.
* **Preconditions:** Camera feed available, perception pipeline configured, model loaded, vehicle/test platform ready.
* **Steps/Stimuli:** Run the vehicle through the controlled test track while recording the model output.
* **Expected Results:** Traffic signs and obstacles are detected with stable labels and correctly aligned bounding boxes.
* **Evidence:** Recorded video showing the model running during the test.
* **Status:** Completed

---

## Conclusion

The real test video validates that the traffic sign and obstacle recognition model can run in a controlled driving-like scenario and produce perception outputs while the robotic vehicle is moving.

This provides important evidence that the model is not only functional in isolation, but also usable within the DrivaPi perception pipeline during real test execution.
