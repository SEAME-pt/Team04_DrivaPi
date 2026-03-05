# Reinforcement Learning for Autonomous Driving

## Overview

Reinforcement Learning (RL) is a machine learning paradigm where an **agent learns to make decisions
by interacting with an environment** and receiving feedback in the form of rewards or penalties.
Unlike supervised learning, there is no labelled dataset, the agent must discover good behaviour through trial and error.

The agent continuously improves its **policy** (a mapping from observations to actions)
by maximising the cumulative reward signal over time.
In autonomous driving, this means the agent explores different driving behaviours
and is rewarded for desirable outcomes (staying in lane, obeying speed limits, reaching the destination safely)
and penalised for undesirable ones (collisions, traffic violations, uncomfortable manoeuvres).

---

## How Reinforcement Learning Works

### Core Components

| Component | Description |
|---|---|
| **Agent** | The autonomous vehicle / driving policy |
| **Environment** | The road, traffic, weather conditions, other vehicles |
| **State (S)** | Sensor observations: camera, LiDAR, GPS, speed, etc. |
| **Action (A)** | Control outputs: steering angle, throttle, braking |
| **Reward (R)** | Scalar signal indicating how good the last action was |
| **Policy (π)** | The function mapping states to actions that the agent learns |

### The RL Loop

```
Agent observes state Sₜ
       ↓
Agent selects action Aₜ ~ π(Sₜ)
       ↓
Environment transitions to Sₜ₊₁
       ↓
Agent receives reward Rₜ
       ↓
Agent updates policy to maximise future cumulative reward
       ↓
Repeat
```

The agent's goal is to maximise the **expected discounted return**, the total accumulated reward over time,
where a discount factor $\gamma$ controls how much the agent prioritises immediate rewards over future ones.
A value close to 1 makes the agent think long-term, while a value close to 0 makes it focus on short-term gains.

### Key Algorithms Used in Autonomous Driving

| Algorithm | Category | Key Characteristics |
|---|---|---|
| **PPO** (Proximal Policy Optimisation) | Policy Gradient | Stable, widely used, on-policy |
| **SAC** (Soft Actor-Critic) | Actor-Critic | Sample efficient, off-policy, entropy regularised |
| **TD3** (Twin Delayed Deep Deterministic Policy Gradient (DDPG)) | Actor-Critic | Robust to function approximation errors |
| **DQN** (Deep Q-Network) | Value-Based | Works with discrete action spaces |
| **DDPG** (Deep Deterministic Policy Gradient) | Actor-Critic | Continuous action spaces |
| **Dreamer / World Models** | Model-Based | Learns a world model, plans in latent space |

### Reward Function Design for Driving

Designing the reward function is a critical and challenging step.
A typical autonomous driving reward function combines multiple weighted terms, rewarding forward progress
and rule compliance, while penalising collisions, lane deviation, and uncomfortable manoeuvres.

---

## Application in Autonomous Driving

RL has been applied across a wide spectrum of autonomous driving sub-tasks:

### Lane Keeping & Speed Control
Simple RL tasks where the agent learns to maintain lane position and follow speed limits using camera and speed sensor input.

### Highway Driving & Merging
Agents learn complex multi-vehicle interactions, when to accelerate to merge, how to follow safely, how to change lanes.

### Intersection Navigation
RL agents can learn to navigate uncontrolled intersections by reasoning about other vehicles' trajectories and right-of-way.

### Parking
Goal-conditioned RL policies learn precise low-speed manoeuvres for parking in constrained spaces.

