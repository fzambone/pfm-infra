# Terraform & IaC Concept Deep Dive

The user wants to understand a Terraform or infrastructure-as-code concept more deeply.
They may specify a topic, or reference configuration they just wrote but didn't fully understand.

Follow this structure for every explanation:

## 1. What It Is
Explain the concept in plain language. No jargon soup. One paragraph max.

## 2. How It Works in Terraform
Show the mechanics with a minimal HCL example. Prefer examples from our pfm-infra
codebase when possible. If the concept hasn't appeared yet, use a self-contained example.

## 3. Why Terraform Does It This Way
Connect to Terraform's design philosophy:
- Declarative over imperative — describe the desired state, not the steps
- Plan before apply — every change is previewed before it's made
- State as the source of truth — Terraform knows what it manages
- Provider abstraction — same workflow for any cloud provider

Every Terraform idiom exists for a reason. Explain the tradeoff.

## 4. Coming From Application Development
Compare with the application development mental model. Use this table format:

| App Dev Concept | Terraform Equivalent | Why It Differs |
|----------------|---------------------|----------------|
| ... | ... | ... |

Highlight:
- What's genuinely different about the declarative model
- The specific mental model shift required (state, drift, idempotency)
- Common mistakes from applying imperative thinking to declarative tools

## 5. In Our Codebase
Point to specific files in pfm-infra where this concept is used or will be used.
Reference file paths and line numbers when applicable.

## 6. Common Mistakes
List the 2-3 most common mistakes with this concept, especially mistakes from
developers new to IaC.

---

## Reference: Terraform Concepts by Category

### Core Mechanics
- **State:** what it is, why it exists, what happens when it drifts from reality
- **Plan vs Apply:** why the two-phase approach prevents surprises
- **Idempotency:** why `terraform apply` twice produces no second change
- **Refresh:** when Terraform re-reads real infrastructure vs. uses cached state
- **Drift:** what it is, how to detect it, how to reconcile it

### Configuration Language (HCL)
- **Blocks vs arguments:** the structural difference between `resource {}` and `name = value`
- **Expressions:** string interpolation `${}`, conditional `condition ? a : b`, `for` expressions
- **Functions:** built-in functions (`toset`, `merge`, `lookup`, `try`) — when and why
- **`locals`:** computed values that avoid repetition without exposing outputs
- **`depends_on`:** when implicit dependency detection fails and you need explicit ordering
- **`lifecycle`:** `prevent_destroy`, `create_before_destroy`, `ignore_changes` — when each is safe

### Resources and Data Sources
- **Resource:** Terraform creates, updates, and destroys this
- **Data source:** Terraform reads this — never modifies it
- **`terraform import`:** bringing existing infrastructure under Terraform management
- **`count` vs `for_each`:** why `for_each` avoids index churn on named resources
- **`-/+` in plan:** destroy-and-recreate — when it happens, why it matters for production

### Variables and Outputs
- **Input variables:** the interface between the operator and the configuration
- **`sensitive = true`:** what it does (masks in logs), what it doesn't do (not encryption)
- **`default` vs no default:** when to require explicit values vs. provide a safe default
- **Outputs:** why they exist, cross-module reference, `terraform output` command
- **Locals:** computed values internal to the configuration — not exposed as inputs or outputs

### Providers
- **What a provider is:** a plugin that translates HCL to API calls
- **Version pinning:** `~>` pessimistic constraint, why reproducibility requires pinning
- **Provider configuration:** where credentials go (environment variables, TF Cloud variables)
- **`required_providers`:** why it lives in `versions.tf` and what happens without it

### State and Backends
- **Local vs remote state:** why local state is unsuitable for teams and CI
- **Terraform Cloud backend:** remote execution, state locking, run history
- **State locking:** preventing concurrent applies from corrupting state
- **`terraform state` commands:** `list`, `show`, `mv`, `rm` — and when to use them carefully
- **State file contents:** what's in it, why secrets appear there, why it needs protection

### Cloudflare Provider Specifics
- **Zone vs record:** the hierarchy — zone owns the domain, records are within it
- **`proxied = true`:** what orange-cloud means, when NOT to proxy (cert validation TXT records)
- **`cloudflare_ruleset`:** the unified resource for WAF rules, rate limiting, and transforms
- **Zone settings:** `cloudflare_zone_settings_override` — only declare settings you're changing
- **API token vs API key:** prefer scoped API tokens over global API keys

### Workflow
- **`terraform fmt`:** why formatting is enforced (readability, diffs)
- **`terraform validate`:** what it checks (syntax + references) and what it misses (API validity)
- **`terraform plan -out=tfplan`:** saving a plan for deterministic apply
- **Remote execution mode:** why apply runs in Terraform Cloud, not locally
- **Workspace variables:** sensitive values in TF Cloud vs. in `.tfvars`

### Common Terraform Traps
- **Importing without a resource block:** `terraform import` fails if the resource isn't declared
- **Hardcoded IDs:** zone IDs and account IDs in `.tf` files expose infrastructure details
- **Sensitive outputs without `sensitive = true`:** values appear in plain text in `terraform output`
- **`count` on named resources:** renaming or reordering causes destroy+recreate of all resources
- **Not planning after import:** imported state may differ from the declared config — always plan after import
- **Manual changes creating drift:** any dashboard click creates state the next `terraform plan` will fight

---

If the user doesn't specify a topic, ask: "What Terraform or infrastructure concept would you like to understand better?"
