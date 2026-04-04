# Personal Preferences & Teaching Mandate

## Workflow Rules

- **I orchestrate, Claude codes.** I make architectural and product decisions. Claude writes all code, creates all files, and produces all implementation. I do not type code.
- **One step at a time.** One file or one logical unit per step. Pause at decisions that affect architecture or approach — don't proceed through them silently. Wait for confirmation before the next step.
- **Claude runs terraform and git commands autonomously.** Before making any file changes, create the feature branch. Use `terraform` commands and `git` to verify work (validate, plan, fmt, status, diff, log). Commits and pushes require my explicit instruction.
- **Always pin provider versions.** Never leave `version` unconstrained in `required_providers`.
- **Start every story with `/project:implement`.** This skill handles: issue loading, branch creation, existing config assessment, plan writing, decision surfacing, and CI gate execution. Do not begin implementation without running it first.
- **Branch before coding.** Before touching any file, create the feature branch from `main`: `feat/<scope>-<description>-<N>` where `<N>` is the issue number. No edits on `main` — ever. Run `terraform validate` + `terraform fmt -check`, then `/project:verify-issue`, then `/project:review` against the branch diff before suggesting a commit. All three must PASS. One branch = one issue = one squash-merge.
- **Ship with `/project:ship`.** After all CI gates pass, use `/project:ship` to run the business-alignment review, commit, push, create the PR, squash-merge, delete the branch, and sync main. Do not do these steps manually.
- **Fetch GitHub issues via `gh`.** Use `gh issue view <N>` to read issue details and acceptance criteria.
- **Never apply from local.** `terraform apply` runs in Terraform Cloud. Local work produces plans only — never apply locally.

## Decision Points — Always Stop and Ask

Stop and surface a decision when:
- A new provider or resource type is needed that isn't already in use
- A Cloudflare feature has free vs. paid variants and the right tier isn't clear
- An import is needed (existing resource must be brought into state)
- A change could cause downtime or disrupt the live production API
- Something in the acceptance criteria is unclear or potentially in conflict

## Teaching Mandate — Terraform & IaC Mastery

I am newer to Terraform and infrastructure as code. When writing configuration,
**proactively explain Terraform-specific idioms and patterns** that differ from
application development.

### Always Explain These When They Appear

- **HCL syntax:** block types, argument vs block distinction, heredoc strings,
  expressions vs literals, `${}` interpolation, `%{}` directives
- **State mechanics:** why state exists, what it tracks, why remote state matters,
  what happens when state drifts from reality
- **Resource lifecycle:** `create`, `read`, `update`, `destroy` — when each fires,
  why `terraform plan` shows a destroy+create instead of update
- **Provider mechanics:** why providers are plugins, what the version constraint
  `~>` means vs `>=`, why pinning matters for reproducibility
- **Meta-arguments:** `for_each` vs `count` — when each is appropriate and why
  `for_each` avoids index churn, `depends_on`, `lifecycle` blocks
- **Data sources:** the difference between `resource` (manages) and `data` (reads),
  when to use each, why importing beats recreating
- **Variables and outputs:** input vs local vs output — the data flow model,
  why `sensitive = true` matters in Terraform Cloud output masking
- **Import:** why `terraform import` exists, what it does to state, why you must
  write the matching resource block before importing
- **Workspaces vs directories:** when to use multiple workspaces vs separate directories
  for environment separation
- **`terraform plan` reading:** how to read the diff symbols (`+`, `-`, `~`, `-/+`),
  what "forces replacement" means and why it matters for production resources

### How to Explain

- **Comment non-obvious blocks.** Any Terraform block that isn't self-explanatory
  gets an inline comment explaining why it's written that way.
- **Inline with guidance:** When a step uses a Terraform-specific pattern, add 2-3
  sentences on WHY it works that way — not just what to type.
- **Connect to production impact:** Infrastructure changes affect live systems.
  Always surface the production consequence of a change (e.g. "this forces a
  replacement, which means a brief DNS propagation window").
- **Use `/project:learn`** when I ask for a deeper dive on any concept.

### Do NOT Explain

- Basic HCL syntax (string, number, bool) once understood
- Things I've already demonstrated understanding of in previous interactions
