# Terraform — layout, state, naming, lint, Terragrunt, OpenTofu

**Snapshot 2026-10-03.** Every rule below has its URL; open it before quoting anything else.
Style source: https://developer.hashicorp.com/terraform/language/style

## 1. Layout (one environment)

```
infra/
  modules/                 # reusable, no provider config, no backend
    network/               # vpc, subnets, nat, security groups
    iam/                   # deploy role (OIDC), task execution role, task role
    ecs_service/           # see containers.md §2
    state_backend/         # S3 bucket for state (bootstrapped once, local state then migrated)
  envs/
    dev/
      backend.tf  main.tf  providers.tf  terraform.tf  variables.tf  outputs.tf  dev.tfvars
```

File roles per the style guide: `terraform.tf` (required_version + required_providers),
`providers.tf`, `backend.tf`, `main.tf` (resources, module calls), `variables.tf` and
`outputs.tf` alphabetical, `locals.tf` when needed. Split `main.tf` by concern
(`network.tf`, `compute.tf`) once it grows. Modules own no `provider` or `backend` blocks.

## 2. State backend — the first module, always

S3 with the **native lockfile**; DynamoDB locking is deprecated and will be removed —
https://developer.hashicorp.com/terraform/language/backend/s3

```hcl
terraform {
  backend "s3" {
    bucket       = "acme-tfstate-123456789012"   # account id in the name: globally unique
    key          = "dev/root.tfstate"            # one key per env (or per Terragrunt unit)
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
```

Bootstrap: `modules/state_backend` creates the bucket (versioning on, public access blocked,
SSE enabled) with **local** state; the user runs `terraform init -migrate-state` once after
adding `backend.tf`. The deploy role needs `s3:GetObject/PutObject/DeleteObject` on the key
prefix and `s3:ListBucket` on the bucket — nothing broader.

## 3. Versions

```hcl
terraform {
  required_version = ">= 1.10"            # use_lockfile needs 1.10+
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}
```

Commit `.terraform.lock.hcl`. Bumping a provider major is a dependency change: ask first.

## 4. Naming and tagging

- Resource and variable names: lowercase, underscores, descriptive nouns
  (`aws_ecs_service.api`, not `apiService`) — style guide above.
- Cloud-side names: `<product>-<env>-<component>` (`acme-dev-api`); keep them in a `locals`
  `name_prefix`.
- Tags on everything through `provider "aws" { default_tags { tags = local.tags } }`:
  `Product`, `Environment`, `ManagedBy = "terraform"`, `Owner`, `CostCenter` when billing
  needs it — https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/tagging-best-practices.html

## 5. Lint and validate (safe for the skill to run; no cloud access)

```bash
terraform fmt -recursive -check          # formatting; drop -check to fix
terraform init -backend=false            # plugins only, no backend touched
terraform validate                       # syntax + internal consistency
tflint --init && tflint --recursive      # provider-aware lint (.tflint.hcl with the aws ruleset)
```

`validate` needs an initialized directory; `-backend=false` is the documented way to do it
without a backend — https://developer.hashicorp.com/terraform/cli/commands/validate .
tflint: https://github.com/terraform-linters/tflint (`brew install terraform-linters/tap/tflint`,
user installs). All four belong in the plan-on-PR job (`ci.md`).

## 6. Terragrunt — when, and only then

Use it at **≥ 2 environments that share the same modules**: one `root.hcl` generates the
backend and provider blocks, one `terragrunt.hcl` per unit (`envs/dev/api/terragrunt.hcl`)
holds only inputs and the module source; `terragrunt run --all plan` walks the dependency
graph — https://docs.terragrunt.com/getting-started/quick-start/ . With a single environment
it adds a binary, a second config language and nothing else: plain Terraform with
`envs/<env>/` folders. Terragrunt has no official MCP; use the Terraform MCP plus the docs.

## 7. OpenTofu

Linux Foundation fork created after HashiCorp's move to BUSL; same HCL, `tofu` binary,
docs at https://opentofu.org/docs/ (1.13.x), reasons and license stance at
https://opentofu.org/faq/ . Choose it when the license matters to the user or their company;
otherwise Terraform, which the AWS and HashiCorp docs target first. Terragrunt supports both.

## 8. HCP Terraform (remote runs) — optional

Free organizations are capped at **500 managed resources** —
https://developer.hashicorp.com/terraform/cloud-docs/overview . Default for hyperui is the S3
backend plus GitHub Actions (§2, `ci.md`); HCP only when the team wants hosted runs/policies.

## 9. Terraform MCP (show the line, ask, never add)

```bash
claude mcp add terraform -s user -t stdio -- docker run -i --rm hashicorp/terraform-mcp-server
```

Needs Docker running; add `-e TFE_TOKEN=$TFE_TOKEN` only for HCP Terraform. It serves live
registry docs for providers and modules so resource arguments are never guessed —
https://developer.hashicorp.com/terraform/mcp-server · https://github.com/hashicorp/terraform-mcp-server .
For AWS resource documentation the AWS MCP Server (SKILL.md §4) is the second source.
