# CI artifact retention and optional S3 retention

This document shows a practical path to retain traceability artifacts produced by CI beyond Actions artifacts lifetime by uploading them to S3 using either GitHub OIDC role assumption (recommended) or long-lived AWS keys (fallback).

Overview
- CI job already produces traceability artifacts: CSV matrix, per-category CSVs, a markdown report and JSON manifest.
- By default these are uploaded to GitHub Actions artifacts. For longer retention, upload them to S3 and record the manifest location in the PR.

Option A — Recommended: OIDC role (no secrets)
1. Create an IAM role for GitHub Actions OIDC trust. Example trust policy (replace ACCOUNT_ID and repo path):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"},
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {"token.actions.githubusercontent.com:sub": "repo:SEAME-pt/Team04_DrivaPi:*"}
      }
    }
  ]
}
```

2. Attach an inline policy that grants S3 put permissions for the chosen prefix (minimal):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/traceability/*"
    }
  ]
}
```

3. Add the role ARN to the repository secret `TRACEABILITY_ROLE_ARN` (no keys stored in the repo).
4. CI will detect the role secret and use OIDC to assume it and upload artifacts to the configured bucket/prefix.

Option B — Fallback: long-lived keys (not recommended)
1. Create an IAM user with minimal policy (same as above).
2. Store `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as repository secrets and `TRACEABILITY_S3_BUCKET` as the bucket name.
3. CI will use the keys to upload artifacts.

Encryption and retention
- Use `TRACEABILITY_S3_SSE=AES256` for SSE-S3, or `TRACEABILITY_KMS_KEY` to set SSE-KMS.
- Configure S3 lifecycle rules for retention and archival according to your project's policy (e.g., transition to Glacier after 90 days).

Testing locally
- To test the upload step locally, create a small artifact and use the AWS CLI with the provided keys or assume-role call.

CI workflow notes
- The workflow guards the S3 upload step at runtime. If no role or keys are present, it will skip the upload.
- The workflow outputs `manifest_url` (S3 path) which is commented back on PRs when available.

Security notes
- Prefer OIDC role to avoid long-lived keys.
- Limit the role to the exact repository and prefix via the trust condition and resource ARN.
- Audit role usage in AWS CloudTrail.

Troubleshooting
- If uploads fail with access denied, ensure the role's inline policy covers the prefix and that trust policy matches the repo path.
- For KMS failures, ensure the role/user has kms:Encrypt permission for the chosen key.

Document created: 2025-10-17
