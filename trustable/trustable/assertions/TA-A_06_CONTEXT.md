---
active: true
derived: false
level: 1.6.1
links: []
normative: false
ref: ''
reviewed: d2422190c462147644e9180d521b1d727b1919a5e747f4225a02c46335e48346
---

**Guidance**

This assertion is satisfied to the extent that we have mirrored sources for DrivaPi and tools, ensuring builds are reproducible via locked dependencies (e.g., Cargo.lock for Rust elements).

This addresses automotive needs where binary tools or online services limit control, relying on supplier attestations.

**Evidence**

- Software Bill of Materials (SBoM) manifest of components/tools with source/binary indication, controlled URLs, upstream URLs
- Build instructions and CI logs demonstrating reproducibility

**Confidence scoring**

CS-A_06 is based on URL genuineness and explicit binary identification.

**Checklist**

- Could source/binary distinction be wrong?
- Could SBoM miss components?
- Does SBoM include toolchain/bootstrap?
- Are builds fully reproducible in CI?
