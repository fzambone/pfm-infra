# PFM-Infra — Infrastructure as Code for PFM

## Project Identity

- **Repo:** `github.com/fzambone/pfm-infra`
- **Stack:** Terraform + Cloudflare provider + Terraform Cloud (remote state)
- **Manages:** DNS, TLS, WAF, rate limiting, and security settings for `pfm-go-api.zambone.dev`
- **Application repo:** `github.com/fzambone/pfm-go`
- **Commits:** Conventional Commits — three-part format:
  ```
  type(scope): imperative description

  - Bullet per meaningful change (what and why, not how)

  closes #N
  ```
  Prefixes: `feat`, `fix`, `refactor`, `chore`, `docs`. Scope = infrastructure concern (e.g. `cloudflare`, `dns`, `waf`, `tls`).
  Subject: lowercase, no period, imperative mood (`add`, `enable`, `configure`, not `added`, `enables`).
  Footer `closes #N` on its own line after a blank line.
- **Git:** Trunk-based, squash-merge, short-lived branches: `feat/<scope>-<description>-<N>`
- **CI Gate:** `terraform fmt -check` + `terraform validate` + `terraform plan` (clean, no unexpected changes). All must pass.

## Non-Negotiables — Blocking Issues

1. **No Manual Changes.** Every Cloudflare configuration change must be made via a pull request to this repo — never through the dashboard. Manual changes create drift and are overwritten by the next `terraform apply`.
2. **No Secrets in Source.** API tokens, credentials, and sensitive values live in Terraform Cloud as sensitive variables — never in `.tf` files, `terraform.tfvars`, or anywhere in the repo.
3. **Pin Provider Versions.** Every provider must declare a minimum version in `versions.tf`. Unpinned providers break reproducibility.
4. **Remote State Only.** State lives in Terraform Cloud. Never commit `terraform.tfstate` or `*.tfstate.backup` to the repo.
5. **Plan Before Apply.** Every change goes through `terraform plan` review before `terraform apply`. No blind applies.
6. **Explicit Over Convenient.** Prefer readable, explicit resource declarations over clever meta-arguments. Readability matters more than DRY at this scale.

## Repository Structure

```
pfm-infra/
  versions.tf       → required_providers + required_version
  providers.tf      → provider "cloudflare" configuration
  variables.tf      → input variable declarations (no values — values in TF Cloud)
  outputs.tf        → output values for cross-reference
  main.tf           → primary resource declarations
  dns.tf            → cloudflare_record resources (if split by concern)
  waf.tf            → cloudflare_ruleset resources
  security.tf       → zone settings (SSL, HSTS, Bot Fight Mode, etc.)
  .gitignore        → excludes .terraform/, *.tfstate, *.tfstate.backup, .tfvars
  README.md         → setup guide for new contributors
```

Split files by concern when `main.tf` exceeds ~100 lines. Group related resources.

## Naming Conventions

| Thing | Convention | Example |
|-------|-----------|---------|
| Resource | `<provider>_<type>.<descriptive_name>` | `cloudflare_record.pfm_api_cname` |
| Variable | `snake_case`, noun | `cloudflare_zone_id` |
| Output | `snake_case`, noun | `pfm_api_cname_hostname` |
| Local | `snake_case`, noun | `waf_ruleset_id` |
| Descriptive names | Reflect purpose, not implementation | `pfm_api_cname` not `record_1` |

## Technology Stack

| Concern | Choice |
|---------|--------|
| IaC tool | Terraform (OpenTofu-compatible) |
| State backend | Terraform Cloud (remote execution mode) |
| DNS + Security | Cloudflare (free tier) |
| Provider | `cloudflare/cloudflare` — pin to specific minor version |
| Secrets | Terraform Cloud sensitive variables — never in repo |

### Provider Policy

**Cloudflare provider:** Manage all zone settings, DNS records, WAF rulesets, and rate limiting rules.
**No Fly.io provider:** Fly.io infrastructure is managed via `fly.toml` and `flyctl` CLI in `pfm-go`. The one-time cert provisioning (`fly certs add`) is a CLI operation, not Terraform.

## Terraform Conventions

### File Layout

- `versions.tf` — `terraform {}` block with `required_version` and `required_providers`
- `providers.tf` — `provider "cloudflare" {}` block (no credentials — injected via env/TF Cloud)
- `variables.tf` — all `variable` blocks with `type`, `description`, and `sensitive = true` where applicable
- `outputs.tf` — all `output` blocks
- Resource files — named by concern (`dns.tf`, `waf.tf`, `security.tf`)

### Variables

Every variable must have:
- `type` — never omit
- `description` — one sentence explaining what it is and where to find it
- `sensitive = true` for any secret or credential

### Resources

- One resource per logical concern — don't cram unrelated settings into one block
- Use `description` or inline comments for non-obvious configuration choices
- Prefer `for_each` over `count` for named resources (avoids index-based state churn)

### Outputs

Define outputs for any value another resource or a human operator might need:
- Zone IDs, record hostnames, ruleset IDs used for cross-referencing
- Keep output names descriptive: `pfm_api_url` not `url`

## Design Decisions

**Remote execution mode:** Terraform Cloud runs `plan` and `apply` — not local machines. This prevents state drift from local applies and ensures the Cloudflare API token never leaves Terraform Cloud.

**Cloudflare zone managed externally:** The `zambone.dev` zone is imported into Terraform state (not created by it). Use `terraform import cloudflare_zone.zambone_dev <zone_id>` on first run. The zone itself is not destroyed by `terraform destroy`.

**No `terraform destroy` on production:** Destroying the zone config would take down the production API. Treat this repo's resources as permanent — remove individual resources via PR only.

**WAF simulate-before-block:** When enabling new WAF rulesets, set action to `log` first. Review 24h of traffic before switching to `block`. This prevents false positives from silently dropping legitimate API requests.

## Error Handling (Terraform-Specific)

1. **Drift detection:** Run `terraform plan` in CI to detect drift between declared state and live Cloudflare config. Non-empty plan on `main` = someone made a manual change — open a PR to reconcile.
2. **Import before manage:** Any existing Cloudflare resource must be imported into state before it can be managed. Never use `terraform apply` to recreate a resource that already exists.
3. **Sensitive output:** Never use `terraform output` in CI logs without `-json` + masking. Sensitive outputs are redacted in Terraform Cloud by default.

## Pre-Commit Gates — Run Before Every Commit

**Step 1:** Run `/project:verify-issue` to confirm the implementation satisfies
the issue's acceptance criteria. Verdict must be PASS before proceeding.

**Step 2:** Run `/project:review` for the full infrastructure checklist:

- [ ] **Format:** `terraform fmt -check` passes — all files formatted
- [ ] **Validate:** `terraform validate` passes — no syntax or reference errors
- [ ] **Plan:** `terraform plan` produces only expected changes — no surprise drift
- [ ] **Secrets:** No credentials, tokens, or sensitive values in any `.tf` file
- [ ] **Versions:** All providers pinned in `versions.tf`
- [ ] **Variables:** All variables typed and described; sensitive ones marked
- [ ] **State:** No `.tfstate` files committed
- [ ] **Naming:** Resources named by purpose, not by index

## Build & Workflow

All Terraform operations run via CLI:
- `terraform fmt` — format all files
- `terraform validate` — validate configuration
- `terraform plan` — preview changes (runs in Terraform Cloud)
- `terraform apply` — apply changes (runs in Terraform Cloud, requires explicit approval)
- `terraform import <resource> <id>` — import existing infrastructure into state
