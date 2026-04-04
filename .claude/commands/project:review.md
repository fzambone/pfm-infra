# Infrastructure Code Review Checklist

Run this complete checklist against all changed files. Every item must pass.
Do NOT suggest a commit until all categories report PASS.

Review the actual configuration — read every changed `.tf` file, check variable
declarations, verify no secrets are present.

## Format and Syntax
- [ ] `terraform fmt -check` exits 0 — all files are correctly formatted
- [ ] `terraform validate` exits 0 — no syntax errors or invalid references
- [ ] All files use consistent 2-space indentation (enforced by `terraform fmt`)
- [ ] No trailing whitespace

## Secrets and Sensitive Values
- [ ] No credentials, API tokens, or secrets hardcoded in any `.tf` file
- [ ] No `.tfvars` files committed
- [ ] Variables holding sensitive values have `sensitive = true`
- [ ] No sensitive values in output blocks without `sensitive = true`
- [ ] No real zone IDs, account IDs, or resource IDs hardcoded — use variables or data sources

## Provider and Version Pinning
- [ ] All providers declared in `required_providers` in `versions.tf`
- [ ] Every provider has a `version` constraint — no unconstrained providers
- [ ] `required_version` declares a minimum Terraform version
- [ ] Version constraints use `~>` (pessimistic) or `>=` with `<` upper bound — never `latest` or no constraint

## Resource Quality
- [ ] Every resource has a descriptive name that reflects its purpose (not `record_1`, `rule_1`)
- [ ] Resources use `for_each` instead of `count` when iterating over named things
- [ ] No duplicate resource declarations
- [ ] Resources that already exist in the provider are imported, not recreated
- [ ] `lifecycle` blocks used only when necessary and with clear justification
- [ ] `depends_on` used only when implicit dependency detection is insufficient

## Variables
- [ ] Every `variable` block has a `type` declared
- [ ] Every `variable` block has a `description` — one sentence explaining what it is and where to find the value
- [ ] Variables with no safe default have no `default` (forces explicit set in TF Cloud)
- [ ] Variables holding secrets or IDs are marked `sensitive = true`

## Outputs
- [ ] Every `output` block has a `description`
- [ ] Outputs exposing sensitive values have `sensitive = true`
- [ ] Outputs are defined for any value a human operator or cross-reference might need
- [ ] No unused outputs

## State Safety
- [ ] No `*.tfstate` or `*.tfstate.backup` files staged or committed
- [ ] No `.terraform/` directory staged or committed
- [ ] `terraform plan` shows only the changes declared in this PR — no unrelated drift
- [ ] No `-/+` (destroy and recreate) on resources actively serving production traffic
  without explicit acknowledgement and user confirmation

## Cloudflare-Specific
- [ ] DNS records use the correct `type` (CNAME vs A vs TXT)
- [ ] Proxied records (`proxied = true`) are intentional — only proxy records that should
  go through Cloudflare's network (not cert validation TXT records)
- [ ] SSL/TLS mode changes are backward-compatible — do not switch to Full (Strict)
  before the origin cert is confirmed active
- [ ] WAF rulesets introduced in `log` mode before `block` mode
- [ ] Rate limiting thresholds are documented with rationale in a comment
- [ ] Zone settings that are being changed from Cloudflare defaults are commented
  with the reason

## Documentation
- [ ] Non-obvious resource configurations have inline comments explaining why
- [ ] Any manual step required (e.g. `terraform import`, nameserver update at registrar)
  is documented in the PR description or an inline comment
- [ ] `README.md` is updated if the change introduces new prerequisites or setup steps

## Final Verification
- [ ] `terraform fmt -check` passes
- [ ] `terraform validate` passes
- [ ] `terraform plan` output reviewed — matches expected changes exactly
- [ ] Commit message follows: `type(scope): description` + `closes #N`

---

**Report format:** List each category as PASS or FAIL.
For failures, state the specific violation and the file:line where it occurs.
Do NOT suggest committing until every category passes.

Categories:
1. Format and Syntax
2. Secrets and Sensitive Values
3. Provider and Version Pinning
4. Resource Quality
5. Variables
6. Outputs
7. State Safety
8. Cloudflare-Specific
9. Documentation
