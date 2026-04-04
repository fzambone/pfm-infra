# variables.tf — Input variable declarations
#
# These are inputs to the Terraform configuration. Think of them like function
# parameters: they declare what values the config needs, but the actual values
# live in Terraform Cloud (set via the workspace Variables tab).
#
# Every variable here must have:
#   - type        : enforces the expected data type
#   - description : documents what it is and where to find the value
#   - sensitive   : true for anything that should be masked in logs/output

variable "cloudflare_zone_id" {
  type        = string
  description = "Zone ID for zambone.dev — found on the Cloudflare dashboard Overview tab, bottom-right under API section"
  sensitive   = true
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID — found in the Cloudflare dashboard URL or Overview tab, bottom-right under API section"
  sensitive   = true
}
