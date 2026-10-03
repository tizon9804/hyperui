# Containers — Fargate vs EKS, ECS Fargate module sketch, Dockerfile rules

**Snapshot 2026-10-03.** Prices are re-fetched from the URL before being quoted.

## 1. Fargate vs EKS

| | ECS Fargate (default) | EKS |
|---|---|---|
| Fixed fee | None: ECS orchestration is free — https://aws.amazon.com/ecs/pricing/ | **$0.10/cluster-h ≈ $73/mo per cluster** (standard support), $0.60/h on extended support; Auto Mode adds a per-instance fee — https://aws.amazon.com/eks/pricing/ |
| Compute | Per task: x86 ≈ $0.04048/vCPU-h + $0.004445/GB-h, ARM ≈ 20% less, Spot cheaper and interruptible — https://aws.amazon.com/fargate/pricing/ | Nodes (EC2 or Fargate profiles) on top of the cluster fee |
| Team | 1–3 people, nobody on call for a cluster | ≥ 2 people who already run Kubernetes and can debug nodes, add-ons, upgrades |
| Ops load | Task definition + service; AWS patches the hosts (platform versions) | Cluster upgrades, CNI/CoreDNS/kube-proxy add-ons, node groups, RBAC, admission |
| Ecosystem | ALB/NLB, Service Connect, CloudWatch, App Mesh is retired | Helm, operators, service meshes, GitOps controllers, portable manifests |
| Pick when | Several HTTP/worker services, one cloud, small team | Existing k8s skills, need its ecosystem, multi-cloud portability, platform team |

Rule of thumb for the reply: "team of N, no k8s on-call → Fargate; EKS would add ≈ $73/mo per
cluster per environment before nodes" — with both pricing URLs.
Fargate facts: `requiresCompatibilities = ["FARGATE"]`, `awsvpc` network mode, target groups
of type `ip`, every task gets its own ENI — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html .
Operational guidance: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-best-practices.html .

## 2. Minimal ECS Fargate service module (`modules/ecs_service`)

```hcl
variable "name" { type = string }
variable "cluster_arn" { type = string } # one cluster per env, shared by the services
variable "image" { type = string }       # ECR image with an immutable tag
variable "port" { type = number }
variable "region" { type = string }
variable "size" { type = object({ cpu = number, memory = number, desired_count = number }) }
variable "network" { type = object({ subnet_ids = list(string), security_group_ids = list(string) }) }
variable "roles" { type = object({ execution_arn = string, task_arn = string }) }
variable "secrets" { type = map(string) } # ENV_NAME => SSM parameter / Secrets Manager ARN

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.size.cpu
  memory                   = var.size.memory
  execution_role_arn       = var.roles.execution_arn
  task_role_arn            = var.roles.task_arn
  container_definitions = jsonencode([{
    name         = var.name
    image        = var.image
    portMappings = [{ containerPort = var.port, protocol = "tcp" }]
    secrets      = [for k, v in var.secrets : { name = k, valueFrom = v }]
    logConfiguration = { logDriver = "awslogs", options = { "awslogs-group" = "/ecs/${var.name}",
      "awslogs-create-group" = "true", "awslogs-region" = var.region, "awslogs-stream-prefix" = "app" } }
  }])
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.size.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.network.subnet_ids
    security_groups  = var.network.security_group_ids
    assign_public_ip = false
  }
}
```

Argument reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service .
Sizing: `cpu`/`memory` must be a valid Fargate pair (256/512, 512/1024, 1024/2048…); start at
the smallest and let the plan-on-PR job catch invalid pairs. Add a `load_balancer {}` block and
an ALB target group of type `ip` for HTTP services; workers need neither. The cluster
(`aws_ecs_cluster`, one per env) lives in the caller. `awslogs-create-group` needs
`logs:CreateLogGroup` on the execution role; for a retention policy declare the
`aws_cloudwatch_log_group` in the caller instead. Secrets arrive via `secrets[].valueFrom` from
SSM SecureString or Secrets Manager; the **execution role** needs `ssm:GetParameters` /
`secretsmanager:GetSecretValue` on those ARNs only —
https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html .
A changed secret needs a forced new deployment to be picked up (same page).

## 3. Dockerfile rules — https://docs.docker.com/build/building/best-practices/

- **Multi-stage**: build in one stage, copy only the artifact into a slim runtime stage.
- **Pinned base**: tags are mutable; pin `image:1.2.3` or a digest, never `latest`.
- **Non-root**: `USER` to an unprivileged user once dependencies are installed.
- `.dockerignore` for `.git`, `node_modules`, `.env*`, build caches; one process per container;
  `HEALTHCHECK` or an ALB health path; no secrets in `ENV`, `ARG` or layers.
- Push to ECR with an immutable tag per commit (`sha-<short>`) so the task definition pins it.

## 4. If EKS is the pick

Read the official guide first — https://docs.aws.amazon.com/eks/latest/best-practices/introduction.html —
then the Kubernetes production checklist https://kubernetes.io/docs/setup/production-environment/
and the security checklist https://kubernetes.io/docs/concepts/security/security-checklist/ .
Minimums: Pod Security Standards enforced, resource requests/limits on every workload,
IRSA/Pod Identity instead of node-wide credentials, private endpoint or restricted CIDR,
one cluster per environment (so count the cluster fee once per env).

## 5. Kubernetes MCP (show, ask, never add)

```bash
claude mcp add kubernetes -- npx -y kubernetes-mcp-server@latest
```

Native Go server from the `containers` org, not a kubectl wrapper; set `read_only = true` in
its config until the user wants writes — https://github.com/containers/kubernetes-mcp-server .
ECS/EKS awslabs servers: lines in `SKILL.md` §4.
