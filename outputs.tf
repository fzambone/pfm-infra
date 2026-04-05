# outputs.tf — Output value declarations
#
# Outputs expose values after terraform apply. They're useful for:
# - Verifying what was created (e.g. the full hostname of a DNS record)
# - Cross-referencing between configurations
# - Quick lookups without opening the Cloudflare dashboard

output "pfm_api_cname_hostname" {
  description = "FQDN of the pfm-go-api DNS record (e.g. pfm-go-api.zambone.dev)"
  value       = cloudflare_dns_record.pfm_api_cname.name
}
