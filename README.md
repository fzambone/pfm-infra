# pfm-infra

Infrastructure as Code for the PFM (Personal Finance Manager) platform.
Manages DNS, TLS, WAF, rate limiting, and security settings for
`pfm-go-api.zambone.dev` via Terraform and the Cloudflare provider.

## What this repository manages

| Concern         | Provider   | Resources                              |
|-----------------|------------|----------------------------------------|
| DNS records     | Cloudflare | CNAME, TXT, and other record types     |
| TLS/SSL         | Cloudflare | SSL mode, HSTS, minimum TLS version    |
| WAF             | Cloudflare | Managed rulesets, custom rules          |
| Rate limiting   | Cloudflare | Rate limiting rules for API protection  |
| Bot protection  | Cloudflare | Bot Fight Mode                         |

The application itself (Go API, Fly.io deployment) lives in
[pfm-go](https://github.com/fzambone/pfm-go).

## Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/install) >= 1.5
- A [Terraform Cloud](https://app.terraform.io) account with access to the `pfm` organization
- A Cloudflare account with access to the `zambone.dev` zone

## Directory structure

```
versions.tf       → Terraform version constraints and Terraform Cloud backend
providers.tf      → Cloudflare provider configuration (no credentials in code)
variables.tf      → Input variable declarations
outputs.tf        → Output value declarations
dns.tf            → DNS record resources (added in future issues)
waf.tf            → WAF ruleset resources (added in future issues)
security.tf       → Zone security settings (added in future issues)
```

## Authentication

### Terraform Cloud

Terraform Cloud stores state and runs plan/apply remotely. Authenticate your CLI:

```bash
terraform login
```

This opens a browser to generate an API token, stored at
`~/.terraform.d/credentials.tfrc.json`.

### Cloudflare API token

The Cloudflare API token is configured as a **sensitive environment variable**
(`CLOUDFLARE_API_TOKEN`) in the Terraform Cloud workspace. It never appears in
this repository.

To create a token: Cloudflare dashboard → My Profile → API Tokens → Create Token.
The token needs permissions for the `zambone.dev` zone: Zone Settings (Read),
Zone (Read), DNS (Edit), Firewall Services (Edit).

## Usage

### Initialize

```bash
terraform init
```

Connects to Terraform Cloud and downloads the Cloudflare provider.

### Preview changes

```bash
terraform plan
```

Runs remotely in Terraform Cloud. Shows what would change without applying.

### Apply changes

Changes are applied via Terraform Cloud after a pull request is merged.
**Never run `terraform apply` locally** — this prevents state drift and ensures
all changes go through code review.

### Format and validate

```bash
terraform fmt        # Auto-format all .tf files
terraform validate   # Check syntax and references
```

## Workflow

1. Create a branch: `feat/<scope>-<description>-<N>`
2. Make changes to `.tf` files
3. Run `terraform fmt` and `terraform validate`
4. Run `terraform plan` to preview
5. Open a pull request
6. After review, squash-merge to `main`
7. Terraform Cloud applies the change automatically
