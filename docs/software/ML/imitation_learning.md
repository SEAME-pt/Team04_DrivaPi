# Imitation Learning for Autonomous Driving

## Overview

Imitation Learning (IL) is a supervised machine learning paradigm where an agent learns to perform a task
by **mimicking the behaviour of an expert**. Rather than hand-crafting reward functions or rules,
the system observes demonstrations, typically human drivers, and learns a policy that maps sensor observations (camera frames, LiDAR, Sonar, etc.)
directly to driving actions (steering angle, throttle, braking).

The core intuition is simple: *if we can record what a skilled driver does in a wide variety of situations,
a neural network can learn to reproduce that behaviour.*

---

## How Imitation Learning Works

### 1. Data Collection
An expert (human driver or a scripted planner) operates the vehicle while all sensor data and
corresponding control outputs are logged. This creates a dataset of `(observation, action)` pairs.

### 2. Policy Training
A supervised learning model, most commonly a deep neural network, is trained to minimise
the difference between its predicted actions and the expert's recorded actions.
Common loss functions include:

- **Mean Squared Error (MSE)** for continuous controls (steering, throttle)

  MSE measures the average squared difference between the model's predicted action
  and the expert's recorded action. Squaring the error penalises large deviations heavily,
  which is desirable when precise, smooth control (e.g., steering angle) is critical.

- **Cross-Entropy Loss** for discretised action spaces

  When actions are grouped into classes (e.g., "turn left", "go straight", "turn right"),
  the model outputs a probability for each class. Cross-Entropy penalises the model when it is confidently wrong,
  pushing it to assign high probability to the correct action class.

### 3. Deployment
At inference time, the trained policy receives only raw sensor data
and outputs control commands directly, without any explicit planning module.

### Key Variants

| Variant | Description |
|---|---|
| **Behavioural Cloning (BC)** | The simplest form, pure supervised learning on expert demonstrations. |
| **Inverse Reinforcement Learning (IRL)** | Infers a reward function from expert behaviour, then uses RL to optimise it. |
| **Generative Adversarial Imitation Learning (GAIL)** | Uses a Generative Adversarial Network (GAN)-like setup to match the expert's state-action distribution. |
| **Dataset Aggregation (DAgger)** | Iteratively queries the expert to correct the learner's mistakes (see dedicated file). |

---

## Application in Autonomous Driving

Imitation learning gained significant real-world traction through projects like **NVIDIA's End-to-End Learning for 
Self-Driving Cars (2016)**, where a Convolutional Neural Network (CNN) was trained solely on human driving data to output steering angles. More recent 
systems use IL as a warm-start or pre-training stage before fine-tuning with reinforcement learning.

Typical inputs used in autonomous driving IL pipelines:
- Red, Green, Blue (RGB) cameras (front, surround)
- Light Detection and Ranging (LiDAR) point clouds
- Global Positioning System (GPS) / Inertial Measurement Unit (IMU) measurements
- High-definition maps

Typical outputs:
- Steering angle
- Throttle / brake percentage
- Waypoints for a downstream controller

---

## Using CARLA Simulator for Imitation Learning

CARLA's built-in **Autopilot / Traffic Manager** acts as the expert driver, navigating road networks while respecting traffic rules. This means large amounts of labelled demonstration data can be generated automatically across different towns, weather conditions, and traffic densities, without needing a human to manually drive.

Once the dataset is collected, training happens entirely offline. The recorded `(observation, action)` pairs are fed into the neural network. After training, the policy is deployed back into CARLA to evaluate its driving performance.

---

## Advantages

### ✅ No Reward Engineering Required
One of the most labour-intensive parts of reinforcement learning is designing a reward function
that correctly captures the desired behaviour. Imitation learning sidesteps this entirely,
the expert demonstrations implicitly encode the desired behaviour.

### ✅ Sample Efficient Compared to RL
Learning from human demonstrations requires far fewer environment interactions
than exploring from scratch with reinforcement learning. A moderate-sized dataset of human drives
can produce a functional policy.

### ✅ Leverages Existing Human Expertise
Decades of collective human driving knowledge can be compressed into a dataset and transferred to the model.
Edge cases that would take an RL agent millions of episodes to encounter organically
can be deliberately included in the training set.

### ✅ Simpler Training Pipeline
The training loop is standard supervised learning, well-understood, stable, and supported by mature tooling (PyTorch, TensorFlow, etc.).

### ✅ Safe Data Collection
Training data is collected from human drivers operating the vehicle normally, which is inherently safe.
There is no need to let an untrained agent explore dangerous states in the real world.

### ✅ Interpretable Failure Modes
When the model fails, debugging is relatively straightforward, you can inspect which observations the model misjudged
and augment the dataset with more examples of similar situations.

---

## Disadvantages

### ❌ Distributional Shift
This is the **fundamental weakness** of behavioural cloning. The model is trained on the expert's state distribution,
but at deployment it will encounter states that result from its own (imperfect) actions.
Small errors compound over time, leading the agent into situations that were never covered in the training data.
The agent has no data on how to recover.

### ❌ Requires Large, High-Quality Datasets
The model can only be as good as the data it was trained on. Collecting diverse, high-quality demonstrations that cover rare 
but critical scenarios (emergency braking, obstacle avoidance, adverse weather) is expensive and time-consuming.

### ❌ Replicates Expert Mistakes
If the human expert makes systematic errors or has bad habits (e.g., late braking, inconsistent lane positioning),
the model will faithfully learn and reproduce those mistakes.

### ❌ Poor Generalisation to Novel Scenarios
Pure behavioural cloning struggles in situations that differ significantly from the training distribution, 
different road geometries, unusual weather conditions, or unexpected obstacles that were not represented in training data.

### ❌ No Explicit Notion of Safety
The model has no built-in mechanism to reason about safety margins or traffic rules.
It simply imitates what the expert did, which may not always be the safest possible action.

### ❌ Causal Confusion
Neural networks trained with IL can learn spurious correlations.
For example, the model might learn to brake when it sees brake lights in its camera feed
even when braking is not necessary, simply because those two events co-occurred in the training data.

---

## Summary

| Property | Imitation Learning |
|---|---|
| Training Signal | Expert demonstrations |
| Reward Function Needed | No |
| Real-world Safety During Training | High |
| Generalisation to Novel Situations | Moderate |
| Handles Distributional Shift | Poorly (without augmentation) |
| Data Requirements | Moderate–High |
| Complexity | Low–Moderate |
