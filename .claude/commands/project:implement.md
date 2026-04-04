# Implement an Infrastructure Story

Implement a GitHub issue end-to-end: issue loading, branch creation, existing config
assessment, plan writing, decision surfacing, and CI gate execution.

Run this skill at the **start of every new story**. Do not begin implementation without it.

---

## Phase 1 — Setup

### 1.1 Identify the issue

- Read the argument passed to this skill (e.g. `/project:implement 3`)
- If no argument, check the current branch name for a numeric suffix
- If still not found, ask: "Which GitHub issue should I implement?"

### 1.2 Load the issue

```
gh issue view <N>
```

Read the full issue body carefully. Extract:
- The stated **goal** — what problem this solves
- Explicit **acceptance criteria** (checklist items in the issue body)
- Implicit requirements in prose
- Explicitly **out-of-scope** items

### 1.3 Create the branch

```
git checkout main && git pull
git checkout -b feat/<scope>-<description>-<N>
```

Where `<scope>` is the infrastructure concern (e.g. `cloudflare`, `dns`, `waf`, `tls`) and `<N>` is the issue number.

---

## Phase 2 — Configuration Assessment

Explore the existing Terraform configuration before writing anything:

- Read all existing `.tf` files to understand what is already declared
- Identify which files will need to change and which will be new
- Check `versions.tf` for already-pinned providers
- Check `variables.tf` for variables that can be reused
- Note any existing resources that the new work depends on or extends

---

## Phase 3 — Implementation Plan

Write a plan to `.claude/plans/<branch-name>.md` with these sections:

```
## Summary
One paragraph: what this story delivers and why.

## Files changed
- New files: list with one-line purpose
- Modified files: list with what changes

## Resources declared
- List each new Terraform resource type and logical name

## Variables needed
- New input variables required (name, type, description, sensitive?)

## Outputs added
- New outputs and why they're useful

## Import required?
- yes/no — if yes, which resources and what IDs are needed

## Verification
- How to confirm the change is live (e.g. DNS lookup, curl, Cloudflare dashboard)

## Open decisions
- Architectural ambiguities that require input before coding starts
```

**Stop here and present the plan.** Surface all open decisions. Wait for confirmation before Phase 4.

---

## Phase 4 — Implementation

### Approach: Plan-First

Unlike application TDD, Terraform verification happens through `terraform plan` before
any real change is applied. The discipline is:

1. **Write** the resource declaration in `.tf` files
2. **Format:** `terraform fmt` — clean formatting before anything else
3. **Validate:** `terraform validate` — catches syntax and reference errors immediately
4. **Plan:** `terraform plan` — review the diff carefully before accepting
5. **Apply:** happens in Terraform Cloud after PR merge — never locally

### One resource at a time

Add one logical resource (or one group of tightly related resources) at a time.
Validate and plan after each addition. Do not batch unrelated resources.

### Import before manage

If a resource already exists in Cloudflare (created manually or by a prior process),
it must be imported before Terraform can manage it:

```
terraform import <resource_address> <resource_id>
```

Write the resource block first, then import. Never import without a matching declaration.

### Sensitive values

Never put real values in `.tf` files. Variables that hold secrets use `sensitive = true`
and are set in Terraform Cloud. Use placeholder descriptions in `variables.tf` that tell
the operator where to find the value.

### Reading `terraform plan` output

- `+` green — resource will be created
- `-` red — resource will be destroyed
- `~` yellow — resource will be updated in-place
- `-/+` — resource will be destroyed and recreated (check if this causes downtime)
- `(known after apply)` — value computed during apply, not available at plan time

Any `-/+` on a DNS record or WAF rule that is actively serving traffic must be flagged
and discussed before proceeding.

---

## Phase 5 — CI Gates

All three must PASS before the story is considered done.

### Gate 1 — Terraform validation

```
terraform fmt -check
terraform validate
terraform plan
```

`terraform fmt -check` must exit 0. `terraform validate` must report success.
`terraform plan` must show only the expected changes — no surprise additions or
deletions beyond what the issue requires.

### Gate 2 — Acceptance verification

```
/project:verify-issue
```

Every acceptance criterion must be COVERED. PARTIAL or MISSING = FAIL. Fix and re-run.

### Gate 3 — Infrastructure quality

```
/project:review
```

All categories must PASS. Fix every violation before proceeding.

---

## Phase 6 — Wrap Up

Report to the user:
- Story summary: what was implemented
- Files changed (list with one-line description of each)
- Resources added/modified
- Verification steps to confirm the change is live after apply
- Any deferred items or follow-up issues to open

Ready for `/project:ship`.
