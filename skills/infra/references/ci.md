# CI/CD — GitHub Actions with OIDC (default) vs CodePipeline

**Snapshot 2026-10-03.** No long-lived AWS keys anywhere: the workflow assumes a role.

## 1. GitHub Actions → AWS through OIDC

Why: GitHub mints a short-lived JWT per job; AWS trusts it for one role, scoped to one repo and
branch. No `AWS_ACCESS_KEY_ID` secret to leak or rotate —
https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws
and IAM's own guidance to prefer temporary credentials —
https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html .

Terraform side (in `modules/iam`): an `aws_iam_openid_connect_provider` for
`https://token.actions.githubusercontent.com` and a deploy role whose trust policy allows
`sts:AssumeRoleWithWebIdentity` only when `token.actions.githubusercontent.com:sub` equals
`repo:<org>/<repo>:ref:refs/heads/main` (apply role) or `repo:<org>/<repo>:pull_request`
(plan role, read-only). Two roles, two permission sets: plan reads state and describes; apply
writes.

Workflow (`.github/workflows/infra.yml`), plan on PR / apply on main:

```yaml
name: infra
on:
  pull_request: { paths: ["infra/**"] }
  push: { branches: [main], paths: ["infra/**"] }
permissions: { id-token: write, contents: read, pull-requests: write }
env: { AWS_REGION: us-east-1, TF_IN_AUTOMATION: "true" }
jobs:
  plan:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v4
      - uses: aws-actions/configure-aws-credentials@v6
        with: { role-to-assume: "${{ vars.AWS_PLAN_ROLE_ARN }}", aws-region: "${{ env.AWS_REGION }}" }
      - run: terraform fmt -recursive -check && terraform -chdir=infra/envs/dev init && terraform -chdir=infra/envs/dev validate
      - run: terraform -chdir=infra/envs/dev plan -no-color -input=false
  apply:
    if: github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: production           # required reviewers live here (§2)
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v4
      - uses: aws-actions/configure-aws-credentials@v6
        with: { role-to-assume: "${{ vars.AWS_APPLY_ROLE_ARN }}", aws-region: "${{ env.AWS_REGION }}" }
      - run: terraform -chdir=infra/envs/dev init && terraform -chdir=infra/envs/dev apply -auto-approve -input=false
```

Actions pinned by major (`@v4`, `@v6`) per their READMEs — https://github.com/hashicorp/setup-terraform ·
https://github.com/aws-actions/configure-aws-credentials ; pin to a commit SHA when the user's
policy requires it. Role ARNs are repository *variables*, not secrets: they are not sensitive.

## 2. Manual approval before apply

The `apply` job targets a GitHub **environment** with the *Required reviewers* protection rule
(up to 6 people or teams; one approval releases the job) —
https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments .
The user creates the environment and adds reviewers in Settings → Environments; **the skill
never enables a workflow that applies** — it writes the YAML and says which switch to flip.
Several environments → one job per env (`dev` auto, `prod` behind reviewers) or a Terragrunt
`run --all` per folder.

Cost: public repos free; private repos 2,000 min/mo on the Free plan, then $0.006/min for the
Linux 2-core runner — https://docs.github.com/en/billing/concepts/product-billing/github-actions .
A plan+apply pair is a few minutes; the free tier covers a small team.

## 3. CodePipeline — when the org is AWS-only

Pick it when source, approvals, identity and audit already live in AWS (CodeConnections to the
repo, IAM-gated manual approval action, CloudTrail) and there is no GitHub organization to
hold environments and reviewers — https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html .
Pricing: V1 $1 per active pipeline/mo (one free), V2 $0.002 per action-minute (100 free;
manual approvals are not billed) — https://aws.amazon.com/codepipeline/pricing/ .
Shape: Source (CodeConnections) → Build (CodeBuild runs fmt/validate/plan, stores the plan
artifact) → Approval (manual) → Deploy (CodeBuild runs `apply` on the stored plan). Define
the pipeline itself in Terraform (`aws_codepipeline`, `aws_codebuild_project`) so it is not
click-ops. Trade-off in one line: fewer moving parts outside AWS, but slower feedback on PRs
and no marketplace of actions.

## 4. Image build and deploy (application pipeline, separate workflow)

Build → `docker build` with the commit SHA tag → push to ECR (OIDC role with
`ecr:GetAuthorizationToken` + push on one repository) → register a new task definition
revision → `aws ecs update-service --force-new-deployment` (or let Terraform own the image tag
via a variable, which keeps a single source of truth). ECR storage is billed per GB-month —
https://aws.amazon.com/ecr/pricing/ . Immutable tags on the ECR repo so a tag can never be
re-pointed.

## 5. GitHub MCP (show, ask, never add)

```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ --header "Authorization: Bearer $GITHUB_PAT"
```

Remote server; the PAT comes from an env var, never pasted. Local alternative:
`claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PAT -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server` —
https://github.com/github/github-mcp-server . Useful here for reading workflow runs and PR
checks; the `git` specialist owns commits and PRs.
