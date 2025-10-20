
Trustable Software Framework (TSF)

The Trustable Software Framework (TSF) approach is designed for software where safety, security, performance, availability and reliability are critical. Broadly, trust in software must be based on evidence. This overview explains the context and rationale for TSF, its model and methodology, and guidance on implementation.

Why TSF matters

Software and systems complexity has increased: modern software often cannot be guaranteed bug-free or deterministic. Releases happen frequently and each release carries risk. TSF helps measure, manage and reduce that risk by collecting evidence and presenting structured arguments about a release's trustworthiness.

Key areas to collect evidence for each release (example "XYZ" project):

- Provenance: who produced the software and what claims do they make?
- Construction: how the software is built, installed and run; how do we know it was done correctly?
- Change: how updates are made and how regressions are avoided?
- Expectations: what the software must do and must not do?
- Results: what the software actually does vs expectations?
- Confidence: estimate confidence from all the above.

TSF Tenets and Assertions

TSF represents requirements, claims and evidence as Statements and Links that form directed acyclic graphs (Trustable Graphs). Statements should be concise, affirmative and written in a way that supports logical reasoning. Links indicate implication relationships (parent → child).

Model and methodology (high level)

1. Setting Expectations — stakeholders define key functional and non-functional requirements as Statements.
2. Providing Evidence — contributors gather artifacts and validations that support Statements.
3. Documenting Assumptions — explicit statements about things outside project scope.
4. Recording Reasoning — build intermediate Assertions and document rationale.
5. Assessing Confidence — score evidence and compute confidence values for Statements.
6. Modification — mark changed Statements/Links as Suspect until reviewed.

Applying TSF in practice

- Express expectations as Statements and assemble a Trustable Graph.
- Link Statements to Artifacts (source code, tests, docs, results).
- Use validation (automated checks) where possible; otherwise use SME review as Reference.
- Maintain provenance (reviewed field, git SHA) for each requirement; create baselines and Trustable Reports for releases.

Practical tips

- Start small: pick a few critical Expectations and build evidence for them.
- Use `reqs/` formatted YAML files for requirements; ensure `ref`, `header`, `text`, `reviewers` and `reviewed` fields exist.
- Use CI to run validations and collect transient artifacts (test results, performance measurements) as Evidence.

Trustable compliance and the `-trustable` suffix

A release that follows the methodology (applies Trustable to its claims and includes a Trustable Report) may use a `-trustable` suffix on the release tag. This indicates sufficient information is available for consumers to assess trust, not that the software is implicitly safe for all use.

References and sources

- Trustable project documentation: https://codethinklabs.gitlab.io/trustable/trustable/
- trudag (Trustable tooling) documentation: https://codethinklabs.gitlab.io/trustable/trudag/
- ISO 26262 overview: https://www.iso.org/standard/68383.html
- ASPICE overview: https://www.automotivespice.com/

See also: `docs/tsf/TSF-quick-reference.md`, `docs/tsf/TSF-requirement-template.md`, `docs/tsf/TSF-traceability-guide.md` for practical guidance.
