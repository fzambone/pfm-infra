# Break Down an Epic Issue

Expand a parent epic issue into implementable child issues. The epic already defines
the breakdown, key behaviors, acceptance criteria, and scope boundaries. This skill's
job is to produce high-quality individual issues from that blueprint.

Each child issue must be self-contained and implementable with `/project:implement`.

---

## Phase 1 — Load the Epic

### 1.1 Identify the issue

- Read the argument (e.g. `/project:breakdown 1`)
- If no argument, ask: "Which GitHub issue should I break down?"

### 1.2 Fetch and extract

```
gh issue view <N> --repo fzambone/pfm-infra
```

The epic contains:
- **Breakdown pattern** — the numbered list of issues to create
- **Acceptance Criteria** — behavioral requirements to distribute across child issues
- **Scope Boundaries** — what's explicitly out
- **Depends On** — external prerequisites
- **Infrastructure Requirements** — provider-level constraints and ordering rules

Extract all of these. They are the inputs to the breakdown.

### 1.3 Assess the existing configuration

Before writing issues, understand what already exists:
- Read all existing `.tf` files to see what's already declared
- Check `versions.tf` for already-pinned providers
- Check if any resources that the new issues need already exist and need `terraform import`
- Note any manual prerequisites (e.g. nameserver updates at registrar)

This determines whether issues say "declare" (new) or "extend" (already exists).

---

## Phase 2 — Expand Into Child Issues

### 2.1 Map the epic's pattern to issues

Use the epic's own breakdown list as the skeleton. For each item:

1. Take the one-line description from the epic
2. Distribute the relevant acceptance criteria from the epic to this issue
3. Add edge cases specific to this infrastructure layer
4. Set scope boundaries so issues don't overlap

### 2.2 Issue structure

Each child issue MUST have these sections:

```markdown
## Context
One paragraph: why this issue exists, what infrastructure it manages, how it fits the milestone.

## Depends On
- #N — description of what's needed from that issue

## What This Enables
- Bullet list of capabilities unlocked by completing this work

## Acceptance Criteria
1. When <action>, <expected behavior>.
2. When <condition>, <expected outcome>.
...

## Edge Cases to Handle
- [ ] Description of edge case and expected behavior

## Scope Boundaries
- No <thing explicitly out of scope for this issue>.
```

### 2.3 Quality standards

**Behavioral, not prescriptive:**
- GOOD: "When pfm-go-api.zambone.dev is resolved, it returns a Cloudflare proxy IP"
- BAD: "Set `proxied = true` on the cloudflare_record resource"

**No configuration snippets.** No HCL blocks, no Terraform syntax.

**Each issue is independently verifiable.** After completing issue N, a `curl`, DNS lookup,
or Cloudflare dashboard review confirms the change is live.

**No overlapping scope.** Each Cloudflare concern (DNS, TLS, WAF, zone settings) lives
in exactly one issue.

### 2.4 Dependency chain

- Infrastructure issues form a strict DAG: provider setup → DNS → TLS → security
- Each issue's `Depends On` must reference concrete issue numbers
- Call out any manual steps that must happen outside of Terraform (e.g. updating
  nameservers at GoDaddy) and note that propagation takes time

---

## Phase 3 — Present for Review

Before creating any issues, present the full breakdown:

```
Epic #N: <title>
Milestone: <milestone>

| # | Title | Layer | Depends On | Key behaviors |
|---|-------|-------|------------|---------------|
| 1 | ...   | ...   | ...        | ...           |
...
```

Then show the **full body** of each issue.

**Stop here and wait for approval.**

---

## Phase 4 — Create Issues

After approval:

```
gh issue create \
  --repo fzambone/pfm-infra \
  --title "<title>" \
  --milestone "<milestone>" \
  --body "$(cat <<'ISSUE_EOF'
Parent epic: #N

<full issue body>
ISSUE_EOF
)"
```

Rules:
- Create in dependency order (first issue first)
- After all issues are created, update `Depends On` sections with real numbers

---

## Phase 5 — Update the Epic

```
gh issue edit <N> --repo fzambone/pfm-infra --body "$(cat <<'EPIC_EOF'
<original epic body — preserve exactly>

## Child Issues
- [ ] #A — <title>
- [ ] #B — <title>
...
EPIC_EOF
)"
```

---

## Phase 6 — Report

```
Epic #N: <title>
Created <count> child issues:
- #A — <title>
- #B — <title>
...

Dependency graph:
#A → #B → #C → #D

Ready for /project:implement <first-issue>.
```
