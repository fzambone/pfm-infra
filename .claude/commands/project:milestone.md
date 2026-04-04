# Create a New Milestone

Plan and create a new GitHub milestone with an epic issue and fully broken-down child
issues. This skill is **conversational first** — it asks questions to get the milestone
right before touching GitHub.

The output must match the quality and structure of all previous milestones:
epic issue with full context + acceptance criteria, child issues that are behavioral,
independently testable, and dependency-ordered.

---

## Phase 1 — Gather Information

Before proposing anything, ask the following questions **in a single message**. Wait for
all answers before proceeding.

```
I need to understand the milestone before drafting it. Please answer:

1. **Goal** — One sentence: what does this milestone deliver?
2. **Motivation** — Why now? What problem does it solve or what capability does it unlock?
3. **What it enables** — What becomes possible after this milestone that wasn't before?
4. **Depends on** — Which previous milestones or issues must be complete first?
5. **Scope** — What is explicitly IN scope? What is explicitly OUT of scope?
6. **Rough size** — Is this a small milestone (2–4 stories) or a larger one (5–10 stories)?
7. **Any constraints** — Technology choices, provider limitations, or non-negotiables?
```

If the user has already provided most of this context in their message, extract what you
can and only ask for the gaps.

---

## Phase 2 — Determine the Milestone Number

```
gh api repos/fzambone/pfm-infra/milestones --jq '.[].number' | sort -n | tail -1
```

The new milestone number is `max + 1`. Name format: `M{N}: {Title}`.

---

## Phase 3 — Draft the Epic and Breakdown

### 3.1 Epic issue structure

Every epic follows this exact structure (no deviations):

```markdown
## Context
{Two to four sentences explaining the current infrastructure state, the gap, and why
this milestone addresses it. Reference previous milestones by name if relevant.}

## What This Enables
- {Bullet: capability unlocked}
- {Bullet: operational confidence gained}
- {Bullet: future milestone unblocked}

## Depends On
- M{N} — {reason this prior milestone is a prerequisite}

## {Domain-specific section if applicable}
{E.g. "Security Requirements", "Infrastructure Constraints", "Provider Limitations"}
{Bullet list of the key requirements the child issues must satisfy.}

## Acceptance Criteria (Epic-Level)
1. When {condition}, {outcome}.
2. When {condition}, {outcome}.
...

## Scope Boundaries
- No {thing explicitly excluded}.
- No {thing explicitly excluded}.

**Action Required:** Break this into {N} separate issues following the pattern below
before starting implementation.

## Child Issues
(populated after child issues are created)
```

### 3.2 Child issue structure

Every child issue follows this exact structure:

```markdown
Parent epic: #{epic_number}

## Context
{One paragraph: why this issue exists, what infrastructure layer it operates in,
how it fits the milestone. Reference the epic by number.}

## Depends On
- #{N} — {what's needed from that issue}

## What This Enables
- {Bullet: what this issue unlocks for the next one}

## Acceptance Criteria
1. When {action}, {expected behavior}.
2. When {condition}, {expected outcome}.
...

## Edge Cases to Handle
- [ ] {Edge case and expected behavior}

## Scope Boundaries
- No {thing explicitly out of scope for this issue}.
```

### 3.3 Quality standards (non-negotiable)

**Behavioral, not prescriptive.**
- GOOD: "When a request hits the WAF with a known injection pattern, it is blocked at the edge"
- BAD: "Configure the `cloudflare_ruleset` resource with action = 'block'"

**No configuration snippets.** No HCL, no Terraform blocks, no provider-specific syntax.
The implementer decides the shape during `/project:implement`.

**Each issue is independently testable.** After completing issue N, there is something
concrete to verify (DNS lookup, curl response, Cloudflare dashboard state) without needing N+1.

**No overlapping scope.** Each concern lives in exactly one issue.

**Dependency chain is a DAG.** Infrastructure layers go in order: provider setup → DNS →
TLS → security rules. Allow parallel work where the layers permit.

---

## Phase 4 — Present for Review

Present the complete proposal **before creating anything**:

```
Milestone: M{N}: {Title}

Epic: {one-line summary}

Child issues ({count} total):

| # | Title | Layer | Depends On | Key behaviors |
|---|-------|-------|------------|---------------|
| 1 | ...   | ...   | epic deps  | ...           |
| 2 | ...   | ...   | #1         | ...           |
...
```

Then show the **full body** of every issue — epic first, then each child.

**Stop here. Wait for explicit approval.**

---

## Phase 5 — Create the Milestone and Issues

After approval:

### 5.1 Create the GitHub milestone

```
gh api repos/fzambone/pfm-infra/milestones \
  --method POST \
  --field title="M{N}: {Title}" \
  --field description="{one-line description}"
```

### 5.2 Create the epic issue

```
gh issue create \
  --repo fzambone/pfm-infra \
  --title "{epic title}" \
  --milestone "M{N}: {Title}" \
  --body "$(cat <<'ISSUE_EOF'
{full epic body — Child Issues section left empty for now}
ISSUE_EOF
)"
```

### 5.3 Create child issues in dependency order

```
gh issue create \
  --repo fzambone/pfm-infra \
  --title "{title}" \
  --milestone "M{N}: {Title}" \
  --body "$(cat <<'ISSUE_EOF'
Parent epic: #{epic_number}

{full issue body}
ISSUE_EOF
)"
```

After each creation, note the assigned issue number. Update `Depends On` sections in
subsequent issues with real numbers before creating them.

### 5.4 Update the epic with the child issue checklist

```
gh issue edit {epic_number} --repo fzambone/pfm-infra --body "$(cat <<'EPIC_EOF'
{original epic body — preserved exactly}

## Child Issues
- [ ] #{A} — {title}
- [ ] #{B} — {title}
...
EPIC_EOF
)"
```

---

## Phase 6 — Report

```
Milestone: M{N}: {Title}
Epic:      #{epic_number} — {title}
Issues:    {count} child issues created

Child issues:
- #{A} — {title}
- #{B} — {title}
...

Dependency graph:
#{A} → #{B} → #{D}
#{A} → #{C} → #{D}

Ready for /project:implement #{first_issue}.
```
