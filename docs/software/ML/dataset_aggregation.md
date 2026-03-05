# Dataset Aggregation (DAgger) for Autonomous Driving

## Overview

**Dataset Aggregation**, universally known as **DAgger**, sits at the intersection of imitation learning
and reinforcement learning. Rather than training on a fixed, pre-collected expert dataset,
it **interactively queries the expert** during training to obtain corrective labels for states
that the learner itself visits. Over successive iterations, the training dataset grows to cover more
and more of the states the learner encounters, progressively closing the gap between the training distribution\
and the deployment distribution.

---

## Motivation: Why DAgger Exists

In standard Behavioural Cloning (BC), the model is trained on observations collected while the
**expert** was in control. However, at test time, the **learner** is in control and will inevitably make small mistakes
that lead it to states the expert never visited. Because the learner has no training data for these novel states,
errors cascade, a phenomenon called **compounding errors** or **distributional shift**.

---

## How DAgger Works

### Algorithm (Simplified)

```
Initialise dataset D₀ = {}
Train initial policy π₁ using any method (e.g., behavioural cloning)

For iteration i = 1, 2, 3, ..., N:
    1. Run the current policy πᵢ in the environment to collect trajectories
       (the learner is in control of the vehicle)
    2. Query the expert oracle to label each visited state with the
       correct action → creates dataset Dᵢ
    3. Aggregate: D = D ∪ Dᵢ
    4. Train a new policy πᵢ₊₁ on the full aggregated dataset D
```

### Visual Flow

```
  Iteration 1          Iteration 2          Iteration 3
  ┌──────────┐         ┌──────────┐         ┌──────────┐
  │ Expert   │         │ Learner  │         │ Learner  │
  │ drives   │ ──────▶ │ drives   │ ──────▶ │ drives   │
  │          │         │ (policy  │         │ (improved│
  │ D₁       │         │  π₁)     │         │  policy  │
  └──────────┘         │ Expert   │         │  π₂)     │
                       │ labels   │         │ Expert   │
                       │ D₁ ∪ D₂  │         │ labels   │
                       └──────────┘         │ D∪D₃     │
                                            └──────────┘
                    Dataset grows, covering learner's state distribution
```

### Expert Querying in Practice

A key practical challenge is: *how do you query a human expert for every state the learner visits?*

Several strategies have been used in autonomous driving:

| Strategy | Description |
|---|---|
| **Human override** | A human safety driver monitors and can take control, then labels the observed states post-hoc |
| **Safety driver labelling** | The human labels what they would have done at each timestep in the learner's trajectory |
| **Privileged planner** | A classical planner (e.g., A\*, Rapidly-exploring Random Tree (RRT)) acts as the "expert oracle" and provides labels automatically |
| **Mixed autonomy** | The agent drives but a shadow human provides parallel labels without actually controlling the vehicle |

---

## Application in Autonomous Driving

DAgger has been influential in autonomous driving research, particularly for:

### End-to-End Driving Policies
Systems where a neural network maps raw sensor data directly to control outputs.
DAgger ensures the network sees and learns from the states it actually visits during deployment,
not just ideal expert trajectories.

### Imitation Learning with a Privileged Teacher
In simulation, a privileged planner (one that has access to full ground-truth state information,
e.g., positions of all vehicles) can act as the expert oracle.
The learner, which only has access to sensor data (camera, LiDAR), is iteratively trained
to match the privileged planner's actions from the learner's own experienced states.

> *This setup is used in CARLA-based Imitation Learning (IL) research and systems like Conditional Imitation Learning with ResNet and Speed prediction (CILRS) and Transfuser.*

### Corrective Labelling Pipelines
Real-world automotive companies use DAgger-inspired pipelines where logs
from autonomous fleet vehicles are reviewed by human annotators who label what the correct action
should have been at critical moments.

### Safety Monitoring
DAgger naturally identifies **uncertainty regions**, states where the current policy deviates significantly
from expert behaviour, which can trigger safety interventions.

---

## Using CARLA Simulator for DAgger

