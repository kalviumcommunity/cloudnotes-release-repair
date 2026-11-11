# CloudNotes Release Repair

Repair three bounded configuration defects, then verify CloudNotes locally. Fork this repository, clone your fork, create `fix/local-release`, and open the folder in your IDE. Repair scope, runtime contract and checks follow below.

## Submission boundary — do not modify the question repository

This repository is the intentionally broken question starter. **Do not push any branch or fix to `kalviumcommunity/cloudnotes-release-repair`. Do not open a pull request against this question repository.** Work only in your personal fork. If committing/pushing, confirm `git remote -v` points `origin` to your own GitHub username, then push only there. Submit the PDF through the assessment portal; no pull request is required anywhere.

## Free local setup

Use Terraform >=1.4 and <2, Git, curl, Docker Engine and Docker Compose v2 supporting `up --wait`, and a free IDE/PDF exporter. Docker Desktop is optional only where its free-use licence applies. No paid tools, cloud resources, registry login, or real credentials are needed. Prepare tools and caches yourself before timed work. Linux, macOS or WSL2 with amd64/arm64 Docker, Bash and Python 3 are supported. Allow 2 CPUs, 4 GB free memory and 10 GB disk. First image/package downloads need internet, not payment.

Host ports 5050 (local registry) and 8080 (web) must be free. Run before timing:

```bash
bash scripts/prerequisites.sh
```

Wait for `PREREQUISITES READY`. Helper checks versions/ports, validates isolated built-in Terraform probe without changing broken input, pulls base/database/registry images, builds unchanged correct dependency stage and performs actual push/pull through temporary loopback-only registry. Temporary registry is removed automatically. Publish helper later starts owned registry project. Build-stage layers warm actual dependency cache, not an offline-build guarantee; evicted caches or changed dependencies may still need internet. Initial build/cache rehearsal is ungraded. Do not begin timing on setup failure or reconfigure daemon security during tasks. No unknown containers are removed.

## Files to repair

- `terraform/main.tf`: root-module input interface.
- `Dockerfile`: runtime dependency-artifact copy.
- `compose.yaml`: web-to-database connection configuration.

These are three defect groups, not three arbitrary syntax edits. Application code, reusable module internals, health checks, registry definition, and helper script work as supplied. Do not modify them or bypass checks.

## Terraform

```bash
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform fmt -recursive
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform validate
terraform -chdir=terraform plan -out=tfplan
```

No cloud provider is installed. Built-in `terraform_data` represents one local desired release inventory, not real infrastructure. After repair the plan proposes one resource to add; no apply is needed or allowed. Plan/validate do not prove cloud permissions, deployment, or application health. This exercise uses local state; a team would use an access-controlled shared backend with backend-supported locking/versioning. Never commit state or plan files. The local backend also supports locking; shared-state coordination is a separate concern.

## Build

```bash
docker build -t cloudnotes:1.0.0 .
docker image inspect cloudnotes:1.0.0 --format '{{.RepoTags}} size={{.Size}} user={{.Config.User}}'
```

The Python app requires Flask and psycopg. The build stage packages dependencies; the runtime stage should carry those dependencies and app code, not the build workspace. Keep the official slim base and non-root `app` runtime.

## Publish, pull, and run

```bash
bash scripts/publish-local.sh
docker compose config --quiet
docker compose up -d --wait --wait-timeout 90
docker compose ps
curl -i http://localhost:8080/health
```

The publish script starts a separate local registry project, tags `cloudnotes:1.0.0` as `localhost:5050/cloudnotes:1.0.0`, pushes, removes that local registry-qualified reference, and explicitly pulls it back. It prints a final image/digest summary. Docker may reuse cached layers; this is registry push/pull verification, not proof of a cold download. Do not run `docker login` or push to Docker Hub.

Compose runs `web` and PostgreSQL `db` on its project network. Host requests use `127.0.0.1:8080`; the app listens on container port 8080. The database listens on 5432 inside the Compose network and has no host-published port. The documented credentials `student` / `practice-only` are intentionally fake local practice values, not real secrets and not a planted security defect. Never reuse them elsewhere. No real data should be entered.

`GET /health` executes `SELECT 1` against PostgreSQL. Success is HTTP 200 with `service=cloudnotes`, `status=ok`, `database=connected`. Failure is HTTP 503 with `database=unavailable`. JSON key order is irrelevant. A running web container alone does not demonstrate database connectivity. To inspect actual errors, use `docker compose logs --tail=20 web`.

## Evidence and cleanup

Submit one PDF with one real editor/terminal capture per task and your fork URL. Commit and push only the three repaired files; do not commit state, plans, credentials, or generated evidence into this starter repository.

```bash
git add terraform/main.tf Dockerfile compose.yaml
git commit -m "Repair local release configuration"
git push -u origin fix/local-release
docker compose down
docker compose -p cloudnotes-practice-registry -f registry.yaml down
```

Application database volume persists after `down`. No data deletion is necessary for assessment. Local registry content disappears when its container is removed; republish if needed. Never use broad system prune or delete unrelated containers/images.
