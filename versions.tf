# versions.tf — Terraform and provider version constraints
#
# This block does two things:
# 1. Declares the minimum Terraform CLI version required to use this config
# 2. Pins the Cloudflare provider to a major version range (~> 4.0 = any 4.x)
#
# The "cloud" block connects this repo to Terraform Cloud, which stores state
# remotely and runs plan/apply on its servers — never on your local machine.

terraform {
  required_version = ">= 1.5"

  cloud {
    organization = "pfm"

    workspaces {
      name = "pfm-infra"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