CARLA is well-suited for DAgger because its built-in **Autopilot / Traffic Manager**
can act as an **automated expert oracle**, no human annotator needed.
The learner drives in CARLA while the autopilot is simultaneously queried at each timestep for what it would have done in that state. Those expert labels are added to the dataset,
the policy is retrained, and the loop repeats. Since everything runs in simulation,
the learner can make mistakes freely across different towns, weather conditions,
and traffic densities without any real-world safety risk.


---

## Advantages

### ✅ Directly Addresses Distributional Shift
DAgger's core contribution is solving the distributional shift problem of behavioural cloning.
By training on states the learner actually visits, the policy becomes robust to its own imperfections.
Theoretically, DAgger achieves a mistake bound that grows **linearly** with the time horizon,
compared to **quadratically** for behavioural cloning.

### ✅ More Sample Efficient Than Pure RL
DAgger still leverages expert knowledge to guide learning, making it far more sample efficient
than reinforcement learning. The expert provides dense,
direct supervision rather than sparse reward signals.

### ✅ Works with Offline Expert Oracles
The expert does not need to be present in real-time at every step.
Labels can be collected asynchronously, a human reviewer can annotate recordings
of the learner's driving after the fact.

### ✅ Can Use Simulated or Algorithmic Experts
In simulation-based autonomous driving research, a classical planner
or privileged agent can serve as the expert oracle, making DAgger fully automated
and highly scalable without any human labelling cost.

### ✅ Reduces Compounding Errors
Because the learner encounters and learns from recovery situations it naturally develops
more robust behaviour and better error-recovery capabilities.

### ✅ Interoperable with Modern Architectures
DAgger is a training procedure, not an architecture. It can be applied to
any model (Convolutional Neural Networks (CNNs), Transformers, Long Short-Term Memory (LSTMs)) and any modality (camera, LiDAR, multi-modal fusion),
making it highly flexible.

---

## Disadvantages

### ❌ Requires an Always-Available Expert Oracle
The fundamental requirement of DAgger is that an expert must be able to label any state the learner might visit.
In the real world, this is expensive and logistically complex, it typically requires a trained safety driver
accompanying every test run.

### ❌ Human Labelling is Expensive and Slow
Each iteration requires collecting new trajectories, sending them for expert labelling,
and retraining. This cycle is slow and costly when human annotators are involved,
limiting the number of iterations that are practical.

### ❌ Expert Must Label Out-of-Distribution States
The expert is asked to provide labels for states that are the result of the learner's mistakes,
states the expert may never have encountered themselves.
Providing a good label for "what should I do now that the car is halfway off the road?"
requires significant expertise and careful annotation.

### ❌ Safety Concerns During Data Collection
Because the learner (not the expert) is driving during data collection iterations,
early iterations may produce dangerous driving behaviour.
This makes real-world DAgger data collection risky without robust safety mechanisms
(e.g., safety driver with instant override).

### ❌ Training Complexity Increases Over Iterations
As the aggregated dataset grows with each iteration, training time increases.
Managing a growing, multi-iteration dataset with potentially different state distributions
across iterations adds engineering complexity.

### ❌ Does Not Completely Eliminate Distribution Mismatch
While DAgger significantly reduces distributional shift compared to behavioural cloning,
it does not eliminate it entirely. Rare or novel states encountered at deployment may still
not be covered in the training data if they were not visited during any training iteration.

### ❌ Convergence Can Be Slow
Depending on how poorly the initial policy performs and how broad the state space is,
DAgger may require many iterations to converge to a satisfactory policy,
particularly in complex urban driving environments.

---

## Summary

| Property | DAgger |
|---|---|
| Training Signal | Iteratively queried expert labels |
| Reward Function Needed | No |
| Real-world Safety During Training | Moderate |
| Generalisation to Novel Situations | Moderate–High |
| Handles Distributional Shift | Yes (iteratively) |
| Data Requirements | Moderate (grows each iteration) |
| Complexity | Moderate |
| Can Exceed Expert Performance | No |