### End-to-End Driving
Large-scale RL-based systems (e.g., **Wayve's LINGO**, **comma.ai**) attempt to learn the full driving pipeline from raw sensors to control outputs.

---

## Using CARLA Simulator for Reinforcement Learning

CARLA is a natural fit for RL training as it provides built-in event-based sensors
that can feed directly into the reward function. For example, CARLA exposes tags for
**lane invasions** (crossing lane markings), **collisions**, and **traffic light states**,
which can be used to penalise bad behaviour. Combined with the vehicle's speed and route progress,
these signals make it straightforward to define a reward function that encourages safe,
rule-compliant driving, without needing any external annotation.

---

## Advantages

### ✅ No Expert Demonstrations Required
RL agents discover optimal behaviour through exploration, so there is no need to collect human demonstrations.
This is particularly valuable in scenarios where expert behaviour is difficult or expensive to obtain.

### ✅ Can Surpass Human-Level Performance
Because the agent is not constrained to mimic a human expert, it can discover strategies that are more efficient,
safer, or more optimal than anything a human demonstrator would provide.
RL has achieved superhuman performance in many domains (games, robotics, etc.).

### ✅ Naturally Handles Sequential Decision-Making
Autonomous driving is inherently sequential, each action affects future states.
RL is specifically designed to optimise long-horizon sequential decisions, making it a natural fit.

### ✅ Can Learn from Simulated Environments at Scale
RL agents can train in high-fidelity simulators (CARLA, Simulation of Urban MObility (SUMO), MetaDrive, nuPlan) at speeds far beyond real-time,
accumulating millions of kilometres of virtual driving experience without any safety risk.

### ✅ Robust to Distributional Shift During Training
Since the agent interacts with the environment and receives feedback, it naturally encounters and learns from states
that result from its own imperfect actions, directly addressing the distributional shift problem that plagues imitation learning.

### ✅ Adaptable to Changing Objectives
By modifying the reward function, the same RL framework can be repurposed
for different driving styles (sporty vs. eco-friendly vs. defensive)
or different operational contexts (city vs. highway vs. off-road).

---

## Disadvantages

### ❌ Reward Function Engineering is Extremely Difficult
Designing a reward function that correctly captures the desired behaviour is notoriously hard.
A poorly designed reward can lead to **reward hacking**, the agent finds unexpected shortcuts
to maximise reward without achieving the intended goal.

### ❌ Very Sample Inefficient
RL typically requires millions to billions of environment interactions to converge to a good policy.
In the real world, this is completely impractical, the vehicle would need to drive for thousands of
hours to learn even basic driving skills.

### ❌ Safety During Exploration is a Major Concern
Early in training, the RL agent acts randomly or sub-optimally. In a real vehicle, this means crashes,
traffic violations, and dangerous behaviour. Extensive simulation is required before any real-world deployment,
but simulation-to-reality transfer (sim-to-real gap) remains unsolved.

### ❌ Simulation-to-Reality Gap (Sim-to-Real)
Simulators do not perfectly replicate real-world physics, sensor characteristics,
or the unpredictable behaviour of human drivers. Policies trained in simulation often fail
to transfer cleanly to the real world.

### ❌ Training Instability
Many RL algorithms, especially deep RL, are notoriously difficult to train, sensitive to hyperparameters,
prone to divergence, and highly non-deterministic. Reproducing results across different seeds
or environments is often challenging.

### ❌ Sparse and Delayed Rewards
In driving, rewards are often sparse, the agent may only receive a large negative reward after a collision
that was set up many timesteps earlier. This makes credit assignment, 
figuring out which past actions led to the outcome, very difficult.

### ❌ Difficulty with Multi-Agent Scenarios
Real traffic involves many vehicles interacting simultaneously. Multi-agent RL (MARL) scales poorly, 
with more agents comes exponentially more complexity and instability in training.

---

## Summary

| Property | Reinforcement Learning |
|---|---|
| Training Signal | Reward function |
| Expert Demonstrations Needed | No |
| Real-world Safety During Training | Low (simulation required) |
| Generalisation to Novel Situations | High (with diverse training) |
| Handles Distributional Shift | Yes (by design) |
| Data / Interaction Requirements | Very High |
| Complexity | High |
| Can Exceed Human Performance | Yes |

