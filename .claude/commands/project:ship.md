# Ship the Current Story

Commit, push, create a GitHub PR, squash-merge, delete the branch, and sync main.

Run this skill **after all three CI gates pass** (`terraform validate` + `/project:verify-issue` + `/project:review`).
Do not run this on `main` directly.

---

## Preconditions

- Must be on a `feat/` branch (never `main`)
- All CI gates must have passed in this session
- No uncommitted changes that belong to a different story
- `terraform plan` produced only the expected changes — no surprise drift

If any precondition fails, stop and report what needs to be resolved first.

---

## Step 1 — Business Alignment Review

Before committing, verify we built the **right thing**:

- **Scope fidelity:** Does the implementation match what the issue asked for — no more, no less?
- **Interpretation fidelity:** Did we interpret ambiguous requirements correctly?
- **No manual state:** Does the Terraform plan match reality, or is there drift that needs reconciling first?
- **Acceptance criteria:** Is every criterion in the issue body fully addressed?

Report the verdict:
```
Business Alignment: PASS / NEEDS DISCUSSION
- [criterion 1] → addressed / not addressed
- ...
```

If NEEDS DISCUSSION, stop and ask before proceeding.

---

## Step 2 — Stage files

Stage only files relevant to this story. Never use `git add -A` or `git add .`.

```
git status
git add <file1> <file2> ...
```

Exclude:
- `.claude/plans/` — plan files are session artifacts, not repo history
- `.terraform/` — provider plugins, never committed
- `*.tfstate`, `*.tfstate.backup` — state files, never committed
- `*.tfvars` — variable value files, never committed (may contain secrets)

Verify the staging area with `git diff --cached --stat`.

---

## Step 3 — Commit

Use Conventional Commits format:

```
type(scope): imperative description

- Bullet per meaningful change (what and why, not how)

closes #N
```

Rules:
- `type`: `feat`, `fix`, `refactor`, `chore`, `docs`
- `scope`: infrastructure concern (e.g. `cloudflare`, `dns`, `waf`, `tls`)
- Subject: lowercase, no period, imperative mood (`add`, `enable`, `configure`)
- Footer `closes #N` on its own line after a blank line
- One commit per story

```
git commit -m "$(cat <<'EOF'
type(scope): description

- bullet 1
- bullet 2

closes #N
EOF
)"
```

---

## Step 4 — Push

```
git push -u origin <branch-name>
```

---

## Step 5 — Create Pull Request

```
gh pr create --title "<type>(scope): description" --body "$(cat <<'EOF'
## Summary
- bullet 1
- bullet 2

## Verification
- [ ] `terraform fmt -check` passes
- [ ] `terraform validate` passes
- [ ] `terraform plan` shows only expected changes
- [ ] `/project:verify-issue` verdict: PASS
- [ ] `/project:review` verdict: PASS

## Post-merge steps
- [ ] Confirm Terraform Cloud apply completes successfully
- [ ] Verify live infrastructure matches declared state
EOF
)"
```

---

## Step 6 — Squash-merge

```
gh pr merge --squash --delete-branch
```

Confirm the PR number before merging.

---

## Step 7 — Sync main

```
git checkout main
git pull
```

---

## Step 8 — Report

```
Branch:       feat/<scope>-<description>-<N>
PR:           #<number> — <url>
Merged:       squash-merge ✓
Branch:       deleted ✓
Main:         synced ✓
Business:     PASS / NEEDS DISCUSSION

Story #<N> is done.
Note: confirm Terraform Cloud apply completes after merge triggers the run.
```
