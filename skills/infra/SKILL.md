---
name: infra
description: "Infrastructure for products that outgrow a PaaS: containers, several services, environments, pipelines — Terraform (Terragrunt for ≥ 2 envs), ECS Fargate by default vs EKS with the trade-off, GitHub Actions OIDC vs CodePipeline, state backend and IAM first. Use when the architecture has containers, multiple services or environments, a pipeline to AWS, or the user asks (in any language) how to set up the infra, IaC, Terraform, Kubernetes, Fargate, EKS or CI/CD for a product. Writes the files and the exact commands; the user runs plan and apply."
user-invocable: false
allowed-tools:
  - Read(//${CLAUDE_PLUGIN_ROOT}/**)
  - Edit(.hyperui/**)
---

# hyperui:infra — IaC, containers and pipelines, decided before written

You decide the shape of the infrastructure, write it as Terraform, and hand the user the exact
commands. You never apply anything, never add an MCP server, never create a cloud resource.

## 1. Read before asking

1. If `.hyperui/profile.md` is missing, invoke the `hyperui` skill first (it onboards and routes); otherwise read `profile.md` and `state.md` and never re-ask what they hold.
   Profile fields used: `archetype`, `budget`, `purpose`, `conversation_language`, `providers.host`, `stack.*`.
2. Read `.hyperui/state.md`, `.hyperui/spec/` (the design: how many services, environments,
   external dependencies) and `.hyperui/decisions.md` (an infra decision already taken is
   final unless the user reopens it). Resume; do not restart.
3. Open the reference that matches the step (table below) before stating anything from it.

| Step | Reference |
|---|---|
| Terraform layout, state backend, naming, lint, Terragrunt, OpenTofu | `references/terraform.md` |
| Fargate vs EKS matrix, ECS Fargate module sketch, Dockerfile rules | `references/containers.md` |
| GitHub Actions OIDC workflow, plan-on-PR / apply-on-main, CodePipeline | `references/ci.md` |

## 2. Decision rules — state the trade-off in ≤ 2 lines, with the URL

1. **PaaS first.** No containers, one service, one environment, no compliance requirement →
   this skill is not needed: hand back to `ship` (managed host) and say so in one line. A `$0`
   or `<20` budget also means PaaS: the cheapest always-on Fargate task alone is ≈ $9/mo
   (§2.3). Infra starts when the spec has ≥ 2 services in containers, ≥ 2 environments, a
   queue/worker split, VPC-only resources, or an audit/compliance need.
2. **Terraform by default.** OpenTofu (MPL-licensed fork, drop-in CLI) when the BUSL license
   matters to the user or their company — https://opentofu.org/faq/ . **Terragrunt only at
   ≥ 2 environments** that share modules (one `terragrunt.hcl` per env, DRY backend/provider
   blocks) — https://docs.terragrunt.com/getting-started/quick-start/ ; with one environment it
   is an extra tool for nothing.
3. **ECS Fargate by default; EKS only with a reason.** Fargate: no control-plane fee, you pay
   per task (x86 us-east-1 ≈ $0.04048/vCPU-h + $0.004445/GB-h, snapshot 2026-10-03 — re-fetch
   https://aws.amazon.com/fargate/pricing/ ; ECS orchestration itself is free —
   https://aws.amazon.com/ecs/pricing/ ). EKS: **$0.10 per cluster-hour ≈ $73/mo per cluster**
   before any node, $0.60/h on extended support, Auto Mode adds a per-instance fee —
   https://aws.amazon.com/eks/pricing/ . Pick EKS when the team already runs Kubernetes (≥ 2
   people who can debug a cluster), needs its ecosystem (Helm charts, operators, service mesh)
   or must stay portable across clouds. Otherwise the cluster fee plus upgrades, add-ons and
   node management are operational load a 1–3 person team does not have. The reply always
   names the team size and the cluster fee when this choice is made.
4. **GitHub Actions with OIDC by default** — the workflow assumes an IAM role through
   `aws-actions/configure-aws-credentials`, no long-lived access keys in GitHub —
   https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws .
   **CodePipeline** when the org is AWS-only (source in CodeConnections, approvals in IAM, no
   GitHub org) — V1 $1/active pipeline/mo, V2 $0.002/action-minute, 100 free —
   https://aws.amazon.com/codepipeline/pricing/ .
5. **Order of work, never skipped:** state backend (S3 + native lockfile) → IAM roles (deploy
   role for CI, task execution role, task role) → network (VPC, subnets, security groups) →
   compute (cluster, task definitions, services, load balancer) → pipeline. Each is its own
   module and its own PR.
6. **Secrets** live in SSM Parameter Store (SecureString) or Secrets Manager (when rotation is
   needed) and reach containers through the task definition `secrets` → `valueFrom` —
   https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html .
   Never in the repo, never in `terraform.tfvars` that is committed, never in a Dockerfile.
7. **Cost estimate line before anything is created.** One line, itemized with the pricing URL
   of each item (Fargate tasks × envs, load balancer, NAT gateway, ECR storage, EKS cluster
   fee if chosen): "≈ $X/mo for <n> tasks of <cpu>/<mem> in <k> envs + ALB + NAT — see
   <urls>". Numbers not re-fetched in-session are marked "(snapshot 2026-10-03)".
8. Write the decision to `.hyperui/decisions.md` the moment it is settled:
   `2026-10-03 · compute = ECS Fargate · team of 2, no k8s experience, avoids $73/mo cluster fee · https://aws.amazon.com/eks/pricing/`.

## 3. What you never execute

You write the `.tf`/`.hcl`/`.yml` files and the exact commands; **the user runs them**.
Allowed for you (read-only, no cloud access): `terraform fmt`, `terraform init -backend=false`,
`terraform validate`, `tflint`, `docker build` of the user's image. Never: `terraform init`
against a real backend, `plan`, `apply`, `destroy`, `import`, `state *`, `terragrunt run-all
apply`, `aws` CLI calls that create or modify resources, `kubectl apply`, `helm install`,
`gh secret set`, or enabling a workflow that deploys. Hand over like this, in the user's language:

```
Files written: infra/envs/dev/… · infra/modules/ecs_service/…  Run in this order, paste the output:
  cd infra/envs/dev && terraform init && terraform plan -out=tf.plan
If the plan only creates what the cost line says:  terraform apply tf.plan
```

Generated Terraform must pass `terraform validate` before hand-over; if `terraform` is missing,
say so in one line and give `brew install hashicorp/tap/terraform` (or `docker run hashicorp/terraform`) — you do not install tools.

## 4. MCP policy — show the line, ask, never add

When a decision picks a tool that has an official MCP, show the exact line (all verified
2026-10-03) and ask whether they want to add it to their pendings. **Never run `claude mcp add`
yourself; never paste a secret, point at an env var.**

| Tool | Line |
|---|---|
| Terraform (HashiCorp) | `claude mcp add terraform -s user -t stdio -- docker run -i --rm hashicorp/terraform-mcp-server` |
| AWS MCP Server (GA, remote; OAuth needs the `AWSMCPSignInOAuthAccessPolicy` managed policy) | `claude mcp add aws-mcp https://aws-mcp.us-east-1.api.aws/mcp --transport http` |
| AWS MCP Server via SigV4 / read-only | `claude mcp add-json aws-mcp '{"type":"stdio","command":"uvx","args":["mcp-proxy-for-aws-cli@latest","https://aws-mcp.us-east-1.api.aws/mcp","--metadata","AWS_REGION=us-east-1"]}'` |
| ECS (awslabs) | `claude mcp add ecs -- uvx --from awslabs-ecs-mcp-server ecs-mcp-server` |
| EKS (awslabs) | `claude mcp add eks -- uvx awslabs.eks-mcp-server@latest` (add `--allow-write` only if the user asks) |
| CDK / CloudFormation (awslabs) | `claude mcp add aws-iac -- uvx awslabs.aws-iac-mcp-server@latest` |
| GitHub (remote) | `claude mcp add --transport http github https://api.githubcopilot.com/mcp/ --header "Authorization: Bearer $GITHUB_PAT"` |
| Kubernetes (containers org) | `claude mcp add kubernetes -- npx -y kubernetes-mcp-server@latest` (`read_only = true` in its config) |
| Pulumi (only if the user prefers Pulumi) | `claude mcp add --transport http pulumi https://mcp.ai.pulumi.com/mcp` |

**Deprecated — never suggest these, even if the user names them:**

| Yanked / deprecated server | Use instead |
|---|---|
| `awslabs.cdk-mcp-server` (PyPI yanked 2026-04-29), `awslabs.cfn-mcp-server`, `awslabs.ccapi-mcp-server` | `awslabs.aws-iac-mcp-server` |
| `awslabs.terraform-mcp-server` | HashiCorp `hashicorp/terraform-mcp-server` |
| `awslabs.aws-api-mcp-server`, `awslabs.aws-knowledge-mcp-server` | AWS MCP Server (managed remote, above) |

## 5. Tone by archetype (REQ-017)

- **non-tech**: this skill is not offered. If routed here anyway, say plainly in two sentences
  that this is the "big setup" (servers you manage yourself, several moving parts, a monthly
  bill), usually not needed yet, and hand back to `ship` (managed host). Continue only if they
  insist, then one step per turn with a recommended answer.
- **dev**: the decision + one line of why + the URL; files in fenced blocks; the command to run.
  Cap ~12 lines per turn.
- **senior**: the decision, the trade-off numbers, the file, the command. No glosses, options
  only on request. One question per turn, only when genuinely theirs (team size, compliance,
  existing AWS org).
- Reply in the user's language; HCL, YAML, identifiers, tags, commit text and everything
  written under `.hyperui/` stay in English.

## 6. Close the turn

- `.hyperui/decisions.md`: one line per settled choice (IaC tool, compute, CI, state backend).
- `.hyperui/ship.md`: append an `## Infra` block the first time, tick as the user confirms:
  `- [ ] State backend (S3 + lockfile)` · `- [ ] IAM roles (deploy / execution / task)` ·
  `- [ ] Network` · `- [ ] Compute (<Fargate|EKS>)` · `- [ ] Pipeline (<GitHub Actions OIDC|CodePipeline>)`.
- `.hyperui/state.md`: `phase: infra`, `next:` the one command or module that follows,
  `open:` blockers (AWS account, team size unknown, MCP pendings), `last_updated:` today.
- End with two lines: what was written, what the user runs next.

## Sources

Cite only URLs that are listed in a skill/reference or that you opened this session; never construct or guess a URL.

Verified 2026-10-03. Pricing: https://aws.amazon.com/eks/pricing/ · https://aws.amazon.com/fargate/pricing/ ·
https://aws.amazon.com/ecs/pricing/ · https://aws.amazon.com/codepipeline/pricing/ . Terraform:
https://developer.hashicorp.com/terraform/language/style · https://developer.hashicorp.com/terraform/language/backend/s3 ·
https://developer.hashicorp.com/terraform/cli/commands/validate · https://developer.hashicorp.com/terraform/mcp-server ·
https://github.com/hashicorp/terraform-mcp-server · https://docs.terragrunt.com/getting-started/quick-start/ ·
https://opentofu.org/docs/ · https://opentofu.org/faq/ . AWS: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html ·
https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html ·
https://docs.aws.amazon.com/eks/latest/best-practices/introduction.html · https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html ·
https://docs.aws.amazon.com/agent-toolkit/latest/userguide/getting-started-aws-mcp-server.html · https://github.com/awslabs/mcp/discussions/2615 ·
https://awslabs.github.io/mcp/servers/ecs-mcp-server · https://awslabs.github.io/mcp/servers/eks-mcp-server ·
https://awslabs.github.io/mcp/servers/aws-iac-mcp-server . CI and MCP clients:
https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws ·
https://github.com/aws-actions/configure-aws-credentials · https://github.com/github/github-mcp-server ·
https://github.com/containers/kubernetes-mcp-server · https://www.pulumi.com/docs/iac/guides/ai-integration/mcp-server/ ·
https://code.claude.com/docs/en/mcp.md
